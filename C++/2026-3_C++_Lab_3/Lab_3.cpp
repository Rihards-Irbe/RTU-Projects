#include "Garden.h"
#include <iostream>
#include "FullListException.h"

using namespace std;

int main() {
    Garden g(2);

    Flower f1("Rosa", "Roze", 30, "Sarkana");
    Flower f2("Tulipa", "Tulpe", 40, "Dzeltena");
    Flower f3("Lilium", "Lilija", 50, "Balta");
    try {


        g.Add(f1);
        g.Add(f2);

        //kļūda
        g.Add(f3);

    }
    catch (const FullListException&) {
        cout << "Error: maximal size exceeded!" << endl;
    }

    Garden g2;

    g2.Add(Flower("Rosa", "Roze", 30, "Sarkana"));
    g2.Add(Flower("Tulipa", "Tulpe", 45, "Dzeltena"));
    g2.Add(Flower("Lilium", "Lilija", 50, "Balta"));

    g2.Print();

    cout << "Augstākā puķe: " << g2.GetMaxHeight() << " cm" << endl;

    return 0;
}