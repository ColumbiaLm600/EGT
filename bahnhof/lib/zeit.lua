-- Zeit-Hilfen.
-- Zeiten werden als "Minuten seit 00:00" gespeichert.
-- Beispiel: 01:30 ist 90.

local M = {}

-- "12:30" -> 750
function M.parse(text)
  local h, m = tostring(text):match("^(%d+):(%d%d)$")
  if not h then
    error("Ungültige Zeit: '" .. tostring(text) .. "' (richtig: HH:MM, z. B. 07:05)", 2)
  end
  h, m = tonumber(h), tonumber(m)
  if h > 23 or m > 59 then
    error("Ungültige Zeit: '" .. tostring(text) .. "'", 2)
  end
  return h * 60 + m
end

-- 750 -> "12:30"
function M.format(minuten)
  minuten = math.floor(minuten) % 1440
  return string.format("%02d:%02d", math.floor(minuten / 60), minuten % 60)
end

-- Aktuelle Zeit in Minuten seit 00:00.
-- modus "echt":   Uhrzeit des Servers (wie auf einer Uhr).
-- modus "ingame": Minecraft-Zeit (ein Tag = 20 echte Minuten).
-- Nur in ComputerCraft nutzbar (os.time mit Text gibt es nur dort).
function M.jetzt(modus)
  local stunden
  if modus == "ingame" then
    stunden = os.time("ingame")
  else
    stunden = os.time("local")
  end
  return math.floor(stunden * 60) % 1440
end

return M
