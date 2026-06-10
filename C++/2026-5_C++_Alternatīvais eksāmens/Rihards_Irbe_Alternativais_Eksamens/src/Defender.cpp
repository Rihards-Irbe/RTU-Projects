#include "pch.h"
#include "Defender.h"

/*
Statiskie mainīgie, kurus pielietoju lai trackotu, kur atrodās aizsargi, lai viņus pēc rīcības
aisvestu atpakaļ uz savām pozīcijām
*/
static int def4_X = 0;
static int def4_Y = 0;
static int def5_X = 0;
static int def5_Y = 0;

Defender::Defender(GameInterface* pG, Side s, COLORREF color) :
	Player(pG, s, color)
{
	//Šī laukuma centra pozīcija ir vajadzīga, lai aprēķinātu kur nepieciešams aizvest aizsargus
	centerPositionX = fieldW / 2;
}

void Defender::Move() {

	int xb, yb, targetGoal;
	pGame->GetBallCoordinates(xb, yb);

	double distanceToBall = CalculateDistanceBetweenPoints(x, y, xb, yb);

	//Šeit tracko abus aizsargus, katram ir sava x, y vērtība
	if (myID == 4) {
		def4_X = x; def4_Y = y;
	}
	else if (myID == 5) {
		def5_X = x; def5_Y = y;
	}

	//Parbauda vai bumba ir sitiena attāluma
	if (distanceToBall < myRadius * KICK_DISTANCE) {

		if (mySide == Side::LEFT) {
			targetGoal = fieldW; // labie varti
		}
		else {
			targetGoal = 0; //kreisie
		}

		KickToTarget(targetGoal, centerPositionY, xb, yb);

	}
	else {
		//pārbaude vai bumba ir iekš laikuma
		bool isBallInsideField = false;
		if (mySide == Side::LEFT && xb < centerPositionX) {
			isBallInsideField = true;
		}
		else if (mySide == Side::RIGHT && xb > centerPositionX) {
			isBallInsideField = true;
		}

		//Tikai ja bumba ir iekš laukuma tad jāiet tai pakaļ
		if (isBallInsideField) {
			double dx = xb - x;
			double dy = yb - y;

			x += (int)(PLAYER_SPEED * dx / distanceToBall);
			y += (int)(PLAYER_SPEED * dy / distanceToBall);
		}
		else {
			//Ja bumba nav iekš laukuma tad aprēķinu kur jāatrodās aizsargiem
			int targetX, targetY;
			if (mySide == Side::LEFT) {
				targetX = (fieldW / 4) / 2;
			}
			else {
				targetX = fieldW - ((fieldW / 4) / 2);
			}

			//Viens vārtsargs atrodās augšā un otrs apakšā
			if (myID == 4) {
				targetY = centerPositionY + 40;
			}
			else if (myID == 5) {
				targetY = centerPositionY - 40;
			}

			double distanceToTarget = CalculateDistanceBetweenPoints(x, y, targetX, targetY);

			//Vārtsargi aiziet uz savām pozīcijām
			if (distanceToTarget > 0.0) {
				double step = PLAYER_SPEED;
				if (distanceToTarget < PLAYER_SPEED) {
					step = distanceToTarget; //Šis ir nepieciešams lai aizsargi neraustītos
				}
				x += (int)(step * (targetX - x) / distanceToTarget);
				y += (int)(step * (targetY - y) / distanceToTarget);
			}
		}

		//Pārbauda vai nav saskriešanās ar komandas biedriem
		PlayerCollision();
	}

}