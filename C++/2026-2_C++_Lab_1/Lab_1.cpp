//9. Variants (Plants)

#include <iostream>
#include "Plant.h"

using namespace std;

int main() {

    Plant plant1("Rosa", "Roze", 30);
    plant1.Print();

    Plant* plant2 = new Plant();

    plant2->Print();
    plant2->setLatinName("Tulipa");
    plant2->setLatvianName("Tulpe");
    plant2->setHeightCM(50);

    plant2->Print();

    cout << "Rozes latīņu nosaukums: " << plant1.getLatinName() << endl;
    cout << "Tulpes augstums: " << plant2->getHeightCM() << " cm" << endl;

    delete plant2;
    return 0;
}
