#include <iostream>
#include "Flower.h"

using namespace std;

Flower::Flower() : Plant(), color("unknown") {
    cout << "Izveidots noklus?jamais Flower objekts." << endl;
}

Flower::Flower(string latin, string latvian, unsigned height, string color) : Plant(latin, latvian, height), color(color) {
    cout << "Izveidots Flower objekts ar kr?su: " << color << endl;
}

Flower::~Flower() {
    cout << "Flower objekts ar kr?su '" << color << "' tiek izdz?sts." << endl;
}

void Flower::setColor(string color) {
    this->color = color;
}

string Flower::getColor() const {
    return color;
}

/*void Flower::Print() const {
    cout << *this;
}
*/

ostream& operator<<(ostream& o, const Flower& f) {
    o << static_cast<const Plant&>(f) << endl;
    o << "Flower kr?sa: " << f.color;
    return o;
}
