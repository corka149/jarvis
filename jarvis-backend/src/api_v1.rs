use actix_session::Session;
use actix_web::body::{BoxBody, EitherBody};
use actix_web::dev::{ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::{delete, get, post, put, web, Error, HttpResponse, Responder, Scope};
use mongodb::bson::oid::ObjectId;

use crate::security::AuthTransformer;
use crate::MongoRepo;

use super::model::List;

pub fn api_v1() -> Scope {
    web::scope("/v1").service(auth_api()).service(list_api())
}

// ===== AUTH =====

fn auth_api() -> Scope {
    web::scope("/auth").service(login).service(logout)
}

#[post("/login")]
async fn login(session: Session) -> impl Responder {
    if let Err(err) = session.insert("user_id", "affa0db4-20d3-4c4a-a643-313aa0473bc6") {
        log::error!("Could not add user id to session: {:?}", err);
        return HttpResponse::InternalServerError().finish();
    }

    HttpResponse::Ok().finish()
}

#[post("/logout")]
async fn logout(session: Session) -> impl Responder {
    session.purge();

    HttpResponse::Ok().finish()
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

#[get("")]
async fn get_lists(repo: web::Data<MongoRepo>) -> impl Responder {
    match repo.find_all_lists().await {
        Ok(lists) => HttpResponse::Ok().json(lists),
        Err(err) => {
            log::error!("Could not get lists: {:?}", err);
            HttpResponse::InternalServerError().finish()
        }
    }
}

#[post("")]
async fn create_list(list: web::Json<List>, repo: web::Data<MongoRepo>) -> impl Responder {
    match repo.insert_list(list.into_inner()).await {
        Ok(list) => HttpResponse::Ok().json(list),
        Err(err) => {
            log::error!("Creating list failed: {:?}", err);
            HttpResponse::InternalServerError().finish()
        }
    }
}

#[get("/{list_id}")]
async fn get_list(list_id: web::Path<String>, repo: web::Data<MongoRepo>) -> impl Responder {
    let id = match ObjectId::parse_str(list_id.into_inner()) {
        Ok(id) => id,
        Err(_err) => return HttpResponse::BadRequest().finish(),
    };

    match repo.find_by_id(id).await {
        Ok(Some(list)) => HttpResponse::Ok().json(list),
        Ok(None) => HttpResponse::NotFound().finish(),
        Err(err) => {
            log::error!("Could not get list: {:?}", err);
            HttpResponse::InternalServerError().finish()
        }
    }
}

#[delete("/{list_id}")]
async fn delete_list(list_id: web::Path<String>, repo: web::Data<MongoRepo>) -> impl Responder {
    let id = match ObjectId::parse_str(list_id.into_inner()) {
        Ok(id) => id,
        Err(_err) => return HttpResponse::BadRequest().finish(),
    };

    if let Err(err) = repo.delete_by_id(id).await {
        log::error!("Error while deleting list {}: {:?}", id, err)
    }

    HttpResponse::NoContent().finish()
}

#[put("/{list_id}")]
async fn update_list(
    list_id: web::Path<String>,
    list: web::Json<List>,
    repo: web::Data<MongoRepo>,
) -> impl Responder {
    let id = match ObjectId::parse_str(list_id.into_inner()) {
        Ok(id) => id,
        Err(_err) => return HttpResponse::BadRequest().finish(),
    };

    if let Err(err) = repo.update_list(id, list.into_inner()).await {
        log::error!("Could not update list: {:?}", err);
        return HttpResponse::InternalServerError().finish();
    }

    HttpResponse::NoContent().finish()
}
