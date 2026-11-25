-- Melder am Gleis.
-- Liest ein Redstone-Signal (z. B. von einem Melder-Block am Gleis)
-- und meldet dem Server: "Am Gleis ist ein Zug."
-- Gleis und Seite stehen in config.lua.
-- Starten mit:  /bahnhof/display/melder.lua

package.path = "/bahnhof/?.lua;" .. package.path

local config = require("config")
local Netz = require("lib.netz")

local pause = config.melder_pause or 30
local seite = config.melder_seite or "back"

Netz.start()
print("Melder Gleis " .. tostring(config.gleis) .. " (Seite: " .. seite .. ")")

local letzte_meldung = nil -- Uhrzeit (os.clock) der letzten Meldung
local war_an = redstone.getInput(seite)

while true do
  os.pullEvent("redstone")
  local ist_an = redstone.getInput(seite)
  -- Nur beim Einschalten melden (nicht beim Ausschalten)
  if ist_an and not war_an then
    local jetzt = os.clock()
    if not letzte_meldung or jetzt - letzte_meldung >= pause then
      letzte_meldung = jetzt
      Netz.sende({ t = "melder", bahnhof = config.bahnhof, gleis = config.gleis })
      print("Meldung gesendet: Gleis " .. tostring(config.gleis))
    end
  end
  war_an = ist_an
end
