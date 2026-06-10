#pragma once
#include "Player.h"

class Attacker :public Player {
protected:
	const int SAFE_MARGIN = 1;
	int topPost;
	int bottomPost;
public:
	Attacker(GameInterface* pG, Side s, COLORREF color);
	void Move() override;
};