import datetime

import sqlalchemy as sa
import sqlalchemy.orm as orm

from jarvis.data.modelbase import SqlAlchemyBase


class User(SqlAlchemyBase):
    __tablename__ = 'users'

    id = sa.Column(sa.BigInteger, primary_key=True, autoincrement=True)
    inserted_at = sa.Column(sa.DateTime, default=datetime.datetime.now)
    updated_at = sa.Column(sa.DateTime, default=datetime.datetime.now)

    name = sa.Column(sa.String, nullable=False)
    email = sa.Column(sa.String, nullable=False, index=True)
    password_hash = sa.Column(sa.String, nullable=False)
    default_language = sa.Column(sa.String, default='en')

    # OAuth2
    provider = sa.Column(sa.String, default='jarvis')
    token = sa.Column(sa.String)

    created_groups = orm.relation('UserGroup', back_populates='UserGroup')
