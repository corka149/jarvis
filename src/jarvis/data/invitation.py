import datetime
import sqlalchemy as sa
import sqlalchemy.orm as orm

from jarvis.data.modelbase import SqlAlchemyBase


class Invitation(SqlAlchemyBase):
    __tablename__ = 'invitations'

    id = sa.Column(sa.BigInteger, primary_key=True, autoincrement=True)
    inserted_at = sa.Column(sa.DateTime, default=datetime.datetime.now)
    updated_at = sa.Column(sa.DateTime, default=datetime.datetime.now)
    invitee_email = sa.Column(sa.String, nullable=False)

    host_id = sa.Column(sa.BigInteger, sa.ForeignKey('users.id',
                                                     name='invitations_host_id_fkey'),
                        nullable=False, index=True)
    host = orm.relation('User')

    invitee_id = sa.Column(sa.BigInteger, sa.ForeignKey('users.id',
                                                        name='invitations_invitee_id_fkey'),
                           index=True)
    invitee = orm.relation('User')

    usergroup_id = sa.Column(sa.BigInteger, sa.ForeignKey('usergroups.id',
                                                          name='invitations_usergroup_id_fkey'))
