shift_hyper = {"cmd","alt","ctrl","shift"}

hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall:andUse("ToggleScreenRotation",
  {
    hotkeys = {
      first = {
        shift_hyper,
        "r"
      }
    }
  })

local logger = hs.logger.new('gerrard','debug')
-- table = hs.screen.allScreens()
dellScreen = hs.screen.find('B28F947B-7358-4262-813B-03CB8B692E0F')
logger.d(dellScreen:rotate())
worked = dellScreen:rotate(270)
logger.d(worked)
logger.d(dellScreen:rotate())
-- logger.d(oon.ToggleScreenRotation._screens)
-- for k, v in pairs(table) do
--     print(k, v)
-- end

hs.loadSpoon("VimWindowNav")
spoon.VimWindowNav.hotkey_modifier = shift_hyper

spoon.VimWindowNav:start()
