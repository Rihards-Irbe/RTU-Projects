#pragma once

#include <string>
using namespace std;

class Plant {
protected:
    string latinName;
    string latvianName;
    unsigned heightCM;

public:
    Plant();
    Plant(string latin, string latvian, unsigned height);
    virtual ~Plant();

    virtual void Print() const;

    string getLatinName() const {
        return latinName;
    }

    string getLatvianName() const {
        return latvianName;
    }

    unsigned getHeightCM() const {
        return heightCM;
    }

    void setLatinName(string latin);
    void setLatvianName(string latvian);
    void setHeightCM(unsigned height);
};
