use actix_session::Session;
use actix_web::body::{BoxBody, EitherBody};
use actix_web::dev::{ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::web::Json;
use actix_web::{delete, get, post, put, web, Error, HttpResponse, Responder, Scope};
use futures_util::StreamExt;
use mongodb::bson::oid::ObjectId;

use crate::security::AuthTransformer;
use crate::MongoRepo;

use super::model::List;

const ERROR_CONTENT_TO_BIG: &str = "0a903e62-3588-44fb-8e7a-37edfa176382";

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

const MAX_SIZE: usize = 262_144; // max payload size is 256k

#[post("")]
async fn create_list(mut payload: web::Payload, repo: web::Data<MongoRepo>) -> impl Responder {
    // payload is a stream of Bytes objects
    let mut body = web::BytesMut::new();

    while let Some(chunk) = payload.next().await {
        let chunk = chunk.unwrap();
        // limit max size of in-memory payload
        if (body.len() + chunk.len()) > MAX_SIZE {
            return HttpResponse::BadRequest().body(ERROR_CONTENT_TO_BIG);
        }
        body.extend_from_slice(&chunk);
    }

    // body is loaded, now we can deserialize serde-json
    let list = serde_json::from_slice::<List>(&body).unwrap();

    let list = repo.insert_list(list).await;

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
