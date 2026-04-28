//9. Variants (Plant)

#include <iostream>
#include "Plant.h"
#include "Flower.h"

using namespace std;

int main() {

    Plant* plants = new Plant[2];

    plants[0] = Plant("Rosa", "Roze", 30);
    plants[1] = Plant("Tulipa", "Tulpe", 40);

    for (int i = 0; i < 2; i++) {
        plants[i].Print();
        cout << endl;
    }

    delete[] plants;

    cout << "===============" << endl;

    Plant* arr[3];

    arr[0] = new Plant("Rosa", "Roze", 30);
    arr[1] = new Flower("Tulipa", "Tulpe", 40, "Dzeltena");
    arr[2] = new Flower("Rosa", "Roze", 35, "Sarkana");

    for (int i = 0; i < 3; i++) {
        arr[i]->Print();
        cout << endl;
    }

    for (int i = 0; i < 3; i++) {
        delete arr[i];
    }

    return 0;
}
