use mongodb::bson::oid::ObjectId;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::dto;

use crate::model::Email;
use crate::security::UserData;
use crate::storage::MongoRepo;

use super::model::List;

#[derive(Error, Debug)]
pub enum JarvisError {
    #[error("Unexpected data")]
    InvalidData(String),
    #[error("Requested data is unknown")]
    NotFound,
    #[error("Action not allowed")]
    Unauthorized,
    #[error("Jarvis failed")]
    ServerFailed,
}

// ===== AUTH =====

#[derive(Serialize, Deserialize)]
pub struct LoginData {
    email: String,
    password: String,
}

pub async fn login(login_data: LoginData, repo: &MongoRepo) -> Result<UserData, JarvisError> {
    log::info!("Login attempt for email: {}", login_data.email);

    let email = Email::from(&login_data.email);

    let email = match email {
        Ok(email) => email,
        Err(err) => return Err(JarvisError::InvalidData(err.to_string())),
    };

    let user = match repo.find_user_by_email(&email).await {
        Ok(Some(user)) => user,
        Ok(None) => return Err(JarvisError::Unauthorized),
        Err(err) => {
            log::error!("Error while fetching user by email: {:?}", err);
            return Err(JarvisError::ServerFailed);
        }
    };

    match bcrypt::verify(&login_data.password, &user.password) {
        Ok(true) => {}
        Ok(false) => return Err(JarvisError::Unauthorized),
        Err(err) => {
            log::error!("Error while verifying password: {:?}", err);
            return Err(JarvisError::ServerFailed);
        }
    };

    Ok(UserData::new(&user))
}

// ===== LIST =====

pub async fn get_lists(
    repo: &MongoRepo,
    show_closed: bool,
    user_data: UserData,
) -> Result<Vec<dto::List>, JarvisError> {
    match repo.find_all_lists(user_data, show_closed).await {
        Ok(lists) => {
            let mut dtos: Vec<dto::List> = Vec::new();

            for list in lists {
                let dto: dto::List = list.into();
                dtos.push(dto)
            }

            Ok(dtos)
        }
        Err(err) => {
            log::error!("Could not get lists: {:?}", err);
            Err(JarvisError::ServerFailed)
        }
    }
}

pub async fn create_list(
    list: dto::List,
    repo: &MongoRepo,
    user_data: UserData,
) -> Result<dto::List, JarvisError> {
    let mut model: List = list.into();
    model.deleted = Some(false);

    match repo.insert_list(model, user_data).await {
        Ok(list) => {
            let dto: dto::List = list.into();
            Ok(dto)
        }
        Err(err) => {
            log::error!("Creating list failed: {:?}", err);
            Err(JarvisError::ServerFailed)
        }
    }
}

pub async fn get_list(
    list_id: String,
    repo: &MongoRepo,
    user_data: UserData,
) -> Result<dto::List, JarvisError> {
    let id = match ObjectId::parse_str(list_id) {
        Ok(id) => id,
        Err(err) => return Err(JarvisError::InvalidData(err.to_string())),
    };

    match repo.find_list_by_id(id, user_data).await {
        Ok(Some(list)) => {
            let dto: dto::List = list.into();
            Ok(dto)
        }
        Ok(None) => Err(JarvisError::NotFound),
        Err(err) => {
            log::error!("Could not get list: {:?}", err);
            Err(JarvisError::ServerFailed)
        }
    }
}

pub async fn delete_list(
    list_id: String,
    repo: &MongoRepo,
    user_data: UserData,
) -> Result<(), JarvisError> {
    let id = match ObjectId::parse_str(list_id) {
        Ok(id) => id,
        Err(err) => return Err(JarvisError::InvalidData(err.to_string())),
    };

    if let Err(err) = repo.delete_list_by_id(id, user_data).await {
        log::error!("Error while deleting list {}: {:?}", id, err)
    }

    Ok(())
}

pub async fn update_list(
    list_id: String,
    list: dto::List,
    repo: &MongoRepo,
    user_data: UserData,
) -> Result<(), JarvisError> {
    let id = match ObjectId::parse_str(list_id) {
        Ok(id) => id,
        Err(err) => return Err(JarvisError::InvalidData(err.to_string())),
    };

    let model: List = list.into();

    if let Err(err) = repo.update_list(id, model, user_data).await {
        log::error!("Could not update list: {:?}", err);
        return Err(JarvisError::ServerFailed);
    }

    Ok(())
}
