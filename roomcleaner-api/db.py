import os
from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String, Boolean, ForeignKey

db_url = os.getenv('DATABASE_URL', 'sqlite:///test.db')
engine = create_engine(db_url, convert_unicode=True)

metadata = MetaData()

Table('sensors', metadata,
    Column('id', Integer, primary_key=True),
    Column('mac', String(17), nullable=False),
    Column('motion', Boolean),
    Column('roomId', Integer, ForeignKey('rooms.id'))
)

Table('rooms', metadata,
    Column('id', Integer, primary_key=True),
    Column('googleId', String, nullable=False),
    Column('name', String, nullable=False)
)

metadata.create_all(engine)
