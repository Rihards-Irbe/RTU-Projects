#pragma once

#include <iostream>
#include "Flower.h"
#include "FullListException.h"
using namespace std;

template <class T>
class Garden {
private:
    typedef Flower<T>* FlowerPointer;
    FlowerPointer* list;

    static const unsigned int DEFAULT_SIZE = 5;
    unsigned int max_size;
    unsigned int size;

public:
    Garden();
    Garden(unsigned int sz);
    ~Garden();

    static unsigned int GetDefaultSize();
    unsigned int GetMaxSize() const;
    unsigned int GetSize() const;

    void Add(const Flower<T>& flower);
    Garden<T>& operator+=(const Flower<T>& flower);

    T GetMaxHeight() const;

    void print() const;
};

template <class T>
Garden<T>::Garden(unsigned int sz) : max_size(sz), size(0) {
    list = new FlowerPointer[max_size];
}

template <class T>
Garden<T>::~Garden() {
    for (unsigned int i = 0; i < size; i++)
        delete list[i];
    delete[] list;
}

template <class T>
unsigned int Garden<T>::GetDefaultSize() { return DEFAULT_SIZE; }

template <class T>
unsigned int Garden<T>::GetMaxSize() const { return max_size; }

template <class T>
unsigned int Garden<T>::GetSize() const { return size; }

template <class T>
void Garden<T>::Add(const Flower<T>& flower) {
    if (size >= max_size)
        throw FullListException();
    list[size++] = new Flower<T>(flower);
}

template <class T>
Garden<T>& Garden<T>::operator+=(const Flower<T>& flower) {
    if (size >= max_size)
        throw FullListException();
    list[size++] = new Flower<T>(flower);
    return *this;
}

template <class T>
T Garden<T>::GetMaxHeight() const {
    T max = list[0]->getHeightCM();
    for (unsigned int i = 1; i < size; i++) {
        if (list[i]->getHeightCM() > max)
            max = list[i]->getHeightCM();
    }
    return max;
}

template <class T>
void Garden<T>::print() const {
    cout << "\nDarza Pukes:" << endl;
    for (unsigned int i = 0; i < size; i++) {
        cout << (i + 1) << ". ";
        list[i]->print();
        cout << endl;
    }
}