-- Einstellungen für die Bahnhofsanzeigen.
-- Jeder Computer in der Welt hat eine eigene Kopie dieser Datei.
-- Du änderst nur die Zeilen, die zu diesem Computer passen.

return {
  -- ===== Gilt für ALLE Computer eines Bahnhofs =====

  -- Name des Bahnhofs. Muss überall exakt gleich geschrieben sein.
  bahnhof = "Edgartown Hbf",

  -- ===== Nur für den SERVER =====

  -- Alle Gleise dieses Bahnhofs.
  gleise = { 1, 2, 3, 4, 5, 6 },

  -- "echt":   Uhrzeit des Servers (Fahrplan läuft wie im echten Leben)
  -- "ingame": Minecraft-Zeit (ein Tag dauert nur 20 echte Minuten)
  zeit_modus = "echt",

  -- Wie lange (in Minuten) ein Zug nach der Abfahrtszeit noch angezeigt wird.
  rueckblick = 3,

  -- ===== Nur für BAHNSTEIG-Display, MELDER und ANSAGE =====

  -- Gleis, zu dem dieser Computer gehört.
  gleis = 1,

  -- ===== Nur für HALLEN-Tafel =====

  -- Welche Zugtypen zeigt die Tafel? nil = alle.
  -- Beispiel nur S-Bahn:  typen = { "S" }
  -- Beispiel Fernverkehr: typen = { "IC", "SZ" }
  typen = nil,

  -- Titel auf der Tafel. nil = "Abfahrt".
  titel = nil,

  -- ===== Nur für MELDER =====

  -- Seite des Computers, an der das Redstone-Signal ankommt.
  -- Mögliche Werte: "top", "bottom", "left", "right", "front", "back"
  melder_seite = "back",

  -- Nach einer Meldung so viele Sekunden keine neue annehmen.
  melder_pause = 30,

  -- ===== Nur für ANSAGE =====

  -- Gleise, für die dieser Lautsprecher-Computer ansagt.
  -- nil = nur das Gleis oben.
  ansage_gleise = nil,

  -- ===== Optional =====

  -- Name des Monitors (z. B. "monitor_3"). nil = erster gefundener Monitor.
  monitor = nil,
}
