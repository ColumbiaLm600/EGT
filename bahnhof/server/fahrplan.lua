-- Fahrplan von EGT.
-- BEISPIEL: Alle Orte und Zeiten hier sind erfunden.
-- Bitte durch die echten Linien von EGT ersetzen.
--
-- Zeiten sind in "echter" Uhrzeit des Servers (siehe config.lua, zeit_modus).
--
-- Felder:
--   linie   Name der Linie, z. B. "S1"
--   typ     S, R, RE, IR, IC oder SZ (siehe lib/zugtypen.lua)
--   ziel    Zielbahnhof
--   via     (optional) wichtiger Halt unterwegs
--   gleis   Gleisnummer in diesem Bahnhof
--   region  (optional) Region im 3x3-Raster: A1 bis C3
--   takt    Abfahrt alle N Minuten zwischen "ab" und "bis"
--   zeit    oder eine einzelne Abfahrtszeit

return {
  -- S-Bahn: dichter Takt
  { linie = "S1", typ = "S", ziel = "Hafen", via = "Altstadt",
    gleis = 1, takt = { ab = "05:00", bis = "23:50", alle = 10 } },
  { linie = "S2", typ = "S", ziel = "Waldsiedlung", via = "Markt",
    gleis = 2, takt = { ab = "05:05", bis = "23:55", alle = 10 } },

  -- Regionalverkehr: Ziel liegt in einer Region
  { linie = "R3", typ = "R", ziel = "Nordhafen", via = "Seeburg",
    gleis = 3, region = "A2", takt = { ab = "05:10", bis = "22:50", alle = 20 } },
  { linie = "RE5", typ = "RE", ziel = "Bergstadt", via = "Seeburg",
    gleis = 3, region = "B1", takt = { ab = "05:20", bis = "22:20", alle = 30 } },

  -- Interregio: Schnellfahrstrecke innerhalb der Region
  { linie = "IR21", typ = "IR", ziel = "Seeburg",
    gleis = 4, region = "B2", takt = { ab = "06:00", bis = "22:00", alle = 30 } },

  -- Fernverkehr
  { linie = "IC5", typ = "IC", ziel = "Fernstadt", via = "Seeburg",
    gleis = 5, takt = { ab = "06:15", bis = "21:15", alle = 60 } },
  { linie = "SZ1", typ = "SZ", ziel = "Metropole",
    gleis = 6, takt = { ab = "07:00", bis = "21:00", alle = 120 } },
}
