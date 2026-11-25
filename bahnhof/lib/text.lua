-- Text-Hilfen.
-- ComputerCraft zeigt Umlaute nur an, wenn sie als Einzel-Zeichen
-- (Latin-1) vorliegen. Dateien sind aber UTF-8. Diese Datei wandelt um.

local M = {}

-- UTF-8 (2 Byte) -> Latin-1 (1 Byte), so wie ComputerCraft es zeigt
local ANZEIGE = {
  ["\195\164"] = "\228", -- ä
  ["\195\182"] = "\246", -- ö
  ["\195\188"] = "\252", -- ü
  ["\195\132"] = "\196", -- Ä
  ["\195\150"] = "\214", -- Ö
  ["\195\156"] = "\220", -- Ü
  ["\195\159"] = "\223", -- ß
}

-- UTF-8 -> Ersatz für Dateinamen
local DATEI = {
  ["\195\164"] = "ae", ["\195\182"] = "oe", ["\195\188"] = "ue",
  ["\195\132"] = "ae", ["\195\150"] = "oe", ["\195\156"] = "ue",
  ["\195\159"] = "ss",
}

-- Text für den Bildschirm vorbereiten.
function M.anzeige(s)
  s = tostring(s or "")
  return (s:gsub("\195[\128-\191]", function(c) return ANZEIGE[c] or "?" end))
end

-- Text auf n Zeichen kürzen. Ein Punkt zeigt, dass gekürzt wurde.
function M.kuerzen(s, n)
  s = M.anzeige(s)
  if n <= 0 then return "" end
  if #s > n then
    return s:sub(1, n - 1) .. "."
  end
  return s
end

-- Text auf genau n Zeichen auffüllen (links bündig).
function M.links(s, n)
  s = M.kuerzen(s, n)
  return s .. string.rep(" ", n - #s)
end

-- Text auf genau n Zeichen auffüllen (rechts bündig).
function M.rechts(s, n)
  s = M.kuerzen(s, n)
  return string.rep(" ", n - #s) .. s
end

-- Text in die Mitte von n Zeichen setzen.
function M.mitte(s, n)
  s = M.kuerzen(s, n)
  local links = math.floor((n - #s) / 2)
  return string.rep(" ", links) .. s .. string.rep(" ", n - #s - links)
end

-- Dateiname aus Text. "Hafen Süd" -> "hafen_sued".
-- Muss genau so auch in ansagen/erzeugen.py laufen!
function M.slug(s)
  s = tostring(s or "")
  s = s:gsub("\195[\128-\191]", function(c) return DATEI[c] or "" end)
  s = s:lower():gsub("[^a-z0-9]+", "_")
  s = s:gsub("^_+", ""):gsub("_+$", "")
  return s
end

return M
