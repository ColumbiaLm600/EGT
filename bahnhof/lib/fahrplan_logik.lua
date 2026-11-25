-- Fahrplan-Logik.
-- Berechnet, welche Züge als nächstes fahren.
-- Diese Datei nutzt KEINE ComputerCraft-Funktionen.
-- Darum kann man sie auch ohne Minecraft testen.
--
-- Ein Fahrplan-Eintrag sieht so aus:
--   { linie = "S1", typ = "S", ziel = "Hafen", via = "Altstadt",
--     gleis = 1, region = "A2",
--     zeit  = "12:30" }                          -- eine Abfahrt
--   oder zeiten = { "12:30", "13:10" }           -- mehrere Abfahrten
--   oder takt = { ab = "05:00", bis = "23:00", alle = 20 }  -- Takt

local Zeit = require("lib.zeit")
local Zugtypen = require("lib.zugtypen")

local M = {}

-- Alle Abfahrtszeiten eines Eintrags (in Minuten seit 00:00).
function M.zeiten(eintrag)
  local liste = {}
  if eintrag.zeit then
    liste[#liste + 1] = Zeit.parse(eintrag.zeit)
  end
  for _, z in ipairs(eintrag.zeiten or {}) do
    liste[#liste + 1] = Zeit.parse(z)
  end
  if eintrag.takt then
    local ab = Zeit.parse(eintrag.takt.ab or "00:00")
    local bis = Zeit.parse(eintrag.takt.bis or "23:59")
    local alle = eintrag.takt.alle
    if not alle or alle < 1 then
      error("Takt braucht 'alle' (Minuten, mindestens 1) bei Linie " .. tostring(eintrag.linie), 2)
    end
    local t = ab
    while t <= bis do
      liste[#liste + 1] = t
      t = t + alle
    end
  end
  return liste
end

-- Die nächsten Abfahrten.
-- fahrplan: Liste von Einträgen
-- jetzt:    aktuelle Zeit in Minuten seit 00:00
-- opt.gleis:      nur dieses Gleis
-- opt.max:        höchstens so viele Abfahrten (Standard: alle)
-- opt.rueckblick: so viele Minuten nach der Abfahrt noch zeigen (Standard 3)
-- opt.vorschau:   so viele Minuten in die Zukunft (Standard 180)
--
-- Jede Abfahrt hat: id, zeit (Minuten), zeit_text, in_min,
-- und die Felder aus dem Fahrplan (linie, typ, ziel, via, gleis, region).
function M.abfahrten(fahrplan, jetzt, opt)
  opt = opt or {}
  local rueck = opt.rueckblick or 3
  local vor = opt.vorschau or 180
  local ergebnis = {}

  for nr, e in ipairs(fahrplan) do
    if opt.gleis == nil or tostring(e.gleis) == tostring(opt.gleis) then
      for _, t in ipairs(M.zeiten(e)) do
        -- Minuten bis zur Abfahrt. Negativ = schon vorbei.
        -- Das "% 1440" sorgt dafür, dass es über Mitternacht klappt.
        local in_min = (t - jetzt + rueck) % 1440 - rueck
        if in_min <= vor then
          ergebnis[#ergebnis + 1] = {
            id = nr .. "@" .. t,
            zeit = t,
            zeit_text = Zeit.format(t),
            in_min = in_min,
            linie = e.linie,
            typ = e.typ,
            ziel = e.ziel,
            via = e.via,
            gleis = e.gleis,
            region = e.region,
          }
        end
      end
    end
  end

  table.sort(ergebnis, function(a, b)
    if a.in_min ~= b.in_min then return a.in_min < b.in_min end
    local pa, pb = Zugtypen.info(a.typ).prio, Zugtypen.info(b.typ).prio
    if pa ~= pb then return pa < pb end
    return a.id < b.id
  end)

  if opt.max and #ergebnis > opt.max then
    for i = #ergebnis, opt.max + 1, -1 do
      ergebnis[i] = nil
    end
  end
  return ergebnis
end

-- Welche Abfahrt meint ein Melder am Gleis?
-- Gesucht: die früheste Abfahrt dieses Gleises, die höchstens
-- `vorlauf` Minuten in der Zukunft liegt (oder noch im Rückblick).
-- Gibt nil zurück, wenn nichts passt.
function M.passende_abfahrt(fahrplan, jetzt, gleis, vorlauf, rueckblick)
  local liste = M.abfahrten(fahrplan, jetzt, {
    gleis = gleis, max = 1, rueckblick = rueckblick or 3, vorschau = vorlauf or 15,
  })
  return liste[1]
end

return M
