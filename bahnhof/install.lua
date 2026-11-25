-- Installer für die Bahnhofsanzeigen.
-- Läuft auf einem ComputerCraft-Computer (nicht auf dem PC).
--
-- Benutzung:
--   install <rolle>
-- Rollen: server, bahnsteig, halle, melder, ansage
--
-- Beispiel (auf dem Computer eintippen):
--   wget https://raw.githubusercontent.com/ColumbiaLm600/EGT/main/bahnhof/install.lua install
--   install server
--
-- Hinweis: Das geht nur, wenn das GitHub-Repo öffentlich ist
-- und der Branch "main" die Dateien enthält.
-- Sonst: Dateien von Hand kopieren (siehe README.md).

local BASIS = "https://raw.githubusercontent.com/ColumbiaLm600/EGT/main/bahnhof/"
local ZIEL = "/bahnhof/"

local GEMEINSAM = {
  "config.lua",
  "lib/zugtypen.lua", "lib/zeit.lua", "lib/text.lua", "lib/netz.lua",
}

local ROLLEN = {
  server = {
    "lib/fahrplan_logik.lua", "server/fahrplan.lua", "server/server.lua",
  },
  bahnsteig = {
    "lib/zeichnen.lua", "lib/anzeige.lua", "display/bahnsteig.lua",
  },
  halle = {
    "lib/zeichnen.lua", "lib/anzeige.lua", "display/halle.lua",
  },
  melder = {
    "display/melder.lua",
  },
  ansage = {
    "display/ansage.lua",
  },
}

-- Welche Datei startet beim Hochfahren?
local START = {
  server = "server/server.lua",
  bahnsteig = "display/bahnsteig.lua",
  halle = "display/halle.lua",
  melder = "display/melder.lua",
  ansage = "display/ansage.lua",
}

local function lade(datei)
  local antwort, fehler = http.get(BASIS .. datei, nil, true)
  if not antwort then
    return false, fehler
  end
  local inhalt = antwort.readAll()
  antwort.close()
  local f = fs.open(ZIEL .. datei, "wb")
  f.write(inhalt)
  f.close()
  return true
end

local rolle = ({ ... })[1]
if not rolle or not ROLLEN[rolle] then
  print("Benutzung: install <rolle>")
  print("Rollen: server, bahnsteig, halle, melder, ansage")
  return
end

if not http then
  print("HTTP ist ausgeschaltet. Bitte in der CC-Konfiguration aktivieren.")
  return
end

-- Eigene config.lua nicht überschreiben
local dateien = {}
for _, d in ipairs(GEMEINSAM) do
  if not (d == "config.lua" and fs.exists(ZIEL .. d)) then dateien[#dateien + 1] = d end
end
for _, d in ipairs(ROLLEN[rolle]) do dateien[#dateien + 1] = d end

for _, d in ipairs(dateien) do
  write("Lade " .. d .. " ... ")
  local ok, fehler = lade(d)
  print(ok and "ok" or ("FEHLER: " .. tostring(fehler)))
  if not ok then
    print("Abbruch. Ist das Repo öffentlich? Stimmt der Branch?")
    return
  end
end

-- Audio-Dateien für Ansagen (wenn im Repo vorhanden)
if rolle == "ansage" then
  local liste = http.get(BASIS .. "ansagen/audio/index.txt")
  if liste then
    local text = liste.readAll()
    liste.close()
    for name in text:gmatch("[^\r\n]+") do
      write("Lade Audio " .. name .. " ... ")
      local ok = lade("ansagen/audio/" .. name)
      print(ok and "ok" or "FEHLT")
    end
  else
    print("Keine Audio-Dateien im Repo gefunden.")
    print("Bitte nach /bahnhof/ansagen/audio/ kopieren (siehe README).")
  end
end

-- Autostart
local start = fs.open("/startup.lua", "w")
start.writeLine('shell.run("/bahnhof/' .. START[rolle] .. '")')
start.close()

print("")
print("Fertig. Als nächstes:")
print("  1. edit /bahnhof/config.lua")
print("  2. reboot")
