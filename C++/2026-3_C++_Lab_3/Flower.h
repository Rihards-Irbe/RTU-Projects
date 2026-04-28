#pragma once

#include <string>
#include "Plant.h"

using namespace std;

class Flower : public Plant {
private:
    string color;

public:
    Flower();
    Flower(string latin, string latvian, unsigned height, string color);
    virtual ~Flower();

    void setColor(string color);
    string getColor() const;

    virtual void Print() const;
};