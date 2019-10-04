=== install

```
pip install --upgrade pip
pip install virtualenvwrapper
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> ~/.bash_profile
source /usr/local/bin/virtualenvwrapper.sh
cd ~/projects
git clone http://github.com:satoriforos/iot-smart-conference-room-scheduler.git
cd google-calendar-plugin
Get client_secret.p12
mkvirtualenv google-calendar-plugin
workon google-calendar-plugin
pip install -r requirements.txt
pip install PyOpenSSL
pip install requests
pip install gdata
pip install --upgrade google-api-python-client
```

=== use

```
python register_rooms.py or update_meeting.py
```
