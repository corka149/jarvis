from __future__ import annotations
# Credits goes to Michael Kennedy for response, RequestDictionary, create

from functools import wraps

import flask
import werkzeug
import werkzeug.wrappers
from werkzeug.datastructures import MultiDict


def response(*, mimetype: str = None, template_file: str = None):
    """
    Wrapper for rendering templates

    :param mimetype:
    :param template_file:
    :return: rendered template
    """
    def response_inner(f):

        @wraps(f)
        def view_method(*args, **kwargs):
            response_val = f(*args, **kwargs)

            if isinstance(response_val, werkzeug.wrappers.Response):
                return response_val

            if isinstance(response_val, flask.Response):
                return response_val

            if isinstance(response_val, dict):
                model = dict(response_val)
            else:
                model = dict()

            if template_file and not isinstance(response_val, dict):
                raise Exception(
                    "Invalid return type {}, we expected a dict as the return value.".format(type(response_val)))

            if template_file:
                response_val = flask.render_template(template_file, **response_val)

            resp = flask.make_response(response_val)
            resp.model = model
            if mimetype:
                resp.mimetype = mimetype

            return resp

        return view_method

    return response_inner


class RequestDictionary(dict):
    """
    Contains all request details from URL query, headers, forms and route args
    """

    def __init__(self, *args, default_val=None, **kwargs):
        self.default_val = default_val
        super().__init__(*args, **kwargs)

    def __getattr__(self, key):
        return self.get(key, self.default_val)

    @staticmethod
    def create(default_val=None, **route_args) -> RequestDictionary:
        """ Creates a RequestDictionary """
        request = flask.request

        args = request.args
        if isinstance(request.args, MultiDict):
            args = request.args.to_dict()

        form = request.form
        if isinstance(request.form, MultiDict):
            form = request.form.to_dict()

        data = {
            **args,  # The key/value pairs in the URL query string
            **request.headers,  # Header values
            **form,  # The key/value pairs in the body, from a HTML post form
            **route_args  # And additional arguments the method access, if they want them merged.
        }

        return RequestDictionary(data, default_val=default_val)
