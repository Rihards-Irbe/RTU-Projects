#include <iostream>
#include <algorithm>
#include "Garden.h"

using namespace std;

Garden::Garden() {
    
}

Garden::~Garden() {
    flowerList.clear();
}

void Garden::Add(const Flower& flower) {
    flowerList.push_back(Flower(flower.getLatinName(), flower.getLatvianName(),
        flower.getHeightCM(), flower.getColor()));
}

Garden& Garden::operator+=(const Flower& flower) {
    flowerList.push_back(Flower(flower.getLatinName(), flower.getLatvianName(),
        flower.getHeightCM(), flower.getColor()));
    return *this;
}

unsigned Garden::GetMaxHeight() const {
    if (!flowerList.size())
        throw - 1;
    else
        return max_element(
            flowerList.cbegin(),
            flowerList.cend(),
            [](const Flower& a, const Flower& b) {
                return a.getHeightCM() < b.getHeightCM();
            }
        )->getHeightCM();
}

ostream& operator<<(ostream& o, const Garden& g) {
    o << "\nDārza Puķes:" << endl;
    unsigned i = 1;
    for (auto it = g.flowerList.cbegin(); it != g.flowerList.cend(); it++) {
        o << i++ << ". " << *it << endl;
    }
    return o;
}