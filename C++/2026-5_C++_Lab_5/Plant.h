#pragma once

#include <string>
#include <iostream>
using namespace std;

template <class T>
class Plant {
protected:
    string latinName;
    string latvianName;
    T heightCM;

public:
    Plant();
    Plant(string latin, string latvian, T height);
    virtual ~Plant();

    string getLatinName() const { return latinName; }
    string getLatvianName() const { return latvianName; }
    T getHeightCM() const { return heightCM; }

    void setLatinName(string latin);
    void setLatvianName(string latvian);
    void setHeightCM(T height);

    virtual void print() const;
};

template <class T>
Plant<T>::Plant(string latin, string latvian, T height)
    : latinName(latin), latvianName(latvian), heightCM(height) {
    cout << "Izveidots Plant objekts: " << latvianName << endl;
}

template <class T>
Plant<T>::~Plant() {
    cout << "Plant objekts '" << latvianName << "' tiek izdzests." << endl;
}

template <class T>
void Plant<T>::setLatinName(string latin) { latinName = latin; }

template <class T>
void Plant<T>::setLatvianName(string latvian) { latvianName = latvian; }

template <class T>
void Plant<T>::setHeightCM(T height) { heightCM = height; }

template <class T>
void Plant<T>::print() const {
    cout << "Nosaukums latinu valoda: " << latinName << endl;
    cout << "Nosaukums latviesu valoda: " << latvianName << endl;
    cout << "Augstums (cm): " << heightCM;
}