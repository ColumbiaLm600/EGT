#!/usr/bin/env python3
"""Erzeugt die Sprachdateien für die Bahnhofs-Ansagen.

Läuft auf dem eigenen PC (nicht in Minecraft).

Was das Programm macht:
  1. Liest die festen Bausteine aus texte.md.
  2. Liest Linien und Ziele aus ../server/fahrplan.lua.
  3. Spricht jeden Text mit espeak-ng (deutsche Stimme).
  4. Wandelt das Ergebnis mit ffmpeg in .dfpwm um (das Format von ComputerCraft).

Die fertigen Dateien landen in ./audio/.
Diesen Ordner danach in die Welt kopieren nach:  bahnhof/ansagen/audio/

Benötigt: Python 3, espeak-ng, ffmpeg (Version 5.1 oder neuer).

Aufruf:
  python3 erzeugen.py            # alles erzeugen
  python3 erzeugen.py --trocken  # nur auflisten, nichts erzeugen
"""

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

HIER = Path(__file__).resolve().parent
TEXTE = HIER / "texte.md"
FAHRPLAN = HIER.parent / "server" / "fahrplan.lua"

# Muss genau so arbeiten wie slug() in lib/text.lua!
DATEI_ERSATZ = {
    "ä": "ae", "ö": "oe", "ü": "ue",
    "Ä": "ae", "Ö": "oe", "Ü": "ue",
    "ß": "ss",
}


def slug(text: str) -> str:
    for alt, neu in DATEI_ERSATZ.items():
        text = text.replace(alt, neu)
    # Andere Nicht-ASCII-Zeichen fallen weg (wie in Lua)
    text = re.sub(r"[^\x00-\x7f]", "", text)
    text = re.sub(r"[^a-z0-9]+", "_", text.lower())
    return text.strip("_")


def lese_texte() -> dict:
    """Feste Bausteine aus texte.md: Zeilen im Format '- name: Text'."""
    ergebnis = {}
    for zeile in TEXTE.read_text(encoding="utf-8").splitlines():
        treffer = re.match(r"^- (\w+): (.+)$", zeile.strip())
        if treffer:
            ergebnis[treffer.group(1)] = treffer.group(2).strip()
    return ergebnis


def lese_fahrplan() -> dict:
    """Linien und Ziele aus fahrplan.lua (einfache Textsuche)."""
    quelle = FAHRPLAN.read_text(encoding="utf-8")
    # Kommentare entfernen, damit Beispiele im Kommentar nicht zählen
    quelle = re.sub(r"--[^\n]*", "", quelle)
    ergebnis = {}
    for linie in re.findall(r'linie\s*=\s*"([^"]+)"', quelle):
        # "S1" -> "S 1", damit die Stimme Buchstabe und Zahl getrennt spricht
        gesprochen = re.sub(r"(\d+)", r" \1", linie).strip()
        ergebnis["linie_" + slug(linie)] = gesprochen
    for ziel in re.findall(r'(?:ziel|via)\s*=\s*"([^"]+)"', quelle):
        ergebnis["ziel_" + slug(ziel)] = ziel
    return ergebnis


def spreche(text: str, ziel: Path, stimme: str, tempo: int) -> None:
    with tempfile.TemporaryDirectory() as ordner:
        wav = Path(ordner) / "ton.wav"
        subprocess.run(
            ["espeak-ng", "-v", stimme, "-s", str(tempo), "-w", str(wav), text],
            check=True,
        )
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav),
             "-ar", "48000", "-ac", "1", "-c:a", "dfpwm", str(ziel)],
            check=True,
        )


def main() -> int:
    parser = argparse.ArgumentParser(description="Erzeugt Ansage-Dateien (.dfpwm)")
    parser.add_argument("--trocken", action="store_true",
                        help="nur auflisten, nichts erzeugen")
    parser.add_argument("--ordner", default=str(HIER / "audio"),
                        help="Zielordner (Standard: ./audio)")
    parser.add_argument("--stimme", default="de", help="espeak-ng Stimme (Standard: de)")
    parser.add_argument("--tempo", type=int, default=140,
                        help="Sprechtempo in Wörtern pro Minute (Standard: 140)")
    args = parser.parse_args()

    # Reihenfolge: automatisch erzeugte zuerst, dann feste Texte.
    # Feste Texte aus texte.md haben Vorrang (eigene Aussprache).
    bausteine = lese_fahrplan()
    bausteine.update(lese_texte())

    ordner = Path(args.ordner)
    print(f"{len(bausteine)} Bausteine gefunden.")
    if args.trocken:
        for name, text in sorted(bausteine.items()):
            print(f"  {name}.dfpwm  <-  {text}")
        return 0

    for programm in ("espeak-ng", "ffmpeg"):
        if subprocess.run(["which", programm], capture_output=True).returncode != 0:
            print(f"Fehler: '{programm}' ist nicht installiert.", file=sys.stderr)
            return 1

    ordner.mkdir(parents=True, exist_ok=True)
    for name, text in sorted(bausteine.items()):
        print(f"  {name}.dfpwm")
        spreche(text, ordner / f"{name}.dfpwm", args.stimme, args.tempo)
    # Liste aller Dateien, damit install.lua sie laden kann
    (ordner / "index.txt").write_text(
        "\n".join(f"{name}.dfpwm" for name in sorted(bausteine)) + "\n", encoding="utf-8"
    )
    print(f"Fertig. Dateien liegen in: {ordner}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
