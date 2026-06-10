#pragma once

#include "Flower.h"
#include <list>
#include <iostream>

using namespace std;

class Garden {
private:
    list<Flower> flowerList;

public:
    Garden();
    ~Garden();

    void Add(const Flower& flower);

    unsigned GetMaxHeight() const;

    Garden& operator+=(const Flower& flower);

    friend ostream& operator<<(ostream& o, const Garden& g);
};