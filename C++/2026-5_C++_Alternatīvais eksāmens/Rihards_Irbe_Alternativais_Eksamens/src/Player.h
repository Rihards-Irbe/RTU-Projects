#pragma once
#include "GameInterface.h"
#include "PlayerInterface.h"

class Player : public PlayerInterface {
protected:
	int x, y;
	int myRadius = 7; //kopējais diametrs 14
	Side mySide; //komandas puse left vai right
	int myID; // spelētāja numurs
	COLORREF myColor; // Spēlētāja krāsa
	GameInterface* pGame; //Rādītājs piekļuvai spēles simulācijas metodēm
	CDC* pFieldDC; //Rādītājs uz Device Context priekš zīmēšanas

	const int PLAYER_SPEED = 20; //Pašu spēlētāju ātrums
	const int KICK_SPEED = 30; //Bumbas ātrums pēc sitiena
	const int KICK_DISTANCE = 2; //Koeficients sitiena attāluma noteikšanai
	const int PLAYER_DISTANCE = 30; //Minimālais attālums starp spēlētājiem, šis vajadzīgs priekš izvairīšanos

	int fieldW; //Laukuma platums
	int fieldH; //Augstums

	int centerPositionY; //Laukuma centra Y koordināta
	int centerPositionX; //Laukuma centra X koordināta
	int goalCenter; //Vārtu centra Y koordināta

	FieldPerson* fieldPersons{nullptr}; // Rādītājs uz masīvu ar informāciju par citiem spēlētājiem laukumā
	int fieldPersonCount{0}; //Kopējais laukumā esošo spēlētāju skaits

	//Palīgmetodes algoritmu aprēķiniem
	double CalculateDistanceBetweenPoints(int x1, int y1, int x2, int y2);
	void DrawPlayer(COLORREF fill, COLORREF outline, int radius, CString text) const;
	void KickToTarget(int targetX, int targetY, int ballX, int ballY);
	int GenerateRandomNumber(int from, int to);
	void ClampToField();
	void PlayerCollision();

public:
	Player(GameInterface* pG, Side side, COLORREF color);

	int GetRadius() const { return myRadius; }
	Side GetSide() const { return mySide; }
	int GetID() const { return myID; }

	void GetPosition(int &px, int &py) const { // Nodod spēlētāja aktuālās koordinātes simulācijas programmai
		px = x;
		py = y;
	}

	void SetPosition(int x, int y) { this->x = x; this->y = y; }

	void SetFieldPersonList(FieldPerson* pFP, int n);
	void Draw() const;
	void Move();
};
