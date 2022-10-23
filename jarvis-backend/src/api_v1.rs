use actix_session::Session;
use actix_web::body::{BoxBody, EitherBody};
use actix_web::dev::{ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::{delete, get, head, post, put, web, Error, HttpResponse, Responder, Scope};
use mongodb::bson::oid::ObjectId;
use serde::{Deserialize, Serialize};

use crate::dto;
use crate::security::{AuthTransformer, UserData};
use crate::MongoRepo;

use super::model::List;

pub fn api_v1() -> Scope {
    web::scope("/v1").service(auth_api()).service(list_api())
}

// ===== AUTH =====

#[derive(Serialize, Deserialize)]
struct LoginData {
    email: String,
    password: String,
}

fn auth_api() -> Scope {
    web::scope("/auth")
        .service(login)
        .service(logout)
        .service(check)
}

#[post("/login")]
async fn login(
    login_data: web::Json<LoginData>,
    session: Session,
    repo: web::Data<MongoRepo>,
) -> impl Responder {
    let user = match repo.find_user_by_email(&login_data.email).await {
        Ok(Some(user)) => user,
        Ok(None) => return HttpResponse::Unauthorized().finish(),
        Err(err) => {
            log::error!("Error while fetching user by email: {:?}", err);
            return HttpResponse::InternalServerError().finish();
        }
    };

    match bcrypt::verify(&login_data.password, &user.password) {
        Ok(true) => {}
        Ok(false) => return HttpResponse::Unauthorized().finish(),
        Err(err) => {
            log::error!("Error while verifying password: {:?}", err);
            return HttpResponse::InternalServerError().finish();
        }
    };

    let user_data = UserData::new(&user);

    if let Err(err) = session.insert("user", user_data) {
        log::error!("Could not add user data to session: {:?}", err);
        return HttpResponse::InternalServerError().finish();
    }

    HttpResponse::Ok().finish()
}

#[post("/logout")]
async fn logout(session: Session) -> impl Responder {
    session.purge();

    HttpResponse::Ok().finish()
}

#[head("/check")]
async fn check(session: Session) -> impl Responder {
    if let Ok(Some(_user)) = session.get::<UserData>("user") {
        HttpResponse::Ok().finish()
    } else {
        HttpResponse::Unauthorized().finish()
    }
}

// ===== LIST =====

fn list_api() -> Scope<
    impl ServiceFactory<
        ServiceRequest,
        Response = ServiceResponse<EitherBody<BoxBody>>,
        Error = Error,
        Config = (),
        InitError = (),
    >,
> {
    let auth_transformer = AuthTransformer {};

    web::scope("/lists")
        .wrap(auth_transformer)
        .service(get_lists)
        .service(create_list)
        .service(get_list)
        .service(delete_list)
        .service(update_list)
}

#[derive(Debug, Deserialize)]
struct GetListsQuery {
    show_closed: Option<bool>,
}

#[get("")]
async fn get_lists(
    repo: web::Data<MongoRepo>,
    query: web::Query<GetListsQuery>,
    session: Session,
) -> impl Responder {
    let user_data = match get_user_data(session) {
        Ok(user_data) => user_data,
        Err(failed) => return failed,
    };

    let show_closed = query.show_closed.unwrap_or(false);

    match repo.find_all_lists(user_data, show_closed).await {
        Ok(lists) => {
            let mut dtos: Vec<dto::List> = Vec::new();

            for list in lists {
                let dto: dto::List = list.into();
                dtos.push(dto)
            }

            HttpResponse::Ok().json(dtos)
        }
        Err(err) => {
            log::error!("Could not get lists: {:?}", err);
            HttpResponse::InternalServerError().finish()
        }
    }
}

#[post("")]
async fn create_list(
    list: web::Json<dto::List>,
    repo: web::Data<MongoRepo>,
    session: Session,
) -> impl Responder {
    let user_data = match get_user_data(session) {
        Ok(user_data) => user_data,
        Err(failed) => return failed,
    };

    let model: List = list.into_inner().into();

    match repo.insert_list(model, user_data).await {
        Ok(list) => {
            let dto: dto::List = list.into();
            HttpResponse::Ok().json(dto)
        }
        Err(err) => {
            log::error!("Creating list failed: {:?}", err);
            HttpResponse::InternalServerError().finish()
        }
    }
}

#[get("/{list_id}")]
async fn get_list(
    list_id: web::Path<String>,
    repo: web::Data<MongoRepo>,
    session: Session,
) -> impl Responder {
    let id = match ObjectId::parse_str(list_id.into_inner()) {
        Ok(id) => id,
        Err(_err) => return HttpResponse::BadRequest().finish(),
    };

    let user_data = match get_user_data(session) {
        Ok(user_data) => user_data,
        Err(failed) => return failed,
    };

    match repo.find_list_by_id(id, user_data).await {
        Ok(Some(list)) => {
            let dto: dto::List = list.into();
            HttpResponse::Ok().json(dto)
        }
        Ok(None) => HttpResponse::NotFound().finish(),
        Err(err) => {
            log::error!("Could not get list: {:?}", err);
            HttpResponse::InternalServerError().finish()
        }
    }
}

#[delete("/{list_id}")]
async fn delete_list(
    list_id: web::Path<String>,
    repo: web::Data<MongoRepo>,
    session: Session,
) -> impl Responder {
    let id = match ObjectId::parse_str(list_id.into_inner()) {
        Ok(id) => id,
        Err(_err) => return HttpResponse::BadRequest().finish(),
    };

    let user_data = match get_user_data(session) {
        Ok(user_data) => user_data,
        Err(failed) => return failed,
    };

    if let Err(err) = repo.delete_list_by_id(id, user_data).await {
        log::error!("Error while deleting list {}: {:?}", id, err)
    }

    HttpResponse::NoContent().finish()
}

#[put("/{list_id}")]
async fn update_list(
    list_id: web::Path<String>,
    list: web::Json<dto::List>,
    repo: web::Data<MongoRepo>,
    session: Session,
) -> impl Responder {
    let id = match ObjectId::parse_str(list_id.into_inner()) {
        Ok(id) => id,
        Err(_err) => return HttpResponse::BadRequest().finish(),
    };

    let user_data = match get_user_data(session) {
        Ok(user_data) => user_data,
        Err(failed) => return failed,
    };

    let model: List = list.into_inner().into();

    if let Err(err) = repo.update_list(id, model, user_data).await {
        log::error!("Could not update list: {:?}", err);
        return HttpResponse::InternalServerError().finish();
    }

    HttpResponse::NoContent().finish()
}

fn get_user_data(session: Session) -> Result<UserData, HttpResponse> {
    match session.get::<UserData>("user") {
        Ok(Some(user_data)) => {
            log::debug!("Received data: {:?}", user_data);
            Ok(user_data)
        }
        Ok(None) => Err(HttpResponse::Unauthorized().finish()),
        Err(err) => {
            log::error!("Error while getting user data: {:?}", err);
            Err(HttpResponse::InternalServerError().finish())
        }
    }
}
