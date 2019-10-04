=== install

```
brew install redis
brew install python
pip install --upgrade pip
pip install virtualenvwrapper
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> ~/.bash_profile
source /usr/local/bin/virtualenvwrapper.sh
cd ~/projects
git clone http://github.com:satoriforos/iot-smart-conference-room-scheduler.git
cd roomcleaner-api
mkvirtualenv roomcleaner-api
workon roomcleaner-api
pip install -r requirements.txt

export ROOMCLEANER_GOOGLE_CLIENT=<redacted>
export ROOMCLEANER_GOOGLE_CLIENT_KEY=<redacted> # Note: the value is the result of `base64 --wrap=0 key.p12`
export ROOMCLEANER_API_URL=http://example.com/
```

=== use

```
$ gunicorn roomcleaner:app
$ python register_rooms.py
$ python update_meeting.py
```
