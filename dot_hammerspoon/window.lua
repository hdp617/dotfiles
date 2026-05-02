local mods = {'alt', 'ctrl'}

-- left half
hs.hotkey.bind(mods, 'left', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.5, 1}) end)
-- right half
hs.hotkey.bind(mods, 'right', function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.5, 1}) end)
-- top half
hs.hotkey.bind(mods, 'up', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 0.5}) end)
-- top half
hs.hotkey.bind(mods, 'down', function() hs.window.focusedWindow():moveToUnit({0, 0.5, 1, 0.5}) end)
-- top left
hs.hotkey.bind(mods, 'u', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.5, 0.5}) end)
-- top right
hs.hotkey.bind(mods, 'i', function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.5, 0.5}) end)
-- bottom left
hs.hotkey.bind(mods, 'j', function() hs.window.focusedWindow():moveToUnit({0, 0.5, 0.5, 0.5}) end)
-- bottom right
hs.hotkey.bind(mods, 'k', function() hs.window.focusedWindow():moveToUnit({0.5, 0.5, 0.5, 0.5}) end)
-- left third
hs.hotkey.bind(mods, 'd', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.33, 1}) end)
-- center third
hs.hotkey.bind(mods, 'f', function() hs.window.focusedWindow():moveToUnit({0.33, 0, 0.33, 1}) end)
-- right third
hs.hotkey.bind(mods, 'g', function() hs.window.focusedWindow():moveToUnit({0.67, 0, 0.33, 1}) end)
-- left two thirds
hs.hotkey.bind(mods, 'e', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.67, 1}) end)
-- right two thirds
hs.hotkey.bind(mods, 't', function() hs.window.focusedWindow():moveToUnit({0.33, 0, 0.67, 1}) end)
-- full screen
hs.hotkey.bind(mods, 'return', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 1}) end)
-- center
hs.hotkey.bind(mods, 'c', function() hs.window.focusedWindow():centerOnScreen() end)

-- move between displays
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'right', function()
  local win = hs.window.focusedWindow()
  local next = win:screen():toEast()
  if next then
    win:moveToScreen(next, true)
  end
end)
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'left', function()
  local win = hs.window.focusedWindow()
  local next = win:screen():toWest()
  if next then
    win:moveToScreen(next, true)
  end
end)

-- window hints
hs.hotkey.bind(mods, 'h', hs.hints.windowHints)

-- grid gui
hs.grid.setMargins({w = 0, h = 0})
hs.hotkey.bind({'shift', 'cmd'}, 'g', hs.grid.show)
