#pragma once
#include "Player.h"

class Defender :public Player {
public:
	Defender(GameInterface* pG, Side s, COLORREF color);
	void Move() override;

};