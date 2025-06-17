# server.py
import os
from livekit import api
from flask import Flask, jsonify

app = Flask(__name__)

LIVEKIT_API_KEY = "LIVEKIT_API_KEY"
LIVEKIT_API_SECRET = "LIVEKIT_API_SECRET"
LIVEKIT_URL = "LIVEKIT_URL"

@app.route('/getToken')
def getToken():
    
    from flask import request
    identity = request.args.get('identity', 'user-' + os.urandom(4).hex())
    room = request.args.get('room', 'default-room')
    name = request.args.get('name', identity)

    token = api.AccessToken(
        os.getenv('LIVEKIT_API_KEY', LIVEKIT_API_KEY), 
        os.getenv('LIVEKIT_API_SECRET', LIVEKIT_API_SECRET)
    ) \
    .with_identity(identity) \
    .with_name(name) \
    .with_grants(api.VideoGrants(
        room_join=True,
        room=room,
        room_create=True
    ))
    
    # Return both token and server URL for client configuration
    return jsonify({
        'token': token.to_jwt(),
        'url': os.getenv('LIVEKIT_URL', LIVEKIT_URL)
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
