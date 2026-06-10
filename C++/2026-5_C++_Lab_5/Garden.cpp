#include "Garden.h"

template <class T>
Garden<T>::Garden() : max_size(DEFAULT_SIZE), size(0) {
    list = new FlowerPointer[max_size];
}