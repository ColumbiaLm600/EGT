-- Testet die Ansichten mit einem Fake-Bildschirm (ohne Minecraft).
-- Start (im Ordner bahnhof/):  python3 tests/lauf.py
-- Mit  ZEIGEN=1  wird der Bildschirm als Text ausgegeben.

package.path = "./?.lua;" .. package.path

-- ComputerCraft-Farben (Nachbau)
local namen = { "white", "orange", "magenta", "lightBlue", "yellow", "lime", "pink", "gray",
  "lightGray", "cyan", "purple", "blue", "brown", "green", "red", "black" }
colors = {}
for i, n in ipairs(namen) do colors[n] = 2 ^ (i - 1) end

local function neuer_bildschirm(b, h)
  local t = { zeilen = {}, x = 1, y = 1 }
  for y = 1, h do t.zeilen[y] = string.rep(" ", b) end
  function t.getSize() return b, h end
  function t.setCursorPos(x, y) t.x, t.y = x, y end
  function t.setTextColor() end
  function t.setBackgroundColor() end
  function t.clear() for y = 1, h do t.zeilen[y] = string.rep(" ", b) end end
  function t.write(s)
    local z = t.zeilen[t.y]
    if not z then return end
    local davor = z:sub(1, t.x - 1)
    local danach = z:sub(t.x + #s)
    t.zeilen[t.y] = (davor .. s .. danach):sub(1, b)
    t.x = t.x + #s
  end
  return t
end

local Logik = require("lib.fahrplan_logik")
local Zeit = require("lib.zeit")
local Anzeige = require("lib.anzeige")
local plan = require("server.fahrplan")

local jetzt = Zeit.parse("10:05")
local daten = {
  t = "zustand", bahnhof = "Test", jetzt = jetzt,
  alle = Logik.abfahrten(plan, jetzt, { max = 30 }),
  gleise = {},
}
for g = 1, 6 do daten.gleise[tostring(g)] = Logik.abfahrten(plan, jetzt, { gleis = g, max = 4 }) end
daten.gleise["1"][1].status = "einfahrt"
daten.alle[1].status = "einfahrt"

local fehler = 0
local function pruefe(name, ok)
  if not ok then fehler = fehler + 1; print("FEHLER: " .. name) end
end

local function zeige(titel, t)
  if os.getenv("ZEIGEN") then
    print("--- " .. titel)
    for _, z in ipairs(t.zeilen) do print("|" .. z .. "|") end
  end
end

-- Größen: klein, mittel, groß
for _, g in ipairs({ { 26, 12 }, { 30, 16 }, { 57, 26 }, { 15, 6 } }) do
  local t = neuer_bildschirm(g[1], g[2])
  local ok, err = pcall(Anzeige.bahnsteig, t, daten, { gleis = 3 })
  pruefe("Bahnsteig " .. g[1] .. "x" .. g[2] .. ": " .. tostring(err), ok)
  zeige("Bahnsteig Gleis 3 " .. g[1] .. "x" .. g[2], t)

  t = neuer_bildschirm(g[1], g[2])
  ok, err = pcall(Anzeige.halle, t, daten, { bahnhof = "Edgartown Hbf" })
  pruefe("Halle " .. g[1] .. "x" .. g[2] .. ": " .. tostring(err), ok)
  zeige("Halle " .. g[1] .. "x" .. g[2], t)
end

-- Ohne Daten (Verbindung weg)
local t = neuer_bildschirm(26, 12)
pruefe("Bahnsteig ohne Daten", pcall(Anzeige.bahnsteig, t, nil, { gleis = 1 }))
t = neuer_bildschirm(40, 14)
pruefe("Halle ohne Daten", pcall(Anzeige.halle, t, nil, { bahnhof = "X" }))

-- Typ-Filter: nur S-Bahn
t = neuer_bildschirm(40, 14)
Anzeige.halle(t, daten, { bahnhof = "X", typen = { "S" } })
zeige("Halle nur S", t)
local nur_s = true
for y = 3, 14 do
  local z = t.zeilen[y]
  if z:find("Fernstadt") or z:find("Metropole") then nur_s = false end
end
pruefe("Filter nur S zeigt keine IC/SZ", nur_s)

-- Gleis ohne Zug
t = neuer_bildschirm(26, 12)
Anzeige.bahnsteig(t, daten, { gleis = 99 })
pruefe("Kein Zug geplant", t.zeilen[4]:find("Kein Zug geplant") ~= nil)

if fehler == 0 then print("ANZEIGE-TESTS OK") else print(fehler .. " FEHLER") end
