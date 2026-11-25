-- Bahnsteig-Display.
-- Zeigt den nächsten Zug von einem Gleis (Gleis steht in config.lua).
-- Starten mit:  /bahnhof/display/bahnsteig.lua

package.path = "/bahnhof/?.lua;" .. package.path

local config = require("config")
local Netz = require("lib.netz")
local Zeichnen = require("lib.zeichnen")
local Anzeige = require("lib.anzeige")

local TIMEOUT = 15 -- Sekunden ohne Daten, dann "Keine Daten"

local monitor = Zeichnen.finde_monitor(config.monitor)
Zeichnen.skaliere(monitor, Anzeige.BAHNSTEIG_MIN.breite, Anzeige.BAHNSTEIG_MIN.hoehe)
Netz.start()

local daten = nil
Anzeige.bahnsteig(monitor, daten, config)

local timer = os.startTimer(TIMEOUT)
while true do
  local ereignis, a, b, c = os.pullEvent()
  if ereignis == "rednet_message" then
    local nachricht = Netz.filtere(config.bahnhof, c, b)
    if nachricht and nachricht.t == "zustand" then
      daten = nachricht
      Anzeige.bahnsteig(monitor, daten, config)
      timer = os.startTimer(TIMEOUT)
    end
  elseif ereignis == "timer" and a == timer then
    daten = nil
    Anzeige.bahnsteig(monitor, daten, config)
    timer = os.startTimer(TIMEOUT)
  elseif ereignis == "monitor_resize" then
    Zeichnen.skaliere(monitor, Anzeige.BAHNSTEIG_MIN.breite, Anzeige.BAHNSTEIG_MIN.hoehe)
    Anzeige.bahnsteig(monitor, daten, config)
  end
end
