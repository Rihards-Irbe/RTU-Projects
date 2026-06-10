#pragma once

class GameInterface;

enum class Side { UNDEF = 0, LEFT = 1, RIGHT = 2 };

struct FieldPerson {
	int nID;
	Side side;
	int x, y;
	int radius;
};

class PlayerInterface {
public:
	virtual int GetRadius() const = 0;
	virtual Side GetSide() const = 0;
	virtual int GetID() const = 0;
	virtual void SetPosition(int x, int y) = 0;
	virtual void GetPosition(int& x, int& y) const = 0;
	virtual void SetFieldPersonList(FieldPerson* pFP, int n) = 0;
	virtual void Draw() const = 0;
	virtual void Move() = 0;
};