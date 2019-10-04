from flask import (Flask, request, jsonify, send_from_directory)
import json

app = Flask(__name__)


@app.route('/sensors', methods = ['POST', 'GET'])
def ajax_request():
    app.logger.info(dir(request))
    app.logger.info("Got: {0}".format(request.data))
    return jsonify({'status':'OK'})

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')
