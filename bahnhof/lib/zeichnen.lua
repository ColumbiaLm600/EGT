-- Zeichen-Hilfen für Monitore.

local M = {}

-- Farbe aus Namen holen. "green" -> colors.green
function M.farbe(name)
  return colors[name] or colors.white
end

-- Stellt die Textgröße so ein, dass mindestens
-- `min_breite` x `min_hoehe` Zeichen auf den Monitor passen.
-- Es wird die größte passende Schrift gewählt.
function M.skaliere(monitor, min_breite, min_hoehe)
  if not monitor.setTextScale then return end
  for _, skala in ipairs({ 5, 4, 3, 2.5, 2, 1.5, 1, 0.5 }) do
    monitor.setTextScale(skala)
    local b, h = monitor.getSize()
    if b >= min_breite and h >= min_hoehe then return end
  end
end

-- Schreibt Text an eine Stelle, mit Farben.
function M.schreibe(t, x, y, text, vordergrund, hintergrund)
  local b, h = t.getSize()
  if y < 1 or y > h or x > b then return end
  t.setCursorPos(x, y)
  if vordergrund then t.setTextColor(vordergrund) end
  if hintergrund then t.setBackgroundColor(hintergrund) end
  t.write(text)
end

-- Füllt eine ganze Zeile mit einer Hintergrundfarbe.
function M.zeile(t, y, hintergrund)
  local b = t.getSize()
  M.schreibe(t, 1, y, string.rep(" ", b), colors.white, hintergrund)
end

-- Bildschirm leeren (schwarz).
function M.leeren(t)
  t.setBackgroundColor(colors.black)
  t.setTextColor(colors.white)
  t.clear()
end

-- Passenden Monitor finden. name = nil: erster Monitor.
function M.finde_monitor(name)
  local monitor
  if name then
    monitor = peripheral.wrap(name)
  else
    monitor = peripheral.find("monitor")
  end
  if not monitor then
    error("Kein Monitor gefunden. Bitte einen Monitor an den Computer setzen.", 0)
  end
  return monitor
end

return M
