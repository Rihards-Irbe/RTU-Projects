#pragma once
#include "Player.h"

class Goalkeeper :public Player {
public:
	Goalkeeper(GameInterface* pG, Side s, COLORREF color);
	void Draw() const override;
	void Move() override;
};