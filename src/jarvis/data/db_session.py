import logging
import os

import sqlalchemy as sa
import sqlalchemy.orm as orm


factory = None
logger = logging.getLogger(os.path.basename(__file__))


def global_init(user: str, password: str, host: str, port: int, db_name: str):
    global factory

    if factory:
        return

    conn_str = 'postgresql+psycopg2://{user}:{password}@{host}:{port}/{db_name}'
    conn_str = conn_str.format(
        user=user, password=password, host=host, port=port, db_name=db_name
    )
    logger.debug('Connect to {}'.format(conn_str))
    engine = sa.create_engine(conn_str, echo=(logger.level == logging.DEBUG))
    factory = orm.sessionmaker(bind=engine)
