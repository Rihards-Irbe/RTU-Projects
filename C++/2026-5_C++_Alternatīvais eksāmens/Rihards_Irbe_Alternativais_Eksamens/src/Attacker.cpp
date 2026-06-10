#include "pch.h"
#include "Attacker.h"

Attacker::Attacker(GameInterface* pG, Side s, COLORREF color) :
	Player(pG, s, color)
{
	//Šīs vērtības tiek pielietotas random y koordināšu sišanā.
	topPost = centerPositionY - goalCenter + SAFE_MARGIN;
	bottomPost = centerPositionY + goalCenter - SAFE_MARGIN;
}

void Attacker::Move() {

	bool nearEdge = false;

	int xb, yb, targetGoal, targetY, distanceFromEdge = 2;
	pGame->GetBallCoordinates(xb, yb);

	//Parbauda vai attackers ir tuvuma pie malas, pievienoju, jo ir bugs, kur attackers iesitis bumbu stūri un iesprūdīs
	if (x < myRadius * distanceFromEdge || x > fieldW - myRadius * distanceFromEdge || y < myRadius * distanceFromEdge || y > fieldH - myRadius * distanceFromEdge) {
		nearEdge = true;
	}

	//Lēnām virzās uz laukumu centru
	if (nearEdge) {
		x += (int)(0.1 * (centerPositionX - x));
		y += (int)(0.1 * (centerPositionY - y));
		ClampToField();
		return;
	}

	double distanceToBall = CalculateDistanceBetweenPoints(x, y, xb, yb);

	//Parbauda vai bumba ir sitiena attāluma
	if (distanceToBall < myRadius * KICK_DISTANCE) {
		if (mySide == Side::LEFT) {
			targetGoal = fieldW; // labie varti
		}
		else {
			targetGoal = 0; // kreisie varti
		}

		/*
		Izvelejos ģeneret random skaitli, kas izvēlēsies no vārtu augsas - drosibas koeficients līdz
		vartu apakšai - drošības koeficients lai sistu pa vārtiem, nevis sist pa vartu centra koordinatu
		*/
		
		targetY = GenerateRandomNumber(topPost, bottomPost);

		KickToTarget(targetGoal, targetY, xb, yb);
	}
	else {

		//Ja bumba ir pārāk tālu priekš sišanas tad vienkārši skrien tai pakal
		double dx = xb - x;
		double dy = yb - y;
		if (distanceToBall > 0.1) {
			x += (int)(PLAYER_SPEED * dx / distanceToBall);
			y += (int)(PLAYER_SPEED * dy / distanceToBall);
		}

	}

	//Pārbauda vai nav saskriešanās ar komandas biedriem
	PlayerCollision();

}