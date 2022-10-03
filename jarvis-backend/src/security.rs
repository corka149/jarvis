use std::future::{ready, Ready};

use crate::configuration;
use actix_session::storage::CookieSessionStore;
use actix_session::{SessionExt, SessionMiddleware};
use actix_web::body::EitherBody;
use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error, HttpResponse,
};
use futures_util::future::LocalBoxFuture;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct UserData {
    user_uuid: String,
    organization_id: String,
}

impl UserData {
    // TODO get data from user model
    pub fn new() -> Self {
        Self {
            user_uuid: "a57999c1-d24d-40f4-8efd-04321b5e4cdb".to_string(),
            organization_id: "c69b364a-5cf1-49e0-93bd-b7fc1dc99122".to_string(),
        }
    }
}

// There are two steps in middleware processing.
// 1. Middleware initialization, middleware factory gets called with
//    next service in chain as parameter. (transformer trait)
// 2. Middleware's call method gets called with normal request.
//    (service trait=
pub struct AuthTransformer;

// Middleware factory is `Transform` trait
// `S` - type of the next service
// `B` - type of response's body
impl<S, B> Transform<S, ServiceRequest> for AuthTransformer
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type Transform = AuthMiddleware<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(AuthMiddleware { service }))
    }
}

// ^
// Response & error should be the same
// v

pub struct AuthMiddleware<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for AuthMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    // Called for every request
    fn call(&self, request: ServiceRequest) -> Self::Future {
        // Request
        let session = request.get_session();

        return if let Ok(Some(_user)) = session.get::<UserData>("user") {
            let fut = self.service.call(request);

            // Success Response
            Box::pin(async move {
                let res: ServiceResponse<B> = fut.await?;
                Ok(res.map_into_left_body())
            })
        } else {
            let response = HttpResponse::Unauthorized().finish().map_into_right_body();
            let (request, _pl) = request.into_parts();

            // Failure Response
            Box::pin(async { Ok(ServiceResponse::new(request, response)) })
        };
    }
}

// ===== Sessions =====

pub fn new_session_store(
    config: &configuration::Security,
) -> SessionMiddleware<CookieSessionStore> {
    let secret_key = config.get_key();
    let session_store = CookieSessionStore::default();
    SessionMiddleware::new(session_store, secret_key)
}
