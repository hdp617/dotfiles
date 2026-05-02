utilMenu = hs.menubar.new()

local icon = [[
    .............
    A...H...F...D
    .............
    .............
    ..I...G...E..
    .............
    .............
    .............
    B...........C
    .............
]]

utilMenu:setIcon('ASCII:' .. icon)

local menu = nil

local reloadMenu = function() utilMenu:setMenu(menu) end

menu = {
    {
        title = "Caffeinate",
        checked = false,
        fn = function(modifiers, menuItem)
          local enabled = hs.caffeinate.toggle('displayIdle')
          if enabled then
            hs.notify.new({title='Caffeinate', informativeText='Caffeinate on'}):send()
          else
            hs.notify.new({title='Caffeinate', informativeText='Caffeinate off'}):send()
          end
    
          menuItem.checked = enabled
          reloadMenu()
        end
    },
}

reloadMenu()
