import logging
import dateutil.parser
import pprint
import httplib2
from httplib2 import Http
import os
from apiclient import discovery
import oauth2client
from oauth2client import client
from oauth2client import tools
import datetime
import requests
from oauth2client.client import SignedJwtAssertionCredentials
from apiclient.discovery import build
import base64
import time


logging.basicConfig(level=os.getenv('ROOMCLEANER_LOG_LEVEL', 'INFO'))

def _get_directory_service():
    """Gets service to query Google Directory

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        service
    """

    client_email = os.getenv('ROOMCLEANER_GOOGLE_CLIENT')
    private_key64 = os.getenv('ROOMCLEANER_GOOGLE_CLIENT_KEY')
    private_key = base64.b64decode(private_key64)
    credentials = SignedJwtAssertionCredentials(client_email, private_key, 'https://www.googleapis.com/auth/admin.directory.user')
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('admin', 'directory_v1', http=http)
    return service

def _get_service():
    """Gets service to query Google Calendar

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        service
    """

    client_email = os.getenv('ROOMCLEANER_GOOGLE_CLIENT')
    private_key64 = os.getenv('ROOMCLEANER_GOOGLE_CLIENT_KEY')
    private_key = base64.b64decode(private_key64)
    credentials = SignedJwtAssertionCredentials(client_email, private_key, 'https://www.googleapis.com/auth/calendar')
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('calendar', 'v3', http=http)
    return service


def _get_calendar_ids():
    page_token = None
    calendar_list = service.calendarList().list(pageToken=page_token).execute()
    ids = dict()
    for calendar_list_entry in calendar_list['items']:
        ids[calendar_list_entry['id'].strip()] = calendar_list_entry['summary'].strip()
    logging.debug(pp.pformat(ids))
    return ids

def _get_meeting_details(event, room, calendarId):
    start = event['start'].get('dateTime', event['start'].get('date'))
    end = event['end'].get('dateTime', event['end'].get('date'))
    logging.critical( event['organizer'])
    return {'id': event['id'], 'organizer': event['organizer'], 'startTime': start, 'endTime': end, 'room': {'name': room['displayName'],
        'email': room['email']}, 'calendarId': calendarId, 'title': event['summary']}

def _get_rooms_meetings():
    ids = _get_calendar_ids()
    current = datetime.datetime.utcnow()
    now = current.isoformat() + 'Z' # 'Z' indicates UTC time
    after10mins = current + datetime.timedelta(minutes = 1000)
    time_after10mins = after10mins.isoformat() + 'Z' # 'Z' indicates UTC time
    rooms_meetings = {}
    for id in ids.keys():
        eventsResult = service.events().list(
            calendarId=id, timeMin=now, timeMax = time_after10mins, maxResults=10, singleEvents=True,
            orderBy='startTime').execute()
        events = eventsResult.get('items', [])
        for event in events:
            if 'attendees' in event:
                for attendee in event['attendees']:
                    if attendee['email'] == id and 'resource' in attendee:
                        start = event['start'].get('dateTime', event['start'].get('date'))
                        if id in rooms_meetings:
                            rooms_meetings[ids[id]].append(_get_meeting_details(event, attendee, id))
                        else:
                            rooms_meetings[ids[id]] = [_get_meeting_details(event, attendee, id)]
    logging.debug("Rooms and meetings")
    logging.debug(pp.pformat(rooms_meetings))
    return rooms_meetings

def search_user():
      directory_service = _get_directory_service()
      results = directory_service.users().list(query='email=email@example.com',
          viewType='admin_view').execute()
      print results

def register_meetings():
    """Registers the about-to-start meetings with the free-the-conf server so that it can monitor it for activity

    Returns:
        None
    """
    rooms_meetings = _get_rooms_meetings()
    url = os.getenv('ROOMCLEANER_API_URL')
    for room in rooms_meetings.keys():
        for meeting in rooms_meetings[room]:
#            take_out_room_from_event(meeting)
            room_data = {'name': meeting['room']['name']}
            logging.debug("Making POST request to {} for room {}".format(url, meeting['room']['name']))
            logging.debug(room_data)
            r = requests.post('{}/rooms/{}'.format(url, meeting['room']['email']), room_data)
            logging.debug(r)

            startTime = int(time.mktime(dateutil.parser.parse(meeting['startTime']).timetuple())+25200)
            endTime = int(time.mktime(dateutil.parser.parse(meeting['endTime']).timetuple())+25200)
            meeting_data = {'title': meeting['title'],
                            'startTime': startTime,
                            'endTime': endTime,
                            'roomId': meeting['room']['email']}
            logging.debug("Making POST request to {} for room {} and meeting {}".format(url, room, meeting['startTime']))
            logging.debug(meeting_data)
            r = requests.post('{}/meetings/{}'.format(url, meeting['id']), data = meeting_data)
            logging.debug(r)

def _find_meeting_by_id(eventInfo):
    event = service.events().get(calendarId=eventInfo['roomId'], eventId=eventInfo['id']).execute()
    if event:
        logging.debug("Got meeting: calendarId: {}, eventId: {} and meeting: ".format(eventInfo['roomId'], eventInfo['id']))
        logging.debug(pp.pformat(event))
    return event

def take_out_room_from_event(eventInfo):
    """Updates a meeting and takes out the room resource

    Returns:
        None
    """
    event = _find_meeting_by_id(eventInfo)
    if event and 'attendees' in event:
        for attendee in event['attendees']:
            print "About to delete event, calendarId: ", eventInfo['roomId'], " and eventId: ", eventInfo['id']
            if 'resource' in attendee and attendee['email'] == eventInfo['roomId']:
                logging.debug("About to delete event, calendarId: {} and eventId: {}".format( eventInfo['roomId'], eventInfo['id']))
                service.events().delete(calendarId=eventInfo['roomId'], eventId=eventInfo['id']).execute()
                break

if __name__ == '__main__':
    raise Exception("Can't call this script directly")

pp = pprint.PrettyPrinter(indent=4)
service = _get_service()
