#include "pch.h"
#include "Goalkeeper.h"

Goalkeeper::Goalkeeper(GameInterface* pG, Side s, COLORREF color) :
	Player(pG, s, color) 
{	

}

//Samainīju, lai vārsargs būtu ar baltu outlainu un burtu, lai tas atšķirtos no pārējiem spēlētājiem.
void Goalkeeper::Draw() const {
	CString num;
	num.Format(L"%d", myID);
	DrawPlayer(myColor, RGB(255, 255, 255), myRadius, num);
}

void Goalkeeper::Move() {

	//Pārbauda puses, vārsargs tikai stāv savu vārtu pusē
	if (mySide == Side::LEFT) {
		x = myRadius + 3; // Kreisie varti
	}
	else {
		x = fieldW - myRadius - 3; // Labie varti
	}

	int xb, yb;
	pGame->GetBallCoordinates(xb, yb);

	int targetY = yb;

	//Vārtsargs pārvietojās tikai vārta ierobežojumos
	if (targetY < centerPositionY - goalCenter) {
		targetY = centerPositionY - goalCenter; // Vārtu augšējais stabs
	}

	if (targetY > centerPositionY + goalCenter) {
		targetY = centerPositionY + goalCenter; // Apakšējais stabs
	}

	double distanceToTargetYLocation = CalculateDistanceBetweenPoints(x, y, x, targetY);

	//Tuvojās pie bumbas, bet tikai Y koordinātās.
	if (distanceToTargetYLocation > 0.0) {
		double distance = PLAYER_SPEED;
		if (distanceToTargetYLocation < PLAYER_SPEED) {
			distance = distanceToTargetYLocation; //lai neraustitos
		}
		y += (int)(distance * (targetY - y) / distanceToTargetYLocation);
	}

	double distanceToBall = CalculateDistanceBetweenPoints(x, y, xb, yb);

	//Ja bumba ir pārāk tuvu, tad tā tiek aizsista uz laukuma centru
	if (distanceToBall < myRadius * KICK_DISTANCE) {

		KickToTarget(centerPositionX, centerPositionY, xb, yb);
	}

	//Vārsargs drīkst sadurties ar uzbrucēju un aizsargu, tāpec šeit nav PlayerCollision()

}