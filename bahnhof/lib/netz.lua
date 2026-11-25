-- Netzwerk über rednet (das Funk-/Kabelnetz von ComputerCraft).
-- Jeder Computer braucht ein Modem (kabellos oder mit Kabel).

local M = {}

M.PROTOKOLL = "egt_bahnhof"

-- Öffnet alle angeschlossenen Modems.
function M.start()
  local gefunden = false
  peripheral.find("modem", function(name)
    rednet.open(name)
    gefunden = true
    return true
  end)
  if not gefunden then
    error("Kein Modem gefunden. Bitte ein Modem an den Computer setzen.", 0)
  end
end

-- Sendet eine Nachricht an alle Computer im Netz.
function M.sende(nachricht)
  rednet.broadcast(nachricht, M.PROTOKOLL)
end

-- Prüft, ob eine rednet-Nachricht für diesen Bahnhof ist.
-- Gibt die Nachricht (Tabelle) zurück oder nil.
function M.filtere(bahnhof, protokoll, nachricht)
  if protokoll ~= M.PROTOKOLL then return nil end
  if type(nachricht) ~= "table" then return nil end
  if nachricht.bahnhof ~= bahnhof then return nil end
  return nachricht
end

return M
