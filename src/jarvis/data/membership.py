import sqlalchemy as sa

from jarvis.data.modelbase import SqlAlchemyBase


class Membership(SqlAlchemyBase):
    __tablename__ = 'users_usergroups'

    id = sa.Column(sa.BigInteger, primary_key=True, autoincrement=True)

    user_id = sa.Column(sa.BigInteger,
                        sa.ForeignKey('users.id', name='users_usergroups_user_id_fkey'),
                        nullable=False, index=True)
    user_group_id = sa.Column(sa.BigInteger,
                              sa.ForeignKey('usergroups.id', name='users_usergroups_user_group_id_fkey'),
                              nullable=False, index=True)
