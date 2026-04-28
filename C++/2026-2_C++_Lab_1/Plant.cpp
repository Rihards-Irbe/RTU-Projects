#include <iostream>
#include "Plant.h"

using namespace std;

Plant::Plant() : latinName("Unknown"), latvianName("Nezināms"), heightCM(0) {
    cout << "Izveidots noklusējamais Plant objekts." << endl;
}

Plant::Plant(string latin, string latvian, unsigned height): latinName(latin), latvianName(latvian), heightCM(height) {
    cout << "Izveidots Plant objekts: " << latvianName << endl;
}

Plant::~Plant() {
    cout << "Plant objekts '" << latvianName << "' tiek izdzēsts." << endl;
}

void Plant::Print() const {
    cout << "Nosaukums latīņu valodā: " << latinName << endl;
    cout << "Nosaukums latviešu valodā: " << latvianName << endl;
    cout << "Augstums (cm): " << heightCM << endl;
}

void Plant::setLatinName(string latin) {
    latinName = latin;
}

void Plant::setLatvianName(string latvian) {
    latvianName = latvian;
}

void Plant::setHeightCM(unsigned height) {
    heightCM = height;
}
