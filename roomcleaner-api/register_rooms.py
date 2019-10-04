from roomcleaner import google, janitor
import time

def main():
    while True:
        google.register_meetings()
        janitor.main()
        time.sleep(5)
        print 'sleep 5 sec'

if __name__ == '__main__':
    main()
