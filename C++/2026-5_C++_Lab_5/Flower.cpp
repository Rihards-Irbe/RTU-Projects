#include <iostream>
#include "Flower.h"

using namespace std;

template <class T>
Flower<T>::Flower() : Plant<T>(), color("unknown") {
    cout << "Izveidots noklusejamais Flower objekts." << endl;
}