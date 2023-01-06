use std::error::Error;
use std::fmt::{Debug, Display, Formatter};
use std::io;

/// An error that can only be thrown inside jARVIS
#[derive(Debug)]
pub struct JarvisError {
    reason: String,
}

impl JarvisError {
    pub fn new(reason: String) -> Self {
        Self { reason }
    }
}

impl Display for JarvisError {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "JarvisError{{reason: {}}}", self.reason)
    }
}

impl From<io::Error> for JarvisError {
    fn from(io_err: io::Error) -> Self {
        let msg = io_err.to_string();
        Self::new(msg)
    }
}

impl Error for JarvisError {}
