import datetime

import sqlalchemy as sa
import sqlalchemy.orm as orm

from jarvis.data.modelbase import SqlAlchemyBase


class Item(SqlAlchemyBase):
    __tablename__ = 'items'

    id = sa.Column(sa.BigInteger, primary_key=True, autoincrement=True)
    inserted_at = sa.Column(sa.DateTime, default=datetime.datetime.now)
    updated_at = sa.Column(sa.DateTime, default=datetime.datetime.now)

    name = sa.Column(sa.String, nullable=False)
    amount = sa.Column(sa.BigInteger, nullable=False)

    shopping_list_id = sa.Column(sa.BigInteger,
                                 sa.ForeignKey('shoppinglists.id',
                                               name='items_shopping_list_id_fkey'))
    shopping_list = orm.relation('ShoppingList')
