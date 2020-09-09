import datetime

import sqlalchemy as sa
import sqlalchemy.orm as orm

from jarvis.data.modelbase import SqlAlchemyBase


class UserGroup(SqlAlchemyBase):
    __tablename__ = 'usergroups'

    id = sa.Column(sa.BigInteger, primary_key=True, autoincrement=True)
    inserted_at = sa.Column(sa.DateTime, default=datetime.datetime.now)
    updated_at = sa.Column(sa.DateTime, default=datetime.datetime.now)

    name = sa.Column(sa.String, nullable=False, index=True)

    user_id = sa.Column(sa.BigInteger, sa.ForeignKey('users.id'))
    user = orm.relation('User')
