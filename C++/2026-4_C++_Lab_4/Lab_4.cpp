#include "Garden.h"
#include <iostream>
#include "FullListException.h"
using namespace std;

int main() {
    Garden* g = new Garden(2);

    Flower* f1 = new Flower("Rosa", "Roze", 30, "Sarkana");
    Flower  f2("Tulipa", "Tulpe", 40, "Dzeltena");

    try {
        *g += *f1;
        cout << "\nPu?e pievienota" << endl;
    }
    catch (const FullListException&) {
        cout << "max izm?rs p?rsniegts" << endl;
    }
    delete f1;

    try {
        *g += f2;
        cout << "\nPu?e pievienota" << endl;
    }
    catch (const FullListException&) {
        cout << "max izm?rs p?rsniegts" << endl;
    }

    try {
        *g += f2;
        cout << "\nPu?e pievienota" << endl;
    }
    catch (const FullListException&) {
        cout << "max izm?rs p?rsniegts" << endl;
    }

    cout << "\nNoklus?jamais max izm?rs no KLASES: "
        << Garden::GetDefaultSize() << "." << endl;
    cout << "Noklus?jamais max izm?rs no OBJEKTA: "
        << g->GetDefaultSize() << "." << endl;

    cout << *g;

    delete g;

    cin.get();
    return 0;
}