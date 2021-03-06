
from flask import Flask, request
from flask_cors import CORS, cross_origin

app = Flask(__name__)
CORS(app)

@app.route('/bmi', methods=['GET'])
@cross_origin()
def bmi():
        weight = float(request.values['weight'])
        height = float(request.values['height'])
        return str(weight / ((height/100) ** 2))

if __name__ == '__main__':
        app.run(host='0.0.0.0', port=5000, debug=False)



