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

def _get_service():
    """Gets service to query Google Calendar

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        service
    """

    client_email = '137076483756-82erouomnh0c0smn1olc0h27ggeu9lv3@developer.gserviceaccount.com' # XXX TODO
    with open("client_secret.p12") as f:
        private_key = f.read()
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
    pp.pprint(ids)
    return ids

def _get_meeting_details(event, room, calendarId):
    start = event['start'].get('dateTime', event['start'].get('date'))
    end = event['end'].get('dateTime', event['end'].get('date'))
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
    print "Rooms and meetings", pp.pprint(rooms_meetings)
    return rooms_meetings

def register_resources():
    """Registers the about-to-start meetings with the free-the-conf server so that it can monitor it for activity

    Returns:
        None
    """
    rooms_meetings = _get_rooms_meetings()
    url = 'http://localhost:18622' # XXX TODO
    for room in rooms_meetings.keys():
        for meeting in rooms_meetings[room]:
#            take_out_room_from_event(meeting)
            print "Making POST request to ", url, " for room ", room, " and meeting ", meeting['startTime']
            r = requests.post(url, data = meeting)

def _find_meeting_by_id(eventInfo):
    event = service.events().get(calendarId=eventInfo['calendarId'], eventId=eventInfo['id']).execute()
    if event:
        print "Got meeting: calendarId: ", eventInfo['calendarId'], ", eventId: ", eventInfo['id'], " and meeting: ", pp.pprint(event)
    return event

def take_out_room_from_event(eventInfo):
    """Updates a meeting and takes out the room resource

    Returns:
        None
    """
    event = _find_meeting_by_id(eventInfo)
    if event and 'attendees' in event:
        for attendee in event['attendees']:
            if 'resource' in attendee and attendee['email'] == eventInfo['room']['email']:
                print "About to delete event, calendarId: ", eventInfo['calendarId'], " and eventId: ", eventInfo['id']
                service.events().delete(calendarId=eventInfo['calendarId'], eventId=eventInfo['id']).execute()
                break

if __name__ == '__main__':
    raise Exception("Can't call this script directly")
pp = pprint.PrettyPrinter(indent=4)
service = _get_service()
