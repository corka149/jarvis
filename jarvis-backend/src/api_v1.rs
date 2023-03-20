use actix_session::Session;
use actix_web::body::{BoxBody, EitherBody};
use actix_web::dev::{ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::{delete, get, head, post, put, web, Error, HttpResponse, Responder, Scope};

use serde::Deserialize;

use crate::{dto, service};

use crate::security::{AuthTransformer, UserData};
use crate::service::JarvisError;
use crate::storage::MongoRepo;

pub fn api_v1() -> Scope {
    web::scope("/v1").service(auth_api()).service(list_api())
}

// ===== AUTH =====

fn auth_api() -> Scope {
    web::scope("/auth")
        .service(login)
        .service(logout)
        .service(check)
}

#[post("/login")]
async fn login(
    login_data: web::Json<service::LoginData>,
    session: Session,
    repo: web::Data<MongoRepo>,
) -> HttpResponse {
    let user_data = match service::login(login_data.0, &repo).await {
        Ok(user_data) => user_data,
        Err(err) => return into_response(err),
    };

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

    match service::get_lists(&repo, show_closed, user_data).await {
        Ok(lists) => HttpResponse::Ok().json(lists),
        Err(err) => into_response(err),
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

    match service::create_list(list.0, &repo, user_data).await {
        Ok(list) => HttpResponse::Ok().json(list),
        Err(err) => into_response(err),
    }
}

#[get("/{list_id}")]
async fn get_list(
    list_id: web::Path<String>,
    repo: web::Data<MongoRepo>,
    session: Session,
) -> impl Responder {
    let user_data = match get_user_data(session) {
        Ok(user_data) => user_data,
        Err(failed) => return failed,
    };

    match service::get_list(list_id.into_inner(), &repo, user_data).await {
        Ok(list) => HttpResponse::Ok().json(list),
        Err(err) => into_response(err),
    }
}

#[delete("/{list_id}")]
async fn delete_list(
    list_id: web::Path<String>,
    repo: web::Data<MongoRepo>,
    session: Session,
) -> impl Responder {
    let user_data = match get_user_data(session) {
        Ok(user_data) => user_data,
        Err(failed) => return failed,
    };

    match service::delete_list(list_id.into_inner(), &repo, user_data).await {
        Ok(_) => HttpResponse::NoContent().finish(),
        Err(err) => into_response(err),
    }
}

#[put("/{list_id}")]
async fn update_list(
    list_id: web::Path<String>,
    list: web::Json<dto::List>,
    repo: web::Data<MongoRepo>,
    session: Session,
) -> impl Responder {
    let user_data = match get_user_data(session) {
        Ok(user_data) => user_data,
        Err(failed) => return failed,
    };

    match service::update_list(list_id.into_inner(), list.0, &repo, user_data).await {
        Ok(_) => HttpResponse::NoContent().finish(),
        Err(err) => into_response(err),
    }
}

// ===== ===== HELPER ===== =====

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

fn into_response(jarvis_err: service::JarvisError) -> HttpResponse {
    match jarvis_err {
        JarvisError::InvalidData(msg) => HttpResponse::BadRequest().body(msg),
        JarvisError::NotFound => HttpResponse::NotFound().finish(),
        JarvisError::Unauthorized => HttpResponse::Unauthorized().finish(),
        JarvisError::ServerFailed => HttpResponse::InternalServerError().finish(),
    }
}
