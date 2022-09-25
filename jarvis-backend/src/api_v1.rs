use actix_session::Session;
use actix_web::body::{BoxBody, EitherBody};
use actix_web::dev::{ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::http::header::ContentType;
use actix_web::{delete, get, post, put, web, Error, HttpResponse, Responder, Scope};
use futures::stream::TryStreamExt;
use mongodb::Client;
use mongodb::{bson::doc, options::FindOptions};
use serde::Serialize;

use crate::security::AuthTransformer;

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

fn list_api() -> actix_web::Scope<
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
async fn get_lists(db_client: web::Data<Client>) -> impl Responder {
    let db = db_client.database("jarvis");
    let coll = db.collection::<List>("lists");

    let filter = doc! {};
    let find_options = FindOptions::default();
    let mut cursor = coll.find(filter, find_options).await.unwrap();

    let mut lists: Vec<List> = Vec::new();

    while let Some(list) = cursor.try_next().await.unwrap() {
        lists.push(list);
    }

    ok(lists)
}

#[post("")]
async fn create_list() -> impl Responder {
    "not_implemented"
}

#[get("/{list_id}")]
async fn get_list(_list_id: web::Path<String>) -> impl Responder {
    let list = List::new();

    ok(list)
}

#[delete("/{list_id}")]
async fn delete_list(list_id: web::Path<String>) -> impl Responder {
    format!("not_implemented: {list_id}")
}

#[put("/{list_id}")]
async fn update_list(list_id: web::Path<String>) -> impl Responder {
    format!("not_implemented: {list_id}")
}

// ===== RESPONSES =====

fn ok<T: Serialize + Sized>(data: T) -> HttpResponse {
    let json = to_json(&data);

    HttpResponse::Ok()
        .content_type(ContentType::json())
        .body(json)
}

// ===== HELPERS =====

fn to_json<T: Serialize + Sized>(list: &T) -> String {
    serde_json::to_string(list).unwrap()
}
