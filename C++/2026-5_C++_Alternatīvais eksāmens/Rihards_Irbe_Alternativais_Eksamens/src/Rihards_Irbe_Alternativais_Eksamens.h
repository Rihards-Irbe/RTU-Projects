// Rihards_Irbe_Alternativais_Eksamens.h : main header file for the Rihards_Irbe_Alternativais_Eksamens DLL
//

#pragma once

#ifndef __AFXWIN_H__
	#error "include 'pch.h' before including this file for PCH"
#endif

#include "resource.h"		// main symbols


// CRihardsIrbeAlternativaisEksamensApp
// See Rihards_Irbe_Alternativais_Eksamens.cpp for the implementation of this class
//

class CRihardsIrbeAlternativaisEksamensApp : public CWinApp
{
public:
	CRihardsIrbeAlternativaisEksamensApp();

// Overrides
public:
	virtual BOOL InitInstance();

	DECLARE_MESSAGE_MAP()
};
