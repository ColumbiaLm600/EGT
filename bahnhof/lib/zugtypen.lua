-- Zugtypen von EGT.
-- Hier stehen Name, Farbe und Höchstgeschwindigkeit.
-- Neue Zugtypen: einfach eine Zeile ergänzen.
--
-- farbe: Name einer ComputerCraft-Farbe (z. B. "green", "red").
-- prio:  Kleine Zahl = wichtiger. Wird beim Sortieren genutzt,
--        wenn zwei Züge zur gleichen Zeit abfahren.

local M = {}

M.typen = {
  S  = { name = "S-Bahn",         farbe = "green",   vmax = 80,  prio = 5 },
  R  = { name = "Regionalzug",    farbe = "red",     vmax = 120, prio = 4 },
  RE = { name = "Regional-Express", farbe = "magenta", vmax = 120, prio = 3 },
  IR = { name = "Interregio",     farbe = "orange",  vmax = 192, prio = 2 },
  IC = { name = "Intercity",      farbe = "blue",    vmax = nil, prio = 1 },
  SZ = { name = "Schnellzug",     farbe = "yellow",  vmax = 250, prio = 0 },
}

local UNBEKANNT = { name = "Zug", farbe = "gray", vmax = nil, prio = 9 }

-- Gibt die Infos zu einem Typ zurück.
-- Bei unbekanntem Typ: grauer Standard, damit nichts abstürzt.
function M.info(typ)
  return M.typen[typ] or UNBEKANNT
end

return M
