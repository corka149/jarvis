use actix_session::Session;
use actix_web::body::{BoxBody, EitherBody};
use actix_web::dev::{ServiceFactory, ServiceRequest, ServiceResponse};
use actix_web::{delete, get, head, post, put, web, Error, HttpResponse, Responder, Scope};
use std::collections::HashMap;

use axum::extract::{Path, Query};
use axum::http::StatusCode;
use axum::{routing, Json, Router};
use axum_sessions::extractors::{ReadableSession, WritableSession};

use serde::Deserialize;

use crate::dto::List;
use crate::{dto, service};

use crate::security::{AuthTransformer, UserData};
use crate::service::{JarvisError, LoginData};
use crate::storage::MongoRepo;

pub fn api_v1() -> Scope {
    web::scope("/v1").service(auth_api()).service(list_api())
}

pub fn api_v1_a(repo: MongoRepo) -> Router {
    Router::new()
        .nest("/auth", auth_api_a(repo.clone()))
        .nest("/lists", list_api_a(repo))
}

// ===== AUTH =====

fn auth_api() -> Scope {
    web::scope("/auth")
        .service(login)
        .service(logout)
        .service(check)
}

fn auth_api_a(repo: MongoRepo) -> Router {
    Router::new()
        .route(
            "login",
            routing::post(|session, login_data| login_a(repo, session, login_data)),
        )
        .route("logout", routing::post(logout_a))
        .route("check", routing::head(check_a))
}

/// POST "/login"
async fn login_a(
    repo: MongoRepo,
    mut session: WritableSession,
    Json(login_data): Json<LoginData>,
) -> StatusCode {
    let user_data = match service::login(login_data, &repo).await {
        Ok(user_data) => user_data,
        Err(err) => return into_response_a(err),
    };

    if let Err(err) = session.insert("user", user_data) {
        log::error!("Error while updating session: {:?}", err);
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    StatusCode::OK
}

#[post("/login")]
async fn login(
    login_data: web::Json<LoginData>,
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

/// POST "logout"
async fn logout_a(mut session: WritableSession) -> StatusCode {
    session.remove("user");

    StatusCode::OK
}

#[post("/logout")]
async fn logout(session: Session) -> impl Responder {
    session.purge();

    HttpResponse::Ok().finish()
}

/// HEAD "check"
async fn check_a(session: ReadableSession) -> StatusCode {
    match session.get::<UserData>("user") {
        Some(_) => StatusCode::OK,
        None => StatusCode::UNAUTHORIZED,
    }
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

fn list_api_a(repo: MongoRepo) -> Router {
    let lists_repo = repo.clone();
    let create_repo = repo.clone();
    let list_repo = repo.clone();
    let delete_repo = repo.clone();
    let patch_repo = repo.clone();

    Router::new()
        .route(
            "",
            routing::get(move |session, query| get_lists_a(lists_repo, session, query)),
        )
        .route(
            "",
            routing::post(|session, list| create_list_a(create_repo, session, list)),
        )
        .route(
            "/:list_id",
            routing::get(|session, list_id| get_list_a(list_repo, session, list_id)),
        )
        .route(
            "/:list_id",
            routing::delete(|session, list_id| delete_list_a(delete_repo, session, list_id)),
        )
        .route(
            "/:list_id",
            routing::put(|session, path, list| update_list_a(patch_repo, session, path, list)),
        )
}

#[derive(Debug, Deserialize)]
struct GetListsQuery {
    show_closed: Option<bool>,
}

/// GET ""
async fn get_lists_a(
    repo: MongoRepo,
    session: ReadableSession,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Json<Vec<List>>, StatusCode> {
    let user_data = get_user_data_a(session)?;

    let show_closed: bool = params
        .get("show_closed")
        .map(|sc| sc == "true")
        .unwrap_or(false);

    let lists = service::get_lists(&repo, show_closed, user_data)
        .await
        .map_err(into_response_a)?;

    Ok(Json(lists))
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

/// POST ""
async fn create_list_a(
    repo: MongoRepo,
    session: ReadableSession,
    Json(list): Json<List>,
) -> Result<Json<List>, StatusCode> {
    let user_data = get_user_data_a(session)?;

    service::create_list(list, &repo, user_data)
        .await
        .map(|l| Json(l))
        .map_err(into_response_a)
}

#[post("")]
async fn create_list(
    list: web::Json<List>,
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

/// GET "/:list_id"
async fn get_list_a(
    repo: MongoRepo,
    session: ReadableSession,
    Path(list_id): Path<String>,
) -> Result<Json<List>, StatusCode> {
    let user_data = get_user_data_a(session)?;

    service::get_list(list_id, &repo, user_data)
        .await
        .map(|l| Json(l))
        .map_err(into_response_a)
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

/// DELETE "/{list_id}"
async fn delete_list_a(
    repo: MongoRepo,
    session: ReadableSession,
    Path(list_id): Path<String>,
) -> Result<StatusCode, StatusCode> {
    let user_data = get_user_data_a(session)?;

    service::delete_list(list_id, &repo, user_data)
        .await
        .map(|_| StatusCode::NO_CONTENT)
        .map_err(into_response_a)
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

/// PUT "/{list_id}"
async fn update_list_a(
    repo: MongoRepo,
    session: ReadableSession,
    Path(list_id): Path<String>,
    Json(list): Json<List>,
) -> Result<StatusCode, StatusCode> {
    let user_data = get_user_data_a(session)?;

    service::update_list(list_id, list, &repo, user_data)
        .await
        .map(|_| StatusCode::NO_CONTENT)
        .map_err(into_response_a)
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

fn get_user_data_a(session: ReadableSession) -> Result<UserData, StatusCode> {
    match session.get::<UserData>("user") {
        Some(user_data) => Ok(user_data),
        None => Err(StatusCode::UNAUTHORIZED),
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

fn into_response_a(jarvis_err: service::JarvisError) -> StatusCode {
    match jarvis_err {
        JarvisError::InvalidData(msg) => {
            log::warn!("Received invalid data: {}", msg);
            StatusCode::BAD_REQUEST
        }
        JarvisError::NotFound => StatusCode::NOT_FOUND,
        JarvisError::Unauthorized => StatusCode::UNAUTHORIZED,
        JarvisError::ServerFailed => StatusCode::INTERNAL_SERVER_ERROR,
    }
}
