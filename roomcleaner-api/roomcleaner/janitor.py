from roomcleaner import google
import logging
import requests
import time
import json
import pprint
import os
import datetime

pp = pprint.PrettyPrinter(indent=4)
url = os.getenv('ROOMCLEANER_API_URL', 'http://localhost:8000')

def _get_rooms_sensors():
    response = requests.get('{}/rooms'.format(url))
    dict = {}
    if response and response.status_code == requests.codes.ok:
        rooms = json.loads(response.text)
        logging.debug("Rooms and sensors json")
        logging.debug(pp.pprint(rooms))
        if rooms:
            for room in rooms:
                if 'googleId' in room and 'sensors' in room and room['sensors']:
                    dict[room['googleId']] = room['sensors']
    logging.debug("Rooms and sensors returns")
    logging.debug(pp.pprint(dict))
    return dict

def _no_motion_in_sensor(sensorId):
    response = requests.get('{}/sensors/{}/motions'.format(url, sensorId))
    if response and response.status_code == requests.codes.ok:
        sensor_data = json.loads(response.text)
        # logging.debug("Sensor data for ", sensorId, " is")
        # logging.debug(pp.pprint(sensor_data))
        print "Sensor data for ", sensorId, " is ", pp.pprint(sensor_data)
        if sensor_data:
            for key, elem in sensor_data.iteritems():
                print "key: ", key, " and value: ", elem
            noMotion = all(elem == False or elem == 'None' for key, elem in sensor_data.iteritems())
            return noMotion
        else:
            # logging.debug("No sensor data for ", sensorId)
            print "No sensor data for ", sensorId
            return False
    else:
        # logging.debug("No data for sensor ", sensorId)
        print logging.debug("No data for sensor ", sensorId)
        return False

def check_and_eject():
    now = datetime.datetime.now() + datetime.timedelta(hours = 1)
    # Let's get the meeting schedules that we are monitoring
    response = requests.get('{}/meetings'.format(url))
    if response and response.status_code == requests.codes.ok:
        meetings = json.loads(response.text)
        # logging.debug("meetings json: ")
        # logging.debug(pp.pprint(meetings))
        print "Meetings json: ", pp.pprint(meetings), "done"
        if meetings:
            rooms_sensors = _get_rooms_sensors()
            for meeting in meetings:
                # logging.debug("Meeting: ")
                # logging.debug(pp.pprint(meeting))
                if 'startTime' in meeting and 'endTime' in meeting and 'roomId' in meeting and meeting['roomId'] in rooms_sensors:
                    start_time = datetime.datetime.fromtimestamp(int(meeting['startTime']))
                    end_time = datetime.datetime.fromtimestamp(int(meeting['endTime']))
                    print "Now: ", now, " meeting startTime: ", start_time, " and endTime: ", end_time, " and meeting: ", meeting
                    if True:
                        # now < end_time and now > start_time + datetime.timedelta(minutes = 5):
                        # Got the sensors for the room, let's get the sensor data from Redis and check
                        logging.debug("*** Yes, roomId is present {} and sensors in that room: {}".format(meeting['roomId'], rooms_sensors[meeting['roomId']]))

                        noMotion = all(_no_motion_in_sensor(elem) for elem in rooms_sensors[meeting['roomId']])
                        if noMotion:
                            # logging.debug("No motion detected in room: ", meeting['roomId'])
                            print "****** No motion detected in room: ", meeting['roomId']
                            try:
                                google.take_out_room_from_event(meeting)
                            except Exception as e:
                                logging.warn('google failed. or us... {}'.format(str(e)))
                            requests.delete('{}/meetings/{}'.format(url, meeting['id']))
                        else:
                            # logging.debug("Motion detected in room: ", meeting['roomId'])
                            print "Motion detected in room: ", meeting['roomId']
    else:
        logging.debug("No meetings are scheduled, nothing to do")

def main():
    check_and_eject()

if __name__ == '__main__':
    raise Exception("Can't call this script directly")
