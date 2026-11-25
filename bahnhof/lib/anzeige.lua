-- Die zwei Ansichten: Bahnsteig-Display und Hallen-Tafel.
-- Beide bekommen einen Bildschirm (t) und die Daten vom Server.

local Zeichnen = require("lib.zeichnen")
local Zugtypen = require("lib.zugtypen")
local Text = require("lib.text")
local Zeit = require("lib.zeit")

local M = {}

-- Mindestgröße in Zeichen, auf die die Schrift eingestellt wird.
M.BAHNSTEIG_MIN = { breite = 26, hoehe = 12 }
M.HALLE_MIN = { breite = 40, hoehe = 14 }

-- Kurzer Hinweis-Text zu einer Abfahrt
local function status_text(abf)
  if abf.status == "einfahrt" then return "fährt ein" end
  if abf.in_min <= 0 then return "Abfahrt" end
  if abf.in_min <= 30 then return "in " .. abf.in_min .. " Min" end
  return ""
end

local function mitte(t, y, text, vg, bg)
  local b = t.getSize()
  Zeichnen.schreibe(t, 1, y, Text.mitte(text, b), vg, bg)
end

local function kopfzeile(t, links, rechts)
  local b = t.getSize()
  Zeichnen.zeile(t, 1, colors.gray)
  Zeichnen.schreibe(t, 1, 1, " " .. Text.kuerzen(links, b - 8), colors.white, colors.gray)
  Zeichnen.schreibe(t, b - #rechts, 1, rechts .. " ", colors.white, colors.gray)
end

local function keine_daten(t, kopf_links)
  Zeichnen.leeren(t)
  kopfzeile(t, kopf_links, "--:--")
  local _, h = t.getSize()
  mitte(t, math.max(2, math.floor(h / 2)), "Keine Daten", colors.red, colors.black)
end

-- ===== Bahnsteig =====
-- daten: Nachricht vom Server (oder nil = keine Verbindung)
-- cfg.gleis: Gleis dieses Displays
function M.bahnsteig(t, daten, cfg)
  local b, h = t.getSize()
  if not daten then return keine_daten(t, "Gleis " .. cfg.gleis) end

  Zeichnen.leeren(t)
  kopfzeile(t, "Gleis " .. cfg.gleis, Zeit.format(daten.jetzt))

  local liste = (daten.gleise or {})[tostring(cfg.gleis)] or {}
  local erster = liste[1]
  if not erster then
    mitte(t, math.min(h, 4), "Kein Zug geplant", colors.lightGray, colors.black)
    return
  end

  local luft = (h >= 14) and 1 or 0
  local info = Zugtypen.info(erster.typ)
  local farbe = Zeichnen.farbe(info.farbe)
  local text_farbe = (info.farbe == "yellow" or info.farbe == "orange") and colors.black or colors.white

  local y = 2 + luft
  -- Typ-Balken: Linie + Typ
  Zeichnen.zeile(t, y, farbe)
  Zeichnen.schreibe(t, 2, y, Text.kuerzen((erster.linie or "") .. "  " .. info.name, b - 2), text_farbe, farbe)

  -- Ziel
  y = y + 1 + luft
  Zeichnen.schreibe(t, 2, y, Text.kuerzen(erster.ziel, b - 2), colors.white, colors.black)
  y = y + 1
  if erster.via then
    Zeichnen.schreibe(t, 2, y, Text.kuerzen("über " .. erster.via, b - 2), colors.lightGray, colors.black)
    y = y + 1
  end
  if erster.region then
    Zeichnen.schreibe(t, 2, y, Text.kuerzen("Region " .. erster.region, b - 2), colors.lightGray, colors.black)
    y = y + 1
  end

  -- Abfahrt
  y = y + luft
  local einfahrt = erster.status == "einfahrt"
  local abfahrt_bg = einfahrt and colors.yellow or colors.black
  local abfahrt_fg = einfahrt and colors.black or colors.white
  Zeichnen.zeile(t, y, abfahrt_bg)
  Zeichnen.schreibe(t, 2, y, erster.zeit_text .. "  " .. status_text(erster), abfahrt_fg, abfahrt_bg)

  -- Danach: die nächsten zwei Züge
  y = y + 1 + luft
  if liste[2] and y + 1 <= h then
    Zeichnen.schreibe(t, 2, y, "Danach", colors.lightGray, colors.black)
    y = y + 1
    for i = 2, math.min(#liste, 3) do
      if y > h then break end
      local n = liste[i]
      local nf = Zeichnen.farbe(Zugtypen.info(n.typ).farbe)
      Zeichnen.schreibe(t, 2, y, n.zeit_text .. " ", colors.white, colors.black)
      Zeichnen.schreibe(t, 8, y, " " .. Text.links(n.linie or "", 5), colors.black, nf)
      Zeichnen.schreibe(t, 15, y, Text.kuerzen(n.ziel, b - 15), colors.white, colors.black)
      y = y + 1
    end
  end
end

-- ===== Haupthalle =====
-- cfg.typen: Liste erlaubter Typen (oder nil = alle)
-- cfg.titel: Titel (oder nil)
-- cfg.bahnhof: Name des Bahnhofs
function M.halle(t, daten, cfg)
  local b, h = t.getSize()
  local titel = cfg.titel or "Abfahrt"
  if not daten then return keine_daten(t, titel) end

  Zeichnen.leeren(t)
  kopfzeile(t, titel .. "  " .. cfg.bahnhof, Zeit.format(daten.jetzt))

  -- Spaltenbreiten
  local mit_status = b >= 40
  local w_zeit, w_linie, w_gleis = 6, 6, 3
  local w_status = mit_status and 11 or 0
  local w_ziel = b - w_zeit - w_linie - w_gleis - w_status
  local x_zeit, x_linie = 1, 1 + w_zeit
  local x_ziel = x_linie + w_linie
  local x_status = x_ziel + w_ziel
  local x_gleis = x_status + w_status

  -- Spaltentitel
  Zeichnen.schreibe(t, x_zeit, 2, Text.links(" Zeit", w_zeit), colors.lightGray, colors.black)
  Zeichnen.schreibe(t, x_linie, 2, Text.links("Linie", w_linie), colors.lightGray, colors.black)
  Zeichnen.schreibe(t, x_ziel, 2, Text.links("Nach", w_ziel), colors.lightGray, colors.black)
  if mit_status then
    Zeichnen.schreibe(t, x_status, 2, Text.links("Hinweis", w_status), colors.lightGray, colors.black)
  end
  Zeichnen.schreibe(t, x_gleis, 2, Text.rechts("Gl", w_gleis), colors.lightGray, colors.black)

  -- Erlaubte Typen
  local erlaubt
  if cfg.typen then
    erlaubt = {}
    for _, typ in ipairs(cfg.typen) do erlaubt[typ] = true end
  end

  local y = 3
  for _, abf in ipairs(daten.alle or {}) do
    if y > h then break end
    if not erlaubt or erlaubt[abf.typ] then
      local info = Zugtypen.info(abf.typ)
      local farbe = Zeichnen.farbe(info.farbe)
      local hell = (info.farbe == "yellow" or info.farbe == "orange")
      local einfahrt = abf.status == "einfahrt"

      Zeichnen.schreibe(t, x_zeit, y, Text.links(" " .. abf.zeit_text, w_zeit), colors.white, colors.black)
      Zeichnen.schreibe(t, x_linie, y, Text.links(" " .. (abf.linie or ""), w_linie - 1) .. " ",
        hell and colors.black or colors.white, farbe)
      Zeichnen.schreibe(t, x_ziel, y, Text.links(" " .. abf.ziel, w_ziel), colors.white, colors.black)
      if mit_status then
        Zeichnen.schreibe(t, x_status, y, Text.links(status_text(abf), w_status),
          einfahrt and colors.yellow or colors.lightGray, colors.black)
      end
      Zeichnen.schreibe(t, x_gleis, y, Text.rechts(tostring(abf.gleis), w_gleis), colors.white, colors.black)
      y = y + 1
    end
  end

  if y == 3 then
    mitte(t, 4, "Keine Abfahrten", colors.lightGray, colors.black)
  end
end

return M
