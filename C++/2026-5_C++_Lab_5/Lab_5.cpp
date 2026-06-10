#include "Garden.h"
#include "FullListException.h"
#include <iostream>
using namespace std;

int main() {

    Garden<unsigned int>* uintGarden = new Garden<unsigned int>(2);

    Flower<unsigned int>* uintF1 = new Flower<unsigned int>("Rosa", "Roze", 30, "Sarkana");
    Flower<unsigned int>  uintF2("Tulipa", "Tulpe", 40, "Dzeltena");

    try {
        *uintGarden += *uintF1;
        cout << "\nPuke pievienota (unsigned int darzs)." << endl;
    }
    catch (const FullListException&) {
        cout << "max izmers parsniegs (unsigned int darzs)." << endl;
    }
    delete uintF1;

    try {
        *uintGarden += uintF2;
        cout << "\nPuke pievienota (unsigned int darzs)." << endl;
    }
    catch (const FullListException&) {
        cout << "max izmers parsniegs (unsigned int darzs)." << endl;
    }

    try {
        *uintGarden += uintF2;
        cout << "\nPuke pievienota (unsigned int darzs)." << endl;
    }
    catch (const FullListException&) {
        cout << "max izmers parsniegs (unsigned int darzs)." << endl;
    }

    cout << "\nNoklusejamais max izmers no KLASES (unsigned int): "
        << Garden<unsigned int>::GetDefaultSize() << endl;
    cout << "Noklusejamais max izmers no OBJEKTA (unsigned int): "
        << uintGarden->GetDefaultSize() << endl;
    cout << "Maksimalais augstums (unsigned int): "
        << uintGarden->GetMaxHeight() << " cm" << endl;

    uintGarden->print();

    delete uintGarden;

    cout << endl;

    // ---------------------------------------------------------------------

    Garden<unsigned long>* ulongGarden = new Garden<unsigned long>(2);

    Flower<unsigned long>* ulongF1 = new Flower<unsigned long>("Lilium", "Lilija", 60, "Balta");
    Flower<unsigned long>  ulongF2("Viola", "Violete", 20, "Violeta");

    try {
        *ulongGarden += *ulongF1;
        cout << "\nPuke pievienota (unsigned long darzs)." << endl;
    }
    catch (const FullListException&) {
        cout << "max izmers parsniegs (unsigned long darzs)." << endl;
    }
    delete ulongF1;

    try {
        *ulongGarden += ulongF2;
        cout << "\nPuke pievienota (unsigned long darzs)." << endl;
    }
    catch (const FullListException&) {
        cout << "max izmers parsniegs (unsigned long darzs)." << endl;
    }

    try {
        *ulongGarden += ulongF2;
        cout << "\nPuke pievienota (unsigned long darzs)." << endl;
    }
    catch (const FullListException&) {
        cout << "max izmers parsniegs (unsigned long darzs)." << endl;
    }

    cout << "\nNoklusejamais max izmers no KLASES (unsigned long): "
        << Garden<unsigned long>::GetDefaultSize() << endl;
    cout << "Noklusejamais max izmers no OBJEKTA (unsigned long): "
        << ulongGarden->GetDefaultSize() << endl;
    cout << "Maksimalais augstums (unsigned long): "
        << ulongGarden->GetMaxHeight() << " cm" << endl;

    //
    // ulongGarden->print();
    cout << ulongGarden;

    delete ulongGarden;

    cin.get();
    return 0;
}