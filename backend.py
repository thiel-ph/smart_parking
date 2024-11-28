from flask import Flask, request, jsonify

app = Flask(__name__)

# In-memory storage for the parking status
parking_status = {"isOccupied": False}

# Endpoint to receive status updates from Android app
@app.route('/parking/status', methods=['POST'])
def update_parking_status():
    data = request.json
    if "isOccupied" in data:
        parking_status["isOccupied"] = data["isOccupied"]
        return jsonify({"success": True, "message": "Status updated successfully"}), 200
    else:
        return jsonify({"success": False, "message": "Invalid data"}), 400

# Endpoint to provide current parking status
@app.route('/parking/status', methods=['GET'])
def get_parking_status():
    return jsonify(parking_status), 200

if __name__ == '__main__':
    app.run(debug=True)