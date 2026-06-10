#include "Garden.h"
#include <iostream>

using namespace std;

int main() {
    Garden* g = new Garden();

    Flower* f1 = new Flower("Rosa", "Roze", 30, "Sarkana");
    Flower  f2("Tulipa", "Tulpe", 40, "Dzeltena");
    Flower  f3("Lilium", "Lilija", 60, "Balta");

    try {
        *g += *f1;
        cout << "\nPu?e pievienota" << endl;
    }
    catch (...) {
        cout << "K??da!" << endl;
    }

    delete f1;

    try {
        *g += f2;
        cout << "\nPu?e pievienota" << endl;
    }
    catch (...) {
        cout << "K?uda" << endl;
    }

    try {
        *g += f3;
        cout << "\nPu?e pievienota" << endl;
    }
    catch (...) {
        cout << "K??da!" << endl;
    }

    cout << *g;

    try {
        cout << "\nVisaugst?k? pu?e d?rz?: " << g->GetMaxHeight() << " cm." << endl;
    }
    catch (int) {
        cout << "Saraksts ir tukšs!" << endl;
    }

    cout << "\nD?rza dz?šana:";
    delete g;

    cin.get();
    return 0;
}