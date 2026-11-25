-- Hallen-Tafel (Abfahrtstafel).
-- Zeigt die nächsten Abfahrten. Mit config.typen nur bestimmte Zugtypen.
-- Starten mit:  /bahnhof/display/halle.lua

package.path = "/bahnhof/?.lua;" .. package.path

local config = require("config")
local Netz = require("lib.netz")
local Zeichnen = require("lib.zeichnen")
local Anzeige = require("lib.anzeige")

local TIMEOUT = 15 -- Sekunden ohne Daten, dann "Keine Daten"

local monitor = Zeichnen.finde_monitor(config.monitor)
Zeichnen.skaliere(monitor, Anzeige.HALLE_MIN.breite, Anzeige.HALLE_MIN.hoehe)
Netz.start()

local daten = nil
Anzeige.halle(monitor, daten, config)

local timer = os.startTimer(TIMEOUT)
while true do
  local ereignis, a, b, c = os.pullEvent()
  if ereignis == "rednet_message" then
    local nachricht = Netz.filtere(config.bahnhof, c, b)
    if nachricht and nachricht.t == "zustand" then
      daten = nachricht
      Anzeige.halle(monitor, daten, config)
      timer = os.startTimer(TIMEOUT)
    end
  elseif ereignis == "timer" and a == timer then
    daten = nil
    Anzeige.halle(monitor, daten, config)
    timer = os.startTimer(TIMEOUT)
  elseif ereignis == "monitor_resize" then
    Zeichnen.skaliere(monitor, Anzeige.HALLE_MIN.breite, Anzeige.HALLE_MIN.hoehe)
    Anzeige.halle(monitor, daten, config)
  end
end
