from typing import Optional

import bson
import flask
from flask import Request

from jarvis.infrastructure import RequestDictionary


class ViewModelBase:
    def __init__(self):
        self.request: Request = flask.request
        self.request_dict = RequestDictionary.create('')

        self.error: Optional[str] = None
        self.user_id: Optional[bson.ObjectId] = None  # cookie_auth.get_user_id_via_auth_cookie(self.request)

    def to_dict(self):
        return self.__dict__
