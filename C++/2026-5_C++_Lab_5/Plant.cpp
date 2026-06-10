#include "Plant.h"

template <class T>
Plant<T>::Plant() : latinName("Unknown"), latvianName("Nezinams"), heightCM(0) {
    cout << "Izveidots noklusejamais Plant objekts." << endl;
}