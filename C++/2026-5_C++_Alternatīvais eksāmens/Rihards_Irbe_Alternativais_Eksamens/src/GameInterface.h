#pragma once
#include <afxwin.h>
#include "PlayerInterface.h"
enum class GameStatus { INITIAL, STARTING, COMPETE, GOAL, PAUSE, ENDED };

class GameInterface {
public:
	virtual GameStatus GetStatus() const = 0;
	virtual int GetTeamSize() const = 0;
	virtual void GetScore(int& l, int& r) const = 0;
	virtual void GetFieldSize(int& w, int& h) const = 0;
	virtual void GetFieldCentre(int& x, int& y) const = 0;
	virtual int GetGateWidth() const = 0;
	virtual CDC* GetFieldDC() const = 0;
	virtual void GetBallCoordinates(int& x, int& y) const = 0;
	virtual void KickBall(PlayerInterface* const pPlayer, int speed, double dir) = 0;
};