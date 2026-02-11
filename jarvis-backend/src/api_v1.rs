use std::collections::HashMap;

use axum::extract::{Path, Query};
use axum::http::StatusCode;
use axum::{routing, Json, Router};
use tower_sessions::Session;

use crate::dto::List;
use crate::service;

use crate::security::UserData;
use crate::service::{JarvisError, LoginData};
use crate::storage::MongoRepo;

pub fn api_v1(repo: MongoRepo) -> Router {
    Router::new()
        .nest("/v1/auth", auth_api(repo.clone()))
        .nest("/v1/lists", list_api(repo))
}

// ===== AUTH =====

fn auth_api(repo: MongoRepo) -> Router {
    Router::new()
        .route(
            "/login",
            routing::post(|session, login_data| login(repo, session, login_data)),
        )
        .route("/logout", routing::post(logout))
        .route("/check", routing::head(check))
}

/// POST "/login"
async fn login(repo: MongoRepo, session: Session, Json(login_data): Json<LoginData>) -> StatusCode {
    let user_data = match service::login(login_data, &repo).await {
        Ok(user_data) => user_data,
        Err(err) => {
            log::warn!("Login failed: {:?}", err);
            return into_response(err);
        }
    };

    if let Err(err) = session.insert("user", user_data).await {
        log::error!("Error while updating session: {:?}", err);
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    StatusCode::OK
}

/// POST "logout"
async fn logout(session: Session) -> StatusCode {
    let _ = session.remove::<UserData>("user").await;

    StatusCode::OK
}

/// HEAD "check"
async fn check(session: Session) -> StatusCode {
    match session.get::<UserData>("user").await {
        Ok(Some(_)) => StatusCode::OK,
        Ok(None) => StatusCode::UNAUTHORIZED,
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR,
    }
}

// ===== LIST =====

fn list_api(repo: MongoRepo) -> Router {
    let lists_repo = repo.clone();
    let create_repo = repo.clone();
    let list_repo = repo.clone();
    let delete_repo = repo.clone();
    let patch_repo = repo;

    Router::new()
        .route(
            "/",
            routing::get(move |session, query| get_lists(lists_repo, session, query)),
        )
        .route(
            "/",
            routing::post(|session, list| create_list(create_repo, session, list)),
        )
        .route(
            "/{list_id}",
            routing::get(|session, list_id| get_list(list_repo, session, list_id)),
        )
        .route(
            "/{list_id}",
            routing::delete(|session, list_id| delete_list(delete_repo, session, list_id)),
        )
        .route(
            "/{list_id}",
            routing::put(|session, path, list| update_list(patch_repo, session, path, list)),
        )
}

/// GET ""
async fn get_lists(
    repo: MongoRepo,
    session: Session,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Json<Vec<List>>, StatusCode> {
    let user_data = get_user_data(session).await?;

    let show_closed: bool = params
        .get("show_closed")
        .map(|sc| sc == "true")
        .unwrap_or(false);

    service::get_lists(&repo, show_closed, user_data)
        .await
        .map(Json)
        .map_err(into_response)
}

/// POST ""
async fn create_list(
    repo: MongoRepo,
    session: Session,
    Json(list): Json<List>,
) -> Result<Json<List>, StatusCode> {
    let user_data = get_user_data(session).await?;

    service::create_list(list, &repo, user_data)
        .await
        .map(Json)
        .map_err(into_response)
}

/// GET "/:list_id"
async fn get_list(
    repo: MongoRepo,
    session: Session,
    Path(list_id): Path<String>,
) -> Result<Json<List>, StatusCode> {
    let user_data = get_user_data(session).await?;

    service::get_list(list_id, &repo, user_data)
        .await
        .map(Json)
        .map_err(into_response)
}

/// DELETE "/{list_id}"
async fn delete_list(
    repo: MongoRepo,
    session: Session,
    Path(list_id): Path<String>,
) -> Result<StatusCode, StatusCode> {
    let user_data = get_user_data(session).await?;

    service::delete_list(list_id, &repo, user_data)
        .await
        .map(|_| StatusCode::NO_CONTENT)
        .map_err(into_response)
}

/// PUT "/{list_id}"
async fn update_list(
    repo: MongoRepo,
    session: Session,
    Path(list_id): Path<String>,
    Json(list): Json<List>,
) -> Result<StatusCode, StatusCode> {
    let user_data = get_user_data(session).await?;

    service::update_list(list_id, list, &repo, user_data)
        .await
        .map(|_| StatusCode::NO_CONTENT)
        .map_err(into_response)
}

// ===== ===== HELPER ===== =====

async fn get_user_data(session: Session) -> Result<UserData, StatusCode> {
    match session.get::<UserData>("user").await {
        Ok(Some(user_data)) => Ok(user_data),
        Ok(None) => Err(StatusCode::UNAUTHORIZED),
        Err(_) => Err(StatusCode::INTERNAL_SERVER_ERROR),
    }
}

fn into_response(jarvis_err: JarvisError) -> StatusCode {
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
