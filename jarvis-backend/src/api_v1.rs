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
    session
        .insert("user_id", "affa0db4-20d3-4c4a-a643-313aa0473bc6")
        .unwrap();

    "not_implemented"
}

#[post("/logout")]
async fn logout() -> impl Responder {
    "not_implemented"
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
    let lists = repo.find_all_lists().await;

    HttpResponse::Ok().json(lists)
}

#[post("")]
async fn create_list(list: web::Json<List>, repo: web::Data<MongoRepo>) -> impl Responder {
    let list = repo.insert_list(list.into_inner()).await;

    HttpResponse::Ok().json(list)
}

#[get("/{list_id}")]
async fn get_list(list_id: web::Path<String>, repo: web::Data<MongoRepo>) -> impl Responder {
    let id = ObjectId::parse_str(list_id.into_inner()).unwrap();
    let list = repo.find_by_id(id).await;

    if let Some(list) = list {
        HttpResponse::Ok().json(list)
    } else {
        HttpResponse::NotFound().finish()
    }
}

#[delete("/{list_id}")]
async fn delete_list(list_id: web::Path<String>, repo: web::Data<MongoRepo>) -> impl Responder {
    let id = ObjectId::parse_str(list_id.into_inner()).unwrap();

    if let Err(err) = repo.delete_by_id(id).await {
        log::error!("Error while deleting list {}: {:?}", id, err)
    }

    HttpResponse::NoContent().finish()
}

#[put("/{list_id}")]
async fn update_list(_list_id: web::Path<String>) -> impl Responder {
    HttpResponse::NoContent().finish()
}
