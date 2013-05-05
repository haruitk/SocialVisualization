from sklearn import svm, metrics, cross_validation, tree
from sklearn.naive_bayes import GaussianNB
import numpy as np
import os

#function to run 10 cross validation
def evaluate(clf,X,Y):
	#applying 10 fold cross validation.	
	#clf is the classifier, X is the feature vector, Y is the classification vector
	scores = cross_validation.cross_val_score(clf,X,Y,cv=10)
	print(scores)


#read data from CSV file
#TODO: type in the path to the spambase.data file on your local filesystem
path = os.path.join(os.getcwd(),"spambase.data")
f=open(path)
data=np.loadtxt(f,delimiter=",") #using comma as the delimiter since it's a CSV file


#assigning the training and testing indices: The first 57 indices are features, and the 58th is the classification.
X=data[:,0:56] #feature vector
Y=data[:,57]   #classification vector


#SVM
print("SVM:\n")
clf = svm.SVC()
evaluate(clf,X,Y)
#TODO: Instantiate an SVM classifier and call the evaluate function passing the classifer, X and Y as the parameters


#Decision Tree
print("Decision Tree:\n")
clf = tree.DecisionTreeClassifier()
evaluate(clf,X,Y)
#TODO: Instantiate a decision tree classifier and call the evaluate function passing the classifier, X and Y as the parameters



#Naive Bayes
print("Naive Bayes:\n")
clf = GaussianNB()
evaluate(clf,X,Y)
#TODO: Instantiate a Naive Bayes classifier and call the evaluate function passing the classifier, X and Y as the parameters