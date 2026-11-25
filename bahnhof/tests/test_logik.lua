-- Tests ohne Minecraft.
-- Start (im Ordner bahnhof/):  python3 tests/lauf.py
-- Gibt "ALLE TESTS OK" aus, wenn alles stimmt.

package.path = "./?.lua;" .. package.path

local Zeit = require("lib.zeit")
local Logik = require("lib.fahrplan_logik")
local Text = require("lib.text")
local Zugtypen = require("lib.zugtypen")

local fehler = 0
local function pruefe(name, ist, soll)
  if ist ~= soll then
    fehler = fehler + 1
    print("FEHLER: " .. name .. "  ist=" .. tostring(ist) .. "  soll=" .. tostring(soll))
  end
end

-- Zeit
pruefe("parse 12:30", Zeit.parse("12:30"), 750)
pruefe("format 750", Zeit.format(750), "12:30")
pruefe("format Mitternacht", Zeit.format(1440), "00:00")
pruefe("parse ungültig", pcall(Zeit.parse, "25:00"), false)

-- Takt
local takt = Logik.zeiten({ linie = "X", takt = { ab = "10:00", bis = "10:30", alle = 10 } })
pruefe("Takt Anzahl", #takt, 4)
pruefe("Takt letzte", takt[4], 630)

-- Nächste Abfahrten
local plan = {
  { linie = "S1", typ = "S", ziel = "Hafen", gleis = 1, takt = { ab = "10:00", bis = "11:00", alle = 20 } },
  { linie = "IC5", typ = "IC", ziel = "Fernstadt", gleis = 5, zeit = "10:20" },
  { linie = "R3", typ = "R", ziel = "Nord", gleis = 3, zeit = "10:20" },
}
local jetzt = Zeit.parse("10:05")
local liste = Logik.abfahrten(plan, jetzt, { rueckblick = 3, vorschau = 60 })
pruefe("erste ist 10:20 (IC vor R wegen Priorität)", liste[1].linie, "IC5")
pruefe("zweite ist R3", liste[2].linie, "R3")
pruefe("dritte ist S1 10:20", liste[3].linie, "S1")
pruefe("in_min", liste[1].in_min, 15)
pruefe("S1 10:00 schon vorbei und raus", (function()
  for _, a in ipairs(liste) do if a.zeit_text == "10:00" then return "da" end end
  return "weg"
end)(), "weg")

-- Rückblick: 10:00 ist 2 Minuten her -> noch sichtbar
local liste2 = Logik.abfahrten(plan, Zeit.parse("10:02"), { rueckblick = 3, vorschau = 60 })
pruefe("Rückblick zeigt 10:00", liste2[1].zeit_text, "10:00")
pruefe("Rückblick in_min negativ", liste2[1].in_min, -2)

-- Mitternacht
local nacht = { { linie = "N1", typ = "S", ziel = "Nacht", gleis = 1, zeit = "00:10" } }
local n = Logik.abfahrten(nacht, Zeit.parse("23:55"), { vorschau = 60 })
pruefe("Mitternacht in_min", n[1].in_min, 15)

-- Filter Gleis und max
local nur5 = Logik.abfahrten(plan, jetzt, { gleis = 5, vorschau = 60 })
pruefe("Gleis-Filter Anzahl", #nur5, 1)
local max1 = Logik.abfahrten(plan, jetzt, { max = 1, vorschau = 60 })
pruefe("max Anzahl", #max1, 1)

-- Melder-Zuordnung
local pass = Logik.passende_abfahrt(plan, jetzt, 5, 15)
pruefe("Melder Gleis 5 findet IC5", pass and pass.linie, "IC5")
pruefe("Melder Gleis 4 findet nichts", Logik.passende_abfahrt(plan, jetzt, 4, 15), nil)

-- Text
pruefe("slug Umlaute", Text.slug("Hafen Süd"), "hafen_sued")
pruefe("slug Sonderzeichen", Text.slug("St. Georg-Straße"), "st_georg_strasse")
pruefe("anzeige ä", Text.anzeige("fährt"), "f\228hrt")
pruefe("kuerzen", Text.kuerzen("Waldsiedlung", 6), "Walds.")

-- Typen
pruefe("Typ SZ vmax", Zugtypen.info("SZ").vmax, 250)
pruefe("Typ unbekannt", Zugtypen.info("XYZ").farbe, "gray")

if fehler == 0 then print("ALLE TESTS OK") else print(fehler .. " FEHLER") end
