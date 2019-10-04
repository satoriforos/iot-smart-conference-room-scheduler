import logging
import time
import os
from urlparse import urlparse

from flask import Flask
from flask_restful import reqparse, abort, Resource, Api
from sqlalchemy import create_engine, Column, String, Integer, Boolean, ForeignKey
from sqlalchemy.orm import scoped_session, sessionmaker, relationship, column_property
from sqlalchemy.ext.declarative import declarative_base, declared_attr
from sqlalchemy.exc import IntegrityError
from redis import StrictRedis

logging.basicConfig(level=os.getenv('ROOMCLEANER_LOG_LEVEL', 'INFO'))


app = Flask(__name__)
api = Api(app)
app.debug = True

db_url = os.getenv('DATABASE_URL', 'sqlite:///test.db')
redis_url = urlparse(os.getenv('REDISTOGO_URL', 'redis://localhost:6379'))

engine = create_engine(db_url, convert_unicode=True)
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
Base = declarative_base()
Base.query = db_session.query_property()

r = StrictRedis(host=redis_url.hostname, port=redis_url.port, db=0, password=redis_url.password)

@app.teardown_request
def teardown_request(exception):
    db_session.remove()

def init_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

# Sensor Model
class Sensor(Base):
    __tablename__ = 'sensors'

    def as_dict(self):
        return {
              'id': self.id,
              'mac': self.mac,
              'room': self.room.name if self.room else None
            }

    id = Column(Integer, primary_key=True)
    mac = Column(String(17))
    motion = Column(Boolean)
    room_id = Column('roomId', Integer, ForeignKey('rooms.id'))

    room = relationship('Room', foreign_keys=[room_id])

sensor_parser = reqparse.RequestParser()
sensor_parser.add_argument('motion', type=bool)
sensor_parser.add_argument('roomId', type=int)

room_parser = reqparse.RequestParser()
room_parser.add_argument('name', type=str)

class Room(Base):
    __tablename__ = 'rooms'

    def as_dict(self):
        return {
            'id': self.id,
            'googleId': self.googleId,
            'name': self.name,
            'sensors': [s.mac for s in self.sensors]
        }

    id = Column(Integer, primary_key=True)
    googleId = Column(String)
    name = Column(String)

    sensors = relationship('Sensor')

class Person(object):
    def __init__(self, email):
        self.email = email

def person(value):
    try:
        p = Person(**value)
    except TypeError:
        # Raise a ValueError, and maybe give it a good error string
        raise ValueError("Invalid object")
    except:
        # Just in case you get more errors
        raise ValueError

    return p

class Meeting(object):
    def __init__(self, id, title, roomId, startTime,
                 endTime):
        self.id = id
        self.title = title
        self.roomId = roomId
        self.startTime = startTime
        self.endTime = endTime
#        self.organizer = organizer
#        self.attendees = attendees

    @classmethod
    def fetch(cls, meetingId):
        m = dict(r.hgetall('meeting_{}'.format(meetingId)))

        if not len(m):
            return None

        return cls(**m)

    @classmethod
    def fetch_all(cls):
        keys = r.keys('meeting_*')
        m = []
        for k in keys:
            m.append(cls.fetch(k.replace('meeting_', '')))

        print m
        return m

    def as_dict(self):
        keys = 'id title roomId startTime endTime'.split()
        return {c: getattr(self, c) for c in keys}

    def save(self):
        end = self.endTime
        now = time.time()
        diff = end - now
        logging.debug('diff is {} ({} - {})'.format(diff, end, now))
        if diff > 0:
            key = 'meeting_{}'.format(self.id)
            r.hmset(key, self.as_dict())
            r.expireat(key, end)

    def delete(self):
        key = 'meeting_{}'.format(self.id)
        r.delete(key)

class SensorView(Resource):
    def get(self, mac):
        s = Sensor.query.filter(Sensor.mac == mac).first()
        if s is not None:
            return s.as_dict()
        else:
            abort(404, message="Sensor {} doesn't exist".format(mac))

    def post(self, mac):
        args = sensor_parser.parse_args()
        s = Sensor.query.filter(Sensor.mac == mac).first()

        if s is None:
            s = Sensor()
            s.mac = mac
        elif args['roomId']:
            s.room_id = args['roomId']

        try:
            db_session.add(s)
            db_session.commit()
        except IntegrityError, exc:
            return {"error": exc.message}, 500

    def put(self, mac):
        args = sensor_parser.parse_args()
        s = Sensor.query.filter(Sensor.mac == mac).first()
        if s is not None:
            # Put motion value in Redis
            key = 'sensors_{}_motion_{}'.format(s.mac, int(time.time()))
            r.setex(key, 300, args['motion'])
            return
        else:
            abort(404, message="Sensor {} doesn't exist".format(mac))

class SensorViewList(Resource):
    def get(self):
        s = Sensor.query.all()
        results = []
        for row in s:
            results.append(row.as_dict())
        return results

class SensorMotionViewList(Resource):
    def get(self, mac):
        s = Sensor.query.filter(Sensor.mac == mac).first()
        motions = r.keys('sensors_{}_motion_*'.format(mac))
        if len(motions):
            motions_values = r.mget(m for m in motions)
            return dict(zip([m.split('_')[3] for m in motions], motions_values))
        else:
            return []

class RoomView(Resource):
    def post(self, roomId):
        room = Room.query.filter(Room.googleId == roomId).first()
        if room is None:
            args = room_parser.parse_args()
            room = Room()
            room.googleId = roomId
            room.name = args['name']
            try:
                db_session.add(room)
                db_session.commit()
            except IntegrityError, exc:
                return {"error": exc.message}, 500

class RoomListView(Resource):
    def get(self):
        rooms = Room.query.all()
        return [r.as_dict() for r in rooms]

meeting_parser = reqparse.RequestParser()
meeting_parser.add_argument('title', type=str)
meeting_parser.add_argument('roomId', type=str)
meeting_parser.add_argument('startTime', type=int)
meeting_parser.add_argument('endTime', type=int)
#meeting_parser.add_argument('organizer', type=person)
#meeting_parser.add_argument('attendees', type=person, action='append')

class MeetingView(Resource):
    def get(self, meetingId):
        m = Meeting.fetch(meetingId)
        return m.as_dict()

    def post(self, meetingId):
        m = Meeting.fetch(meetingId)
        if m is None:
            logging.debug('create a new meeting with id {}'.format(meetingId))
            args = meeting_parser.parse_args()
            n = Meeting(
                meetingId,
                title=args['title'],
                roomId=args['roomId'],
                startTime=args['startTime'],
                endTime=args['endTime'],
#                organizer=args['organizer'],
#                attendees=args['attendees']
            )
            n.save()
        else:
            logging.debug('meeting {} already exists'.format(meetingId))

    def delete(self, meetingId):
        m = Meeting.fetch(meetingId)
        m.delete()

class MeetingViewList(Resource):
    def get(self):
        meetings = Meeting.fetch_all()
        return [m.as_dict() for m in meetings]

api.add_resource(SensorViewList, '/sensors')
api.add_resource(SensorView, '/sensors/<string:mac>')
api.add_resource(SensorMotionViewList, '/sensors/<string:mac>/motions')
api.add_resource(RoomListView, '/rooms')
api.add_resource(RoomView, '/rooms/<string:roomId>')
api.add_resource(MeetingViewList, '/meetings')
api.add_resource(MeetingView, '/meetings/<string:meetingId>')

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host=os.getenv('API_HOST', '0.0.0.0'), port=port, debug=True)
