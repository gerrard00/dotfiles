hyper = {"cmd","alt","ctrl","shift"}

-- Load GlobalChooserTheme before other Spoons
local Theme = require("GlobalChooserTheme")
Theme.install()

hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall:andUse("ToggleScreenRotation",
  {
    hotkeys = {
      first = {
        hyper,
        "r"
      }
    }
  })

hs.loadSpoon("VimWindowNav")
spoon.VimWindowNav.hotkey_modifier = hyper

spoon.VimWindowNav:start()

-- Load the spoon
hs.loadSpoon("FuzzyFindWindows")

-- Bind hotkeys with Hyper + "/"
spoon.FuzzyFindWindows:bindHotkeys({
  search = { hyper, "w" }
})
