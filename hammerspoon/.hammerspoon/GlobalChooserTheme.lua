-- GlobalChooserTheme.lua
-- Monkey-patches hs.chooser.new to apply Nord color scheme by default

local M = {}

-- Nord color palette
M.palette = {
    background = "#2E3440",
    text = "#E5E9F0",
    subtext = "#D8DEE9",
    accent = "#81A1C1"
}

-- Default theme settings
local defaultTheme = {
    bgDark = true,
    rows = 10,
    width = 30,
    placeholderText = "Type to filter…",
    searchSubText = true,
    fgColor = { hex = M.palette.text },
    subTextColor = { hex = M.palette.subtext }
}

-- Track if already installed to prevent double-patching
local installed = false
local originalChooserNew = nil

-- Apply theme to a chooser instance
local function applyTheme(chooser, overrides)
    -- Verify chooser is valid
    if not chooser or type(chooser) ~= "userdata" then
        return
    end
    
    -- Check for opt-out flag (stored in a weak table to avoid memory leaks)
    if _G._nordOptOutChoosers and _G._nordOptOutChoosers[chooser] then
        return
    end
    
    local theme = {}
    
    -- Merge default theme with overrides
    for k, v in pairs(defaultTheme) do
        theme[k] = v
    end
    
    if overrides then
        for k, v in pairs(overrides) do
            theme[k] = v
        end
    end
    
    -- Apply theme settings using chooser methods (with error handling)
    if theme.bgDark ~= nil then
        local success, err = pcall(function() chooser:bgDark(theme.bgDark) end)
        if not success then
            hs.logger.new("GlobalChooserTheme"):w("Failed to set bgDark: " .. tostring(err))
        end
    end
    if theme.rows ~= nil then
        local success, err = pcall(function() chooser:rows(theme.rows) end)
        if not success then
            hs.logger.new("GlobalChooserTheme"):w("Failed to set rows: " .. tostring(err))
        end
    end
    if theme.width ~= nil then
        local success, err = pcall(function() chooser:width(theme.width) end)
        if not success then
            hs.logger.new("GlobalChooserTheme"):w("Failed to set width: " .. tostring(err))
        end
    end
    if theme.placeholderText ~= nil then
        local success, err = pcall(function() chooser:placeholderText(theme.placeholderText) end)
        if not success then
            hs.logger.new("GlobalChooserTheme"):w("Failed to set placeholderText: " .. tostring(err))
        end
    end
    if theme.searchSubText ~= nil then
        local success, err = pcall(function() chooser:searchSubText(theme.searchSubText) end)
        if not success then
            hs.logger.new("GlobalChooserTheme"):w("Failed to set searchSubText: " .. tostring(err))
        end
    end
    if theme.fgColor ~= nil then
        local success, err = pcall(function() chooser:fgColor(theme.fgColor) end)
        if not success then
            hs.logger.new("GlobalChooserTheme"):w("Failed to set fgColor: " .. tostring(err))
        end
    end
    if theme.subTextColor ~= nil then
        local success, err = pcall(function() chooser:subTextColor(theme.subTextColor) end)
        if not success then
            hs.logger.new("GlobalChooserTheme"):w("Failed to set subTextColor: " .. tostring(err))
        end
    end
end

-- Install the monkey-patch
function M.install(overrides)
    -- Prevent double installation
    if installed then
        return
    end
    
    -- Store original function if not already stored
    if not originalChooserNew then
        originalChooserNew = hs.chooser.new
    end
    
    -- Merge overrides with default theme
    if overrides then
        for k, v in pairs(overrides) do
            defaultTheme[k] = v
        end
    end
    
    -- Store overrides in a module-level variable so it's accessible in the closure
    local themeOverrides = overrides
    
    -- Monkey-patch hs.chooser.new
    hs.chooser.new = function(completionFn)
        -- Create chooser using original function
        local chooser = originalChooserNew(completionFn)
        
        -- Verify chooser was created successfully
        if not chooser then
            return nil
        end
        
        -- Apply theme immediately after creation (with full error handling)
        -- Use a delayed call to ensure chooser is fully initialized
        hs.timer.doAfter(0, function()
            local success, err = pcall(applyTheme, chooser, themeOverrides)
            if not success then
                hs.logger.new("GlobalChooserTheme"):w("Error applying theme (non-fatal): " .. tostring(err))
            end
        end)
        
        return chooser
    end
    
    installed = true
end

return M
