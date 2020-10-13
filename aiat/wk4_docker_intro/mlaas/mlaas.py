from flask import Flask, request
from flask_cors import CORS, cross_origin
import os
import joblib
import numpy as np 

app = Flask(__name__)
CORS(app)

@app.route('/')
def helloworld():
    return 'Hello world: Machine Learning as a Service'

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
        return 'Setosa Flower'
    elif predict_target == 1:
        return 'Versicolor Flower'
    else:
        return 'Virginica Flower'
    

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)

