Last login: Sat Oct 10 13:34:52 on ttys001
(base) paulapivat@Pauls-MacBook ~ % ls
2018			Music			data_baby_boy_j_j.png
Applications		Pictures		data_science_R
Desktop			Postman			diet_data
Documents		Public			diet_data.zip
Downloads		Rplot.png		opt
Dropbox			Rprof.out		scikit_learn_data
Library			Zotero			testdir
Movies			baby names.pdf
(base) paulapivat@Pauls-MacBook ~ % cd Desktop/RCode/ML_notes
(base) paulapivat@Pauls-MacBook ML_notes % ls
R		README.md	aiat		hands_on_ml
(base) paulapivat@Pauls-MacBook ML_notes % cd aiat
(base) paulapivat@Pauls-MacBook aiat % ls
python				wk2_hypothesis_testing
wk2_bagging_ensemble_methods	wk3_homework
wk2_classical_ml		wk3_tensor_flow
wk2_eval_measure		wk4_docker
wk2_homework			wk4_superai_api
(base) paulapivat@Pauls-MacBook aiat % cd wk4_docker
(base) paulapivat@Pauls-MacBook wk4_docker % ls
bmi-api			node-bulletin-board	test
(base) paulapivat@Pauls-MacBook wk4_docker % cd bmi-api
(base) paulapivat@Pauls-MacBook bmi-api % nano App.py

  GNU nano 2.0.6               File: App.py                           Modified  

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





^G Get Help  ^O WriteOut  ^R Read File ^Y Prev Page ^K Cut Text  ^C Cur Pos
^X Exit      ^J Justify   ^W Where Is  ^V Next Page ^U UnCut Text^T To Spell
