#pragma once

#include "Flower.h"

class Garden {
private:
    Flower** list;
    unsigned int max_size;
    unsigned int size;

    static const unsigned int DEFAULT_SIZE = 5;

public:
    Garden();
    Garden(unsigned size);
    ~Garden();

    static unsigned GetDefaultSize();

    void Add(const Flower& flower);
    void Print() const;

    unsigned GetMaxHeight() const;
};