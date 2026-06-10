#include "pch.h"
#include "Player.h"
#include "Attacker.h"
#include "Defender.h"
#include "Goalkeeper.h"

#include <cmath>
#include <cstdlib>

static int IDNUM = 0;
static double PI = 3.1415926535897932;

// Funkcija, ko izsauc GameSimulator pirms spēles, lai izveidotu komandas spēlētājus
extern "C" _declspec(dllexport) PlayerInterface * _cdecl CreatePlayer(GameInterface * pG, Side side, COLORREF color)
{
	++IDNUM;

	/* Iedod 5 playeriem savu lomu */
	if (IDNUM == 1) return new Goalkeeper(pG, side, color);
	if (IDNUM == 2 || IDNUM == 3) return new Attacker(pG, side, color);
	if (IDNUM == 4 || IDNUM == 5) return new Defender(pG, side, color);
	if (IDNUM > 5 || IDNUM < 0) {
		// kluda
	}


	return new Player(pG, side, color);
}

// Bāzes klases Player konstruktors, kas inicializē sākuma vērtības
Player::Player(GameInterface* pG, Side side, COLORREF color) {
	myColor = color;
	mySide = side;
	pGame = pG;
	myID = IDNUM;
	x = 0;
	y = 0;
	pFieldDC = pGame->GetFieldDC();

	pGame->GetFieldSize(fieldW, fieldH); //laukuma izmēri

	// Aprēķinām laukuma un vārtu centrus, tie būs nepieciešami tālākiem aprēķiniem
	centerPositionY = fieldH / 2;
	centerPositionX = fieldW / 2;
	goalCenter = pGame->GetGateWidth() / 2;
}

// Saglabā informāciju par visiem spēlētājiem laukumā
void Player::SetFieldPersonList(FieldPerson* pFP, int n) {
	fieldPersons = pFP;
	fieldPersonCount = n;
}

//Uzzīmē spēlētājus simulācijā
void Player::Draw() const {
	CString num;
	num.Format(L"%d", myID);
	DrawPlayer(myColor, RGB(0, 0, 0), myRadius, num); //padodu mainigos funkcijai, ko izveidoju lai varetu veidot playeru modelus
}

void Player::Move() {
	//katram player tipam: attacker, defender, goalkeeper ir savadaka kustesanas logika, tapec sis paliek tukss
}

//Zīmēšanas palīgfunkcija, lai varētu zīmēt katru spēlētāji padodot parametra vērtības
void Player::DrawPlayer(COLORREF fill, COLORREF outline, int radius, CString text) const {
	CBrush brush(fill); // aizpilda apli
	CPen pen(PS_SOLID, 1, outline); // apla apkartne/outline

	pFieldDC->SelectObject(&brush);
	pFieldDC->SelectObject(&pen);

	pFieldDC->Ellipse(x - radius, y - radius, x + radius, y + radius); // uzzime apli

	/*Lai attelotu ciparu iekš šī apļa*/
	CRect rect(x - radius, y - radius, x + radius, y + radius);
	pFieldDC->SetBkMode(TRANSPARENT);
	pFieldDC->SetTextColor(outline);
	pFieldDC->DrawText(text, &rect, DT_CENTER | DT_VCENTER | DT_SINGLELINE);
}

//Aprēķina attāluimu starp diviem punktiem, izmantojot pitagoru teoremu
double Player::CalculateDistanceBetweenPoints(int x1, int y1, int x2, int y2) {
	double dx = x2 - x1;
	double dy = y2 - y1;

	return sqrt(dx * dx + dy * dy);
}

/*
Šī funkcija tiek izsaukta kad uzbrucēji vai aizsargi ir pietiekami tuvu bumbai, lai vīņu aizspertu
Tiek padotas vērtības, kā mērķa x,y koordinātas un bumbas x,y koordinātas
*/

void Player::KickToTarget(int targetX, int targetY, int ballX, int ballY) {

	double distance = CalculateDistanceBetweenPoints(x, y, ballX, ballY);

	//Matemātisks aprēķins, kādā leņķī spert bumbu
	double angleRad = atan2((double)(targetY - ballY), (double)(targetX - ballX));
	double angleDeg = angleRad * 180.0 / PI;
	if (angleDeg < 0) angleDeg += 360.0;
	pGame->KickBall(this, KICK_SPEED, angleDeg);
}

//Ģenerē random ciparu, padodot no un līdz parametrus
int Player::GenerateRandomNumber(int from, int to) {
	return (from + (rand() % (to - from + 1)));
}

//Novērš spēlētāja iziešanu no laukuma
void Player::ClampToField() {
	x = max(myRadius, min(fieldW - myRadius, x));
	y = max(myRadius, min(fieldH - myRadius, y));
}

//Pārbauda un novērš sadursmes ar savu komandas biedru
void Player::PlayerCollision() {
	for (int i = 0; i < fieldPersonCount; i++) {
		FieldPerson& fp = fieldPersons[i];

		//Pārbauda tikai savas komandas spēlētājus, bet ne pats sevi
		if (fp.nID != myID && fp.side == mySide) {
			double dist = CalculateDistanceBetweenPoints(x, y, fp.x, fp.y);

			// Ja spēlētājs ir pārāk tuvu, ta tas tiek atsutmts, tādējādi novēršot sadursmi
			if (dist < PLAYER_DISTANCE && dist > 0.1) {
				double dx = x - fp.x;
				double dy = y - fp.y;

				double distance = PLAYER_DISTANCE - dist;
				x += (int)(distance * dx / dist);
				y += (int)(distance * dy / dist);
			}
		}

		//Gadījumu pēc ja spēlētājs ir atstumpts ārpus laukuma
		ClampToField();
	}
}