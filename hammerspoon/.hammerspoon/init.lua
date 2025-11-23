shift_hyper = {"cmd","alt","ctrl","shift"}

-- Load GlobalChooserTheme before other Spoons
local Theme = require("GlobalChooserTheme")
Theme.install()

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

hs.loadSpoon("VimWindowNav")
spoon.VimWindowNav.hotkey_modifier = shift_hyper

spoon.VimWindowNav:start()

-- Load the spoon
hs.loadSpoon("FuzzyFindWindows")

-- Bind hotkeys with Hyper + "/"
spoon.FuzzyFindWindows:bindHotkeys({
  search = { shift_hyper, "w" }
})
