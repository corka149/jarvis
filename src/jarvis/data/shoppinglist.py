import datetime
from typing import List

import sqlalchemy as sa
import sqlalchemy.orm as orm

from jarvis.data.item import Item
from jarvis.data.modelbase import SqlAlchemyBase


class ShoppingList(SqlAlchemyBase):
    __tablename__ = 'shoppinglists'

    id = sa.Column(sa.BigInteger, primary_key=True, autoincrement=True)
    inserted_at = sa.Column(sa.DateTime, default=datetime.datetime.now)
    updated_at = sa.Column(sa.DateTime, default=datetime.datetime.now)

    done = sa.Column(sa.Boolean, default=False)
    planned_for = sa.Column(sa.Date, index=True)

    user_id = sa.Column(sa.BigInteger,
                        sa.ForeignKey('users.id', name='shoppinglists_creator_fkey'),
                        name='creator', index=True)
    user = orm.relation('User')

    user_group_id = sa.Column(sa.BigInteger,
                              sa.ForeignKey('usergroups.id', name='shoppinglists_belongs_to_fkey'),
                              name='belongs_to', index=True)
    user_group = orm.relation('UserGroup')

    items: List[Item] = orm.relation('Item')

