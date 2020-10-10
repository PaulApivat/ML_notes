from flask import Flask, request
from flask_cors import CORS, cross_origin
import joblib
import numpy as np 

app = Flask(__name__)
CORS(app)

@app.route('/')
def helloworld():
    return 'Helloworld'

@app.route('/area', methods=['GET'])
@cross_origin()
def area():
    w = float(request.values['w'])
    h = float(request.values['h'])
    return str(w * h)


@app.route('/bmi', methods=['GET'])
@cross_origin()
def bmi():
    weight = float(request.values['w'])
    height = float(request.values['h'])
    height = height/100
    bmi = weight/(height**2)
    return str(bmi)


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

