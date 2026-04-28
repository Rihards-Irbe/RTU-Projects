#include <iostream>
#include "Garden.h"
#include "FullListException.h"

using namespace std;

Garden::Garden() {
    max_size = DEFAULT_SIZE;
    size = 0;
    list = new Flower * [max_size];
}

Garden::Garden(unsigned size) {

    max_size = size;
    size = 0;
    list = new Flower * [max_size];
}

Garden::~Garden() {

    for (unsigned i = 0; i < size; i++) {
        delete list[i];
    }
    delete[] list;
}

unsigned Garden::GetDefaultSize() {
    return DEFAULT_SIZE;
}

void Garden::Add(const Flower& flower) {

    if (size >= max_size) {
        throw FullListException();
    }

    list[size] = new Flower(flower);
    size++;
}

void Garden::Print() const {

    for (unsigned i = 0; i < size; i++) {
        list[i]->Print();
        cout << endl;
    }
}

unsigned Garden::GetMaxHeight() const {

    unsigned max = list[0]->getHeightCM();

    for (unsigned i = 1; i < size; i++) {
        if (list[i]->getHeightCM() > max) {
            max = list[i]->getHeightCM();
        }
    }

    return max;
}