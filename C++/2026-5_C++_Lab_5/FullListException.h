#pragma once
#include <iostream>
using namespace std;

class FullListException {
public:
    FullListException() {
        cout << endl << "FullListException created!" << endl;
    }
    FullListException(const FullListException&) {
        cout << "FullListException copied!" << endl;
    }
    ~FullListException() {
        cout << "FullListException finished!" << endl;
    }
};