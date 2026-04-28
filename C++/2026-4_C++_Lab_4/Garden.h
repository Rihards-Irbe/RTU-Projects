#pragma once

#include "Flower.h"
#include <iostream>

class Garden {
private:
    Flower** list;
    unsigned int max_size;
    unsigned int size;

    static const unsigned int DEFAULT_SIZE = 5;

public:
    Garden();
    Garden(unsigned sz);
    ~Garden();

    static unsigned GetDefaultSize();

    void Add(const Flower& flower);
    //void Print() const;

    unsigned GetMaxHeight() const;

    Garden& operator+=(const Flower& flower);

    friend ostream& operator<<(ostream& o, const Garden& g);
};