--- === VimWindowNav ===
---
--- Vim-style window navigation for macOS using Hammerspoon
---
--- Download: [https://github.com/yourusername/vim-window-nav](https://github.com/yourusername/vim-window-nav)
---
--- This Spoon provides vim-style keybindings (hjkl) for focusing macOS windows globally.
--- It uses Hammerspoon's built-in window focusing functions for reliable navigation.
---
--- ### Features
--- - Vim-style navigation using hjkl keys
--- - Configurable hotkey modifier
--- - Global keybindings that work system-wide
--- - Smart window detection using Hammerspoon's built-in functions
---
--- ### Usage
--- ```lua
--- hs.loadSpoon("VimWindowNav")
--- spoon.VimWindowNav:start()
--- ```
---
--- ### Configuration
--- ```lua
--- hs.loadSpoon("VimWindowNav")
--- spoon.VimWindowNav.hotkey_modifier = {"cmd","ctrl"}  -- Default
--- spoon.VimWindowNav.debug = false                     -- Default
--- spoon.VimWindowNav:start()
--- ```

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "VimWindowNav"
obj.version = "1.1"
obj.author = "Generated for vim-window-nav project"
obj.homepage = "https://github.com/yourusername/vim-window-nav"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- VimWindowNav.hotkey_modifier
--- Variable
--- The main hotkey modifier combination.
--- Accepts either a string like "ctrl+alt" or a table like {"ctrl","alt"}.
--- Default: {"cmd","ctrl"}
obj.hotkey_modifier = {"cmd","ctrl"}

--- VimWindowNav.debug
--- Variable
--- Enable debug logging. Default: false
obj.debug = false

--- VimWindowNav.logger
--- Variable
--- Logger object used within the Spoon.
obj.logger = hs.logger.new('VimWindowNav')

-- Internal variables
obj._hotkeys = {}

-- Utility functions
local function log(self, message)
    if self.debug then
        self.logger.i(message)
    end
end

-- Normalize modifiers: accept string or table
local function normalizeModifiers(mods)
    if type(mods) == "table" then
        return mods
    elseif type(mods) == "string" then
        local out = {}
        for m in mods:gmatch("[^+]+") do table.insert(out, m) end
        return out
    elseif mods == nil then
        return {}
    else
        error("hotkey_modifier must be a string like 'cmd+ctrl' or a table like {'cmd','ctrl'}")
    end
end

-- Pretty-print modifiers for logs
local function modsToString(mods)
    if type(mods) == "table" then
        return table.concat(mods, "+")
    elseif type(mods) == "string" then
        return mods
    else
        return ""
    end
end

-- Window management functions using Hammerspoon's built-in convenience functions
local function focusWindow(self, direction)
    local win = hs.window.focusedWindow()
    if not win then
        log(self, "No focused window found")
        return
    end

    local targetWindow = nil

    if direction == "north" then
        targetWindow = win:focusWindowNorth()
    elseif direction == "south" then
        targetWindow = win:focusWindowSouth()
    elseif direction == "east" then
        targetWindow = win:focusWindowEast()
    elseif direction == "west" then
        targetWindow = win:focusWindowWest()
    end

    if targetWindow then
        log(self, "Focused window " .. direction .. ": " .. targetWindow:title())
    else
        log(self, "No window found " .. direction)
    end
end

-- Hotkey setup
local function setupHotkeys(self)
    -- Clear existing hotkeys
    self:stop()

    local modifiers = normalizeModifiers(self.hotkey_modifier)

    -- Focus windows (hjkl)
    self._hotkeys.h = hs.hotkey.bind(modifiers, "h", function()
        log(self, "Focus window west")
        focusWindow(self, "west")
    end)

    self._hotkeys.j = hs.hotkey.bind(modifiers, "j", function()
        log(self, "Focus window south")
        focusWindow(self, "south")
    end)

    self._hotkeys.k = hs.hotkey.bind(modifiers, "k", function()
        log(self, "Focus window north")
        focusWindow(self, "north")
    end)

    self._hotkeys.l = hs.hotkey.bind(modifiers, "l", function()
        log(self, "Focus window east")
        focusWindow(self, "east")
    end)

    log(self, "Hotkeys configured with modifier: " .. modsToString(modifiers))
end

--- VimWindowNav:start()
--- Method
--- Start the VimWindowNav Spoon
function obj:start()
    log(self, "Starting VimWindowNav")
    setupHotkeys(self)
    return self
end

--- VimWindowNav:stop()
--- Method
--- Stop the VimWindowNav Spoon and remove all hotkeys
function obj:stop()
    log(self, "Stopping VimWindowNav")

    -- Disable all hotkeys
    for key, hotkey in pairs(self._hotkeys) do
        if hotkey then
            hotkey:delete()
        end
    end
    self._hotkeys = {}

    return self
end

--- VimWindowNav:restart()
--- Method
--- Restart the VimWindowNav Spoon
function obj:restart()
    log(self, "Restarting VimWindowNav")
    self:stop()
    self:start()
    return self
end

--- VimWindowNav:setHotkeyModifier(newModifier)
--- Method
--- Change the hotkey modifier and restart the Spoon
function obj:setHotkeyModifier(newModifier)
    local normalized = normalizeModifiers(newModifier)
    self.hotkey_modifier = normalized
    log(self, "Hotkey modifier changed to: " .. modsToString(normalized))
    self:restart()
    return self
end

--- VimWindowNav:toggleDebug()
--- Method
--- Toggle debug mode on/off
function obj:toggleDebug()
    self.debug = not self.debug
    log(self, "Debug mode " .. (self.debug and "enabled" or "disabled"))
    return self
end

--- VimWindowNav:focusWindow(direction)
--- Method
--- Manually focus a window in the specified direction
function obj:focusWindow(direction)
    focusWindow(self, direction)
    return self
end

return obj
