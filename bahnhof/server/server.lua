-- Zentralrechner (Server) für die Bahnhofsanzeigen.
-- Starten mit:  /bahnhof/server/server.lua
--
-- Aufgaben:
--  1. Fahrplan lesen und die nächsten Abfahrten berechnen.
--  2. Alle paar Sekunden den Zustand an alle Displays senden.
--  3. Melder-Nachrichten annehmen ("Zug ist am Gleis")
--     und eine Ansage auslösen.

package.path = "/bahnhof/?.lua;" .. package.path

local config = require("config")
local fahrplan = require("server.fahrplan")
local Logik = require("lib.fahrplan_logik")
local Zeit = require("lib.zeit")
local Netz = require("lib.netz")

local SENDE_PAUSE = 5      -- Sekunden zwischen zwei Zustands-Nachrichten
local MELDER_VORLAUF = 15  -- Melder gilt für Züge der nächsten 15 Minuten

-- id einer Abfahrt -> true, wenn ein Melder sie als "fährt ein" markiert hat
local einfahrt = {}

-- Baut die Nachricht mit allen Abfahrten.
local function baue_zustand()
  local jetzt = Zeit.jetzt(config.zeit_modus)
  local rueck = config.rueckblick or 3

  local alle = Logik.abfahrten(fahrplan, jetzt, { max = 30, rueckblick = rueck })
  local gleise = {}
  for _, g in ipairs(config.gleise) do
    gleise[tostring(g)] = Logik.abfahrten(fahrplan, jetzt, { gleis = g, max = 4, rueckblick = rueck })
  end

  -- Markierungen anwenden und alte aufräumen
  local noch_aktuell = {}
  local function markiere(liste)
    for _, abf in ipairs(liste) do
      if einfahrt[abf.id] then
        abf.status = "einfahrt"
        noch_aktuell[abf.id] = true
      else
        abf.status = "geplant"
      end
    end
  end
  markiere(alle)
  for _, liste in pairs(gleise) do markiere(liste) end
  einfahrt = noch_aktuell

  return { t = "zustand", bahnhof = config.bahnhof, jetzt = jetzt, alle = alle, gleise = gleise }
end

-- Ein Melder meldet: Am Gleis ist ein Zug.
local function melder_behandeln(nachricht)
  local jetzt = Zeit.jetzt(config.zeit_modus)
  local abf = Logik.passende_abfahrt(fahrplan, jetzt, nachricht.gleis, MELDER_VORLAUF, config.rueckblick)
  if not abf then
    print("Melder Gleis " .. tostring(nachricht.gleis) .. ": kein passender Zug im Fahrplan.")
    return
  end
  if einfahrt[abf.id] then return end -- schon gemeldet

  einfahrt[abf.id] = true
  abf.status = "einfahrt"
  print(Zeit.format(jetzt) .. "  Einfahrt Gleis " .. tostring(abf.gleis) .. ": " .. tostring(abf.linie) .. " nach " .. tostring(abf.ziel))

  Netz.sende({ t = "ansage", bahnhof = config.bahnhof, gleis = abf.gleis, abfahrt = abf })
  Netz.sende(baue_zustand()) -- Displays sofort aktualisieren
end

Netz.start()
print("EGT Bahnhofsserver: " .. config.bahnhof)
print("Zeit-Modus: " .. tostring(config.zeit_modus))
print("Beenden mit Strg+T")

local timer = os.startTimer(0)
while true do
  local ereignis, a, b, c = os.pullEvent()
  if ereignis == "timer" and a == timer then
    Netz.sende(baue_zustand())
    timer = os.startTimer(SENDE_PAUSE)
  elseif ereignis == "rednet_message" then
    -- a = Absender, b = Nachricht, c = Protokoll
    local nachricht = Netz.filtere(config.bahnhof, c, b)
    if nachricht and nachricht.t == "melder" then
      melder_behandeln(nachricht)
    end
  end
end
