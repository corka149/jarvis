use std::collections::HashMap;

use axum::extract::{Path, Query};
use axum::http::StatusCode;
use axum::{routing, Json, Router};
use axum_sessions::extractors::{ReadableSession, WritableSession};

use crate::dto::List;
use crate::service;

use crate::security::UserData;
use crate::service::{JarvisError, LoginData};
use crate::storage::MongoRepo;

pub fn api_v1_a(repo: MongoRepo) -> Router {
    Router::new()
        .nest("/auth", auth_api_a(repo.clone()))
        .nest("/lists", list_api_a(repo))
}

// ===== AUTH =====

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

/// POST "logout"
async fn logout_a(mut session: WritableSession) -> StatusCode {
    session.remove("user");

    StatusCode::OK
}

/// HEAD "check"
async fn check_a(session: ReadableSession) -> StatusCode {
    match session.get::<UserData>("user") {
        Some(_) => StatusCode::OK,
        None => StatusCode::UNAUTHORIZED,
    }
}

// ===== LIST =====

fn list_api_a(repo: MongoRepo) -> Router {
    let lists_repo = repo.clone();
    let create_repo = repo.clone();
    let list_repo = repo.clone();
    let delete_repo = repo.clone();
    let patch_repo = repo;

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

    service::get_lists(&repo, show_closed, user_data)
        .await
        .map(Json)
        .map_err(into_response_a)
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
        .map(Json)
        .map_err(into_response_a)
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
        .map(Json)
        .map_err(into_response_a)
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

// ===== ===== HELPER ===== =====

fn get_user_data_a(session: ReadableSession) -> Result<UserData, StatusCode> {
    match session.get::<UserData>("user") {
        Some(user_data) => Ok(user_data),
        None => Err(StatusCode::UNAUTHORIZED),
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
