# 2026-2_C++_Lab_1

## Overview
1. laboratorijas darbs

Abstrakcija un iekapsulēšana. Konstruktori un destruktori

Izveidot klasi saskaņā ar savā variantā norādītajām prasībām, radīt šīs klases objektus un pārbaudīt klases metožu darbību. Varianta aprakstā ir norādīti obligātie atribūti (iekavās – vēlamais tips), bet klasē var iekļaut papildu atribūtus. Jāievēro zemāk minētās prasības.

Visiem klases atribūtiem jābūt privātiem (private), visām klases metodēm – publiskām (public).
Iekļaut vismaz divus konstruktorus (nodrošina visu klases atribūtu inicializāciju). Konstruktoros izmantot inicializatorus un parasto piešķiri.
Izveidot destruktoru, kurš vismaz izvada ziņojumu par objekta likvidēšanu.
Iekļaut informācijas izvades metodi (piemēram, void Print() const;).
Iekļaut iegultās (inline) metodes atribūtu vērtību iegūšanai. Šo metožu vārdus veidot no vārda Get un atribūta vārda (piemēram, unsigned GetArea() const;);
Iekļaut iegultās (inline) metodes atribūtu vērtību modificēšanai. Šo metožu vārdus veidot no vārda Set un atribūta vārda (piemēram, void SetArea(unsigned area););
Funkcijā main() izmantot vismaz divus objektus – vienu lokālu objektu un vienu izveidotu dinamiski ar operatoru new, kā arī izmantot vismaz trīs klasē definētās metodes.
Informācijas izvadi realizēt, izmantojot plūsmu cout.