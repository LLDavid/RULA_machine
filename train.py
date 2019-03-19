from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation, BatchNormalization
#import keras
import numpy as np
import glob
from sklearn.model_selection import train_test_split
from sklearn.utils import class_weight
from scipy.io import savemat, loadmat
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix, precision_score
#import tensorflow as tf
def read_all_txt(*argv):
    """

    :param txt_dir: directory of txt file
    :return:
    """
    all_data=[]
    txt_path_all=argv[0]+"*.txt"
    txt_path_list=glob.glob(txt_path_all)
    if len(argv)>1:
        for f in txt_path_list:
            data = np.loadtxt(f, delimiter=',')
            all_data.append(data)
        all_data = np.array(all_data)
        xx = all_data[0]
        for i in range(1, len(txt_path_list)):
            xx = np.concatenate((xx, all_data[i]), axis=0)
    else:
        for f in txt_path_list:
            data = np.loadtxt(f)
            all_data.append(data)
        all_data = np.array(all_data)
        xx = all_data[0]
        for i in range(1, len(txt_path_list)):
            xx = np.concatenate((xx, all_data[i]), axis=0)
    return xx

def Indices2OneHot(class_indices):
    class_indices = class_indices.astype(int)
    max_i=np.max(class_indices)+1
    class_labels=np.zeros([np.size(class_indices,0),max_i])
    for i in range(np.size(class_indices,0)):
        class_labels[i][class_indices[i]]=1
    #class_indices = class_indices.astype(int)
    return class_labels

def data_aug(x_train, y_train):
    ## count original types
    n_classes=len(y_train[0,:])
    type_count=[0]* n_classes
    for i in range(np.size(x_train, 0)):
        type_count[np.argmax(y_train[i,:])] += 1
    print("count:", type_count)
    ## augmentation
    add_count=[0, 10, 10 , 10, 9, 10]
    x_new=np.empty((1,8))
    y_new=np.empty((1,n_classes))
    for i in range(np.size(x_train, 0)):
        x_new=np.vstack((x_new, x_train[i, :]))
        y_new=np.vstack((y_new, y_train[i, :]))
        for j in range(add_count[np.argmax(y_train[i, :])]):
            x_new = np.vstack((x_new, x_train[i, :]+np.random.normal(0, 2, (1, 8))))
            y_new = np.vstack((y_new, y_train[i, :]))
    ## count augmented types
    type_count=[0]*n_classes
    for i in range(np.size(x_new, 0)):
        type_count[np.argmax(y_new[i, :])] += 1
    print("count:", type_count)
    return x_new, y_new

## Load data
txt_path1=r"./skel_17_all.txt"
txt_path2=r"./gscore_merge.txt"
skel_17=np.loadtxt(txt_path1, delimiter=",")
gscore_merge=np.loadtxt(txt_path2)
gscore_merge=np.reshape(gscore_merge, (527599,1)) # total number of samples

## number of class
n_class=7

## split data
x_train, x_test, y_train, y_test = train_test_split(skel_17, gscore_merge, test_size=0.2, random_state=0)
print(x_train.shape, x_test.shape, y_train.shape, y_test.shape)

## Convert to one hot
y_train  = Indices2OneHot(y_train -1)
print(y_train.shape)

## build network
model=Sequential()
model.add(Dense(1024, input_shape=(34,)))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(Dropout(0.1))

model.add(Dense(1024))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(Dropout(0.1))

model.add(Dense(1024))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(Dropout(0.1))

model.add(Dense(n_class, activation='softmax'))
model.add(BatchNormalization())
model.add(Activation('softmax'))

model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'], )

## train
train_rec=model.fit(x_train, y_train,
       nb_epoch=100, batch_size=2000, validation_split=0.2)

## test
probabilities = model.predict(x_test)
predictions = np.argmax(probabilities, axis=-1)+1

## print result
print(classification_report(y_test, predictions))
print(confusion_matrix(y_test, predictions))
#savemat('result.mat', {'pred': predictions, 'gt': y_test})
