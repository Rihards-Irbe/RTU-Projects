#pragma once

#include <string>
#include <iostream>
#include "Plant.h"
using namespace std;

template <class T>
class Flower : public Plant<T> {
private:
    string color;

public:
    Flower();
    Flower(string latin, string latvian, T height, string color);
    virtual ~Flower();

    void setColor(string color);
    string getColor() const;

    virtual void print() const;
};

template <class T>
Flower<T>::Flower(string latin, string latvian, T height, string color)
    : Plant<T>(latin, latvian, height), color(color) {
    cout << "Izveidots Flower objekts ar krasu: " << color << endl;
}

template <class T>
Flower<T>::~Flower() {
    cout << "Flower objekts ar krasu '" << color << "' tiek izdzests." << endl;
}

template <class T>
void Flower<T>::setColor(string color) { this->color = color; }

template <class T>
string Flower<T>::getColor() const { return color; }

template <class T>
void Flower<T>::print() const {
    Plant<T>::print();
    cout << endl << "Krasa: " << color;
}