use actix_web::{delete, get, HttpResponse, post, put, Responder, Scope, web};
use actix_web::http::header::ContentType;
use actix_session::Session;
use serde::Serialize;

use super::model::List;

pub fn api_v1() -> Scope {
    web::scope("/v1")
        .service(auth_api())
        .service(user_api())
}

// ===== AUTH =====

fn auth_api() -> Scope {
    web::scope("/auth")
        .service(login)
        .service(logout)
}

#[post("/login")]
async fn login(session: Session) -> impl Responder {
    session.insert("user_id", "affa0db4-20d3-4c4a-a643-313aa0473bc6").unwrap();

    "not_implemented"
}

#[post("/logout")]
async fn logout() -> impl Responder {
    "not_implemented"
}

// ===== LIST =====

fn user_api() -> Scope {
    web::scope("/lists")
        .service(get_lists)
        .service(create_list)
        .service(get_list)
        .service(delete_list)
        .service(update_list)
}

#[get("")]
async fn get_lists() -> impl Responder {
    let lists = vec![List::new()];

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

fn ok<T: Serialize + Sized>(data: T) -> HttpResponse {
    let json = to_json(&data);

    HttpResponse::Ok()
        .content_type(ContentType::json())
        .body(json)
}

fn to_json<T: Serialize + Sized>(list: &T) -> String {
    serde_json::to_string(list).unwrap()
}
