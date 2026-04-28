# 2026-3_C++_Lab_3

## Overview
3. laboratorijas darbs

Statiskie klases locekļi. Izņēmumu apstrāde

Izveidot jaunu klasi–kompozīciju ar sarakstu, kas realizēts kā masīvs, kura elementi ir rādītāji uz otrajā laboratorijas darbā realizētās apakšklases objektiem, ievērojot zemāk minētās prasības.

Iekļaut klases private atribūtu – rādītāju uz saraksta sākumu (t. i., uz rādītāju masīva pirmo elementu).
Iekļaut klases atribūtu, kura vērtība ir maksimālais masīva elementu skaits, un atribūtu, kura vērtība ir aizņemto elementu skaits masīvā.
Iekļaut statisku (static) private atribūtu, kas nosaka masīva izmēru "pēc noklusējuma", un izmantot to, lai dinamiski izveidotu rādītāju masīvu konstruktorā, kurā masīva izmērs nav uzdots kā parametrs. Iekļaut arī statisku publisku metodi šā atribūta vērtības iegūšanai.
Izveidot divus konstruktorus: vienu bez parametriem, otru ar vienu parametru – masīva izmēru.
Destruktorā paredzēt objektu, uz kuriem norāda masīva elementi, likvidēšanu un rādītāju masīva likvidēšanu.
Iekļaut informācijas izvades metodi Print(), kas izvada sarakstā esošo objektu atribūtus.
Izveidot objektu pievienošanas metodi Add(), kas kā parametru saņem atsauci uz sarakstam pievienojamo objektu. Metode izveido pievienojamā objekta kopiju un pievieno masīvam rādītāju uz šo kopiju.
Metodē Add() paredzēt masīva izmēra pārbaudi un ar operatoru throw ierosināt izņēmumu, ja masīva izmērs tiek pārsniegts. Funkcijā main() jāveic izņēmumu apstrāde, izmantojot mēģinājuma bloku try un izņēmumu apstrādātāju catch. 
Iekļaut klasē metodi masīva apstrādei atbilstoši savā variantā norādītajām prasībām un pārbaudīt tās darbību.