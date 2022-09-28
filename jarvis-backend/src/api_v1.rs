use actix_session::Session;
use actix_web::body::{BoxBody, EitherBody};
use actix_web::dev::{ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::web::Json;
use actix_web::{delete, get, post, put, web, Either, Error, HttpResponse, Responder, Scope};
use futures_util::StreamExt;
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

    Json(lists)
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
            // return Err(error::ErrorBadRequest("overflow"));
        }
        body.extend_from_slice(&chunk);
    }

    // body is loaded, now we can deserialize serde-json
    let list = serde_json::from_slice::<List>(&body).unwrap();

    let list = repo.insert_list(list).await;

    Json(list)
}

#[get("/{list_id}")]
async fn get_list(
    list_id: web::Path<String>,
    repo: web::Data<MongoRepo>,
) -> Either<Json<List>, HttpResponse> {
    let id = ObjectId::parse_str(list_id.into_inner()).unwrap();
    let list = repo.find_by_id(id).await;

    if let Some(list) = list {
        Either::Left(Json(list))
    } else {
        Either::Right(HttpResponse::NotFound().finish())
    }
}

#[delete("/{list_id}")]
async fn delete_list(list_id: web::Path<String>) -> impl Responder {
    format!("not_implemented: {list_id}")
}

#[put("/{list_id}")]
async fn update_list(list_id: web::Path<String>) -> impl Responder {
    format!("not_implemented: {list_id}")
}
