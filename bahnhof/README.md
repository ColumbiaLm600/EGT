# EGT Bahnhofsanzeigen

Bahnhofsanzeigen mit ComputerCraft (CC: Tweaked) für EGT.

## Was es kann

- **Bahnsteig-Display:** zeigt den nächsten Zug eines Gleises (Linie, Typ, Ziel, Zeit).
- **Hallen-Tafel:** zeigt die nächsten Abfahrten. Kann nach Zugtyp gefiltert werden.
- **Ansagen:** Lautsprecher sagen die Einfahrt an.
- **Melder:** Ein Redstone-Signal am Gleis meldet "Zug ist da".

## Zugtypen

| Typ | Name | Max. km/h | Farbe |
|-----|------|-----------|-------|
| S | S-Bahn | 80 | grün |
| R | Regionalzug | 120 | rot |
| RE | Regional-Express | 120 | magenta |
| IR | Interregio | 192 | orange |
| IC | Intercity | – | blau |
| SZ | Schnellzug | 250 | gelb |

Ändern: `lib/zugtypen.lua`.

## So hängt alles zusammen

```
Melder (Gleis)  ──►  SERVER  ──►  Bahnsteig-Display
 Redstone             │      ──►  Hallen-Tafel
                      └─────►  Ansage (Lautsprecher)
```

- Jeder Kasten ist ein **eigener Computer** in der Welt.
- Alle brauchen ein **Modem** (kabellos oder mit Kabel).
- Der Server kennt den **Fahrplan** (`server/fahrplan.lua`).
- Der Server sendet alle 5 Sekunden den Stand an alle.
- Der Melder sagt dem Server, dass ein Zug am Gleis ist.
  Dann zeigt die Anzeige "fährt ein" und die Ansage läuft.

## Aufbau in der Welt

Pro Bahnhof:

| Gerät | Anzahl | Was dranhängt |
|-------|--------|---------------|
| Server | 1 | Modem |
| Bahnsteig-Display | 1 pro Gleis | Modem + Monitor |
| Hallen-Tafel | 1 oder mehr | Modem + Monitor |
| Melder | 1 pro Gleis | Modem + Redstone-Signal |
| Ansage | 1 pro Bahnsteig | Modem + Speaker |

**Monitor-Größen (Vorschlag):**

- Bahnsteig: 3 breit x 2 hoch oder größer.
- Halle: 6 breit x 4 hoch oder größer.
- Die Schrift passt sich automatisch an.

**Hallen-Tafel für einen Zugtyp:**
In `config.lua` bei `typen` eintragen, z. B. `typen = { "IC", "SZ" }`.
So kann es eine kleine S-Bahn-Tafel und eine große Fernverkehrs-Tafel geben.

## Installation

### Variante 1: automatisch (wenn das Repo öffentlich ist)

Auf dem Computer eintippen. Ersetze `server` durch die Rolle:

```
wget run https://raw.githubusercontent.com/ColumbiaLm600/EGT/main/bahnhof/install.lua server
```

Rollen: `server`, `bahnsteig`, `halle`, `melder`, `ansage`.

Danach:

1. `edit /bahnhof/config.lua` und die Werte anpassen.
2. `reboot`

### Variante 2: von Hand kopieren

Kopiere den Ordner `bahnhof/` in den Ordner des Computers.
Im Einzelspieler liegt er hier:

```
<Welt>/computercraft/computer/<Computer-Nummer>/bahnhof/
```

Die Computer-Nummer zeigt der Befehl `id` auf dem Computer.
Dann starte die passende Datei, z. B. `/bahnhof/server/server.lua`.
Für Autostart: Datei `startup.lua` mit dieser Zeile anlegen:

```lua
shell.run("/bahnhof/server/server.lua")
```

## Einstellungen (`config.lua`)

Jeder Computer hat eine eigene Kopie. Ändere nur das, was zu seiner Rolle passt.
Alles ist in der Datei erklärt.

Wichtig:

- `bahnhof` muss auf **allen** Computern **gleich** geschrieben sein.
- `gleis` sagt, zu welchem Gleis ein Display, Melder oder Lautsprecher gehört.
- `zeit_modus = "echt"`: Der Fahrplan folgt der Uhrzeit des Servers.
  Mit `"ingame"` folgt er der Minecraft-Zeit (ein Tag = 20 Minuten).

## Fahrplan ändern

Datei: `server/fahrplan.lua`. **Die Einträge dort sind nur Beispiele.**

Ein Eintrag:

```lua
{ linie = "S1", typ = "S", ziel = "Hafen", via = "Altstadt",
  gleis = 1, takt = { ab = "05:00", bis = "23:50", alle = 10 } },
```

- `takt`: Abfahrt alle 10 Minuten.
- Oder eine einzelne Zeit: `zeit = "12:30"`.
- Für Regionalzüge: `region = "A2"` (3x3-Raster, A1 bis C3).

## Ansagen erzeugen

Die Sprachdateien baust du **auf deinem PC**:

1. Installiere Python 3, `espeak-ng` und `ffmpeg` (Version 5.1 oder neuer).
2. Im Ordner `bahnhof/ansagen/` ausführen:

   ```
   python3 erzeugen.py
   ```

3. Es entsteht der Ordner `ansagen/audio/` mit `.dfpwm`-Dateien.
4. Kopiere ihn auf den Ansage-Computer nach `/bahnhof/ansagen/audio/`.

Vorher ansehen, was erzeugt wird: `python3 erzeugen.py --trocken`

Texte ändern: `ansagen/texte.md`.
Neue Linien und Ziele aus dem Fahrplan kommen automatisch dazu.
Nach Änderungen am Fahrplan: `erzeugen.py` neu ausführen.

Die Ansage lautet z. B.:
"Auf Gleis 3 fährt ein: S-Bahn S 1 nach Hafen. Bitte zurücktreten."

## Testen ohne Minecraft

```
pip install lupa
python3 bahnhof/tests/lauf.py
```

Es muss `ALLE TESTS OK` und `ANZEIGE-TESTS OK` erscheinen.
Mit `ZEIGEN=1 python3 bahnhof/tests/lauf.py` werden die Bildschirme als Text gezeigt.

## Wenn etwas nicht klappt

| Problem | Lösung |
|---------|--------|
| "Kein Modem gefunden" | Modem an den Computer setzen. |
| "Kein Monitor gefunden" | Monitor direkt an den Computer setzen. |
| Anzeige zeigt "Keine Daten" | Server läuft? Gleicher `bahnhof`-Name? Modem-Reichweite? |
| Melder löst nichts aus | Richtige `melder_seite` in `config.lua`? Signal kommt an? |
| Ansage still, "Datei fehlt" | Audio-Dateien nach `/bahnhof/ansagen/audio/` kopieren. |
| Umlaute falsch | Datei als UTF-8 speichern. |

## Noch offen

- Welcher RTM-Block das Redstone-Signal am Gleis gibt, muss im Spiel getestet werden.
- Verspätungen und Ausfälle: noch nicht eingebaut.
- Ansage "Zug fährt ab" und Durchsagen: noch nicht eingebaut.
