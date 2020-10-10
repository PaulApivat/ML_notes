from flask import Flask, request
from flask_cors import CORS, cross_origin
import joblib
import numpy as np 

app = Flask(__name__)
CORS(app)

@app.route('/')
def helloworld():
    return 'Helloworld'

# Example request: http://localhost:5000/area?w=50&h=3
@app.route('/area', methods=['GET'])
@cross_origin()
def area():
    w = float(request.values['w'])
    h = float(request.values['h'])
    return str(w * h)


# Example request: http://localhost:5000/bmi?w=50&h=180
@app.route('/bmi', methods=['GET'])
@cross_origin()
def bmi():
    weight = float(request.values['w'])
    height = float(request.values['h'])
    height = height/100
    bmi = weight/(height**2)
    return str(bmi)

# Demo in Postman (SuperAI Collections): localhost:5000/iris
@app.route('/iris', methods=['POST'])
@cross_origin()
def predict_species():
    model = joblib.load('iris.model')  #needs to be the correct path
    req = request.values['param']
    inputs = np.array(req.split(','), dtype=np.float32).reshape(1,-1)
    predict_target = model.predict(inputs)
    if predict_target == 0:
        return 'Setosa'
    elif predict_target == 1:
        return 'Versicolor'
    else:
        return 'Virginica'
    

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

