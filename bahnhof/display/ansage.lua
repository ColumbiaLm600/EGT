-- Ansage über Lautsprecher (Speaker).
-- Wartet auf Nachrichten vom Server und spielt Audiodateien ab.
-- Die Dateien liegen in /bahnhof/ansagen/audio/ (siehe ansagen/erzeugen.py).
-- Starten mit:  /bahnhof/display/ansage.lua

package.path = "/bahnhof/?.lua;" .. package.path

local config = require("config")
local Netz = require("lib.netz")
local Text = require("lib.text")
local dfpwm = require("cc.audio.dfpwm")

local AUDIO_ORDNER = "/bahnhof/ansagen/audio/"

local lautsprecher = { peripheral.find("speaker") }
if #lautsprecher == 0 then
  error("Kein Lautsprecher gefunden. Bitte einen Speaker an den Computer setzen.", 0)
end

-- Für welche Gleise sagt dieser Computer an?
local meine_gleise = {}
for _, g in ipairs(config.ansage_gleise or { config.gleis }) do
  meine_gleise[tostring(g)] = true
end

-- Spielt einen Block Ton auf allen Lautsprechern ab.
local function spiele_block(block)
  for _, sp in ipairs(lautsprecher) do
    while not sp.playAudio(block) do
      os.pullEvent("speaker_audio_empty")
    end
  end
end

-- Spielt eine Audiodatei ab. Fehlt sie, wird sie übersprungen.
local function spiele_datei(name)
  local pfad = AUDIO_ORDNER .. name .. ".dfpwm"
  if not fs.exists(pfad) then
    print("Datei fehlt: " .. name .. ".dfpwm")
    return
  end
  local decoder = dfpwm.make_decoder()
  local datei = fs.open(pfad, "rb")
  while true do
    local stueck = datei.read(16 * 1024)
    if not stueck then break end
    spiele_block(decoder:decode(stueck))
  end
  datei.close()
end

-- Zwei Glockentöne vor jeder Ansage.
local function gong()
  for _, sp in ipairs(lautsprecher) do
    sp.playNote("bell", 3, 12)
  end
  sleep(0.5)
  for _, sp in ipairs(lautsprecher) do
    sp.playNote("bell", 3, 6)
  end
  sleep(0.9)
end

-- Welche Dateien gehören zu einer Einfahrt?
-- Beispiel: "Auf Gleis 3 fährt ein: S-Bahn S1 nach Hafen. Bitte zurücktreten."
local function einfahrt_dateien(abf)
  local teile = {
    "auf_gleis", "num_" .. tostring(abf.gleis), "faehrt_ein",
    "typ_" .. tostring(abf.typ),
  }
  if abf.linie and abf.linie ~= abf.typ then
    teile[#teile + 1] = "linie_" .. Text.slug(abf.linie)
  end
  teile[#teile + 1] = "nach"
  teile[#teile + 1] = "ziel_" .. Text.slug(abf.ziel)
  teile[#teile + 1] = "bitte_zurueck"
  return teile
end

-- Warteschlange: Ansagen kommen nacheinander dran.
local schlange = {}

local function empfangen()
  Netz.start()
  while true do
    local _, _, nachricht, protokoll = os.pullEvent("rednet_message")
    nachricht = Netz.filtere(config.bahnhof, protokoll, nachricht)
    if nachricht and nachricht.t == "ansage" and nachricht.abfahrt
        and meine_gleise[tostring(nachricht.gleis)] then
      schlange[#schlange + 1] = nachricht.abfahrt
      os.queueEvent("ansage_neu")
    end
  end
end

local function abspielen()
  while true do
    if #schlange == 0 then
      os.pullEvent("ansage_neu")
    else
      local abf = table.remove(schlange, 1)
      print("Ansage: Gleis " .. tostring(abf.gleis) .. " " .. tostring(abf.linie))
      gong()
      for _, name in ipairs(einfahrt_dateien(abf)) do
        spiele_datei(name)
      end
      sleep(1)
    end
  end
end

print("Ansage für Gleis: " .. table.concat(config.ansage_gleise or { config.gleis }, ", "))
parallel.waitForAny(empfangen, abspielen)
