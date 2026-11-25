# Ansagetexte

Aus diesen Texten erzeugt `erzeugen.py` die Sprachdateien.
Jede Zeile ist ein Baustein. Die Einfahrt-Ansage setzt Bausteine zusammen.

Beispiel: **Auf Gleis 3 fährt ein: S-Bahn S 1 nach Hafen. Bitte zurücktreten.**

Format: `- dateiname: Gesprochener Text`

## Feste Bausteine

- auf_gleis: Auf Gleis
- faehrt_ein: fährt ein
- nach: nach
- bitte_zurueck: Bitte zurücktreten.

## Zugtypen

Der Name nach `typ_` ist der Typ aus `lib/zugtypen.lua`.

- typ_S: S-Bahn
- typ_R: Regionalzug
- typ_RE: Regional-Express
- typ_IR: Interregio
- typ_IC: Intercity
- typ_SZ: Schnellzug

## Gleisnummern

- num_1: 1
- num_2: 2
- num_3: 3
- num_4: 4
- num_5: 5
- num_6: 6
- num_7: 7
- num_8: 8
- num_9: 9
- num_10: 10
- num_11: 11
- num_12: 12

## Linien und Ziele

Diese Bausteine entstehen **automatisch** aus `server/fahrplan.lua`:

- `linie_<name>` für jede Linie (z. B. `linie_s1` mit dem Text "S 1")
- `ziel_<name>` für jedes Ziel (z. B. `ziel_hafen` mit dem Text "Hafen")

Eigene Aussprache für ein Ziel: hier eine Zeile mit gleichem Dateinamen
eintragen. Sie hat Vorrang vor dem automatischen Text.

Beispiel: `- ziel_waldsiedlung: Waldsiedlung`
