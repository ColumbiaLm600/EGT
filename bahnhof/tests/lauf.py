#!/usr/bin/env python3
"""Startet die Lua-Tests ohne Minecraft.

Benötigt:  pip install lupa
Aufruf (egal von wo):  python3 bahnhof/tests/lauf.py
Mit Bildschirm-Ausgabe:  ZEIGEN=1 python3 bahnhof/tests/lauf.py
"""

import os
import sys
from pathlib import Path

try:
    from lupa import LuaRuntime
except ImportError:
    print("Bitte zuerst installieren:  pip install lupa")
    sys.exit(1)

BAHNHOF = Path(__file__).resolve().parent.parent
os.chdir(BAHNHOF)  # Lua-Tests erwarten diesen Ordner

fehler = 0
for name in ("test_logik.lua", "test_anzeige.lua"):
    print(f"== {name}")
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute("function os.getenv_py(n) return nil end")
    try:
        lua.execute((BAHNHOF / "tests" / name).read_text(encoding="utf-8"))
    except Exception as e:  # noqa: BLE001
        print("ABSTURZ:", e)
        fehler += 1

sys.exit(1 if fehler else 0)
