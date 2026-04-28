# 2026-3_C++_Lab_2

## Overview
2. laboratorijas darbs

Mantošana un atvasinātās klases

Saskaņā ar savu variantu pirmajā laboratorijas darbā realizētajai bāzes klasei izveidot atvasināto klasi ar norādīto jauno atribūtu (var pievienot arī papildu atribūtus), ievērojot zemāk minētās prasības.

Bāzes klases deklarācijā piekļuvi private nomainīt uz protected.
Atvasinātās klases konstruktoros izsaukt bāzes klases konstruktorus.
Abu klašu destruktoros izvadīt informāciju par likvidējamā objekta klasi.
Atvasinātajā klasē paredzēt jaunas metodes kases atribūtu vērību piešķiršanai un iegūšanai.
Atvasinātajā klasē pārdefinēt metodi Print(). Atvasinātās klases metodē Print() izsaukt bāzes klases metodi Print(). Ja nepieciešams, var nedaudz mainīt bāzes klases metodi Print().
Abu klašu metodes Print() un destruktorus aprakstīt kā virtuālās funkcijas.
Funkcijā main() realizēt bāzes klases objektu sarakstu, izmantojot divus paņēmienus:
kā objektu masīvu, kuru izveido dinamiski ar operatoru new. Izvadīt informāciju par objektiem masīvā un likvidēt masīvu ar operatoru delete;
kā lokālu fiksēta izmēra rādītāju masīvu, kura elementi ir rādītāji uz bāzes klases objektiem. Izvadīt informāciju par objektiem, uz kuriem norāda masīva elementi. Likvidēt šos objektus un rādītāju masīvu.