-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")

-- Theme handling library
require("beautiful")

-- Notification library
require("naughty")

-- Load Freedesktop.utils Menu Entries
require("freedesktop.utils")
require("freedesktop.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/che/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "geany"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    -- Windows set to float?
    -- awful.layout.suit.floating,
    
    --One Window is Maxed Vertically (Left), rest equally distributed
    awful.layout.suit.tile,
	
	--One Window is Maxed Vertically (Right), rest equally distributed
	--awful.layout.suit.tile.left,
    
    --One Window is Maxed Horizontally (Top), rest equally distributed
    awful.layout.suit.tile.bottom,
	
	--One Window is Maxed Horizontally (Bottom), rest equally distributed
	--awful.layout.suit.tile.top,
    
    --All windows Distributed Equally - Vertical - New Windows on Right
    awful.layout.suit.fair,
    
    --All windows Distributed Equally - Horizontally - New Windows on Bottom
    --awful.layout.suit.fair.horizontal,

--  awful.layout.suit.spiral,
--  awful.layout.suit.spiral.dwindle,
--  awful.layout.suit.max,
--  awful.layout.suit.max.fullscreen,
--  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Start of the TOP Bar Settings
-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
     names  = { "Work", "Productivity", "Fun", "Music" },
     layout = { layouts[3], layouts[3], layouts[3], layouts[3] } }

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout )
end
-- {{{ Change Wallpapers as we move tags
for s = 1, screen.count() do
	for t = 1, 4 do
		tags[s][t]:add_signal("property::selected", function (tag)
			if not tag.selected then return end
			wallpaper_cmd = "feh --bg-fill /home/che/.config/awesome/themes/default/Wallpapers/wallpaper" .. t .. ".jpg"
			awful.util.spawn(wallpaper_cmd)
		end)
	end
end

-- }}}	
-- }}}
-- {{{ Menu
-- Create a laucher widget and a main menu
menu_items = freedesktop.menu.new()
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}
table.insert(menu_items, { "awesome", myawesomemenu } )

mymainmenu = awful.menu.new({ items = menu_items, width = 150 })

-- End Menu }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, " %a %d %b %I:%M ", 1)

-- Creat a Textbox
mytextbox = widget({ type = "textbox" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            -- mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        -- mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        mytextbox,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}
-- End Top Bar Settings}}}

-- {{{ Mouse bindings
--~ root.buttons(awful.util.table.join(
    --~ awful.button({ }, 3, function () mymainmenu:toggle() end),
    --~ awful.button({ }, 8, awful.tag.viewnext),
    --~ awful.button({ }, 9, awful.tag.viewprev)
--~ ))
-- }}}

-- {{{ Keyboard Shortcts
globalkeys = awful.util.table.join(

	-- //Navigate Viewport/Tags on both Monitors//
	-- Move Viewport Forward/Right
	awful.key({ modkey,       }, "`", 
	  function()
	    for i = 1, screen.count() do
	      awful.tag.viewprev(screen[i])
	    end
	  end ),

	--Move Viewport Backward/Left
	awful.key({ modkey,       }, "1", 
	  function()
	    for i = 1, screen.count() do
	      awful.tag.viewnext(screen[i])
	    end
	  end ),
	
	-- Moves Single Tag Left and Right
    --~ awful.key({ modkey, "Control" }, "Left",   awful.tag.viewprev       ),
    --~ awful.key({ modkey, "Control" }, "Right",  awful.tag.viewnext       ),

	--~ Move to previous tag/single screen
    --~ awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

	-- Tab through Maximized windows on single screen/forwards
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    -- Tab through Maximized windows on single screen/backwards
    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    
    --Show application menu
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),
    
    --A simple window picker
    awful.key({ "Mod1",  }, "w", function ()
    -- If you want to always position the menu on the same place set coordinates
    awful.menu.menu_keys.down = { "Down" }
    awful.menu:clients({theme = { width = 250 }}, { keygrabber=true })
		end),
	
	--Initiate Text-to-Speech
    awful.key({ "Control" }, "Escape", function () awful.util.spawn_with_shell("~/Scripts/Espeak.sh") end),
    
    --Stop Text-to-Speech
    awful.key({ "Control", "Shift" }, "Escape", function () awful.util.spawn_with_shell("~/Scripts/StopEspeak.sh") end),
    
    --Shutdown key
    awful.key({}, "XF86Eject", function () awful.util.spawn_with_shell("sudo shutdown -h now") end),
    
    --Volume Keys
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -D pulse set Master 2%+", false) end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -D pulse set Master 2%-", false) end),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer -D pulse set Master Playback Switch toggle", false) end),
	
    --//Layout Manipulation//
    -- Move window forward within screen/Swap positions
    awful.key({ modkey, "Control"   }, "Right", function () awful.client.swap.byidx(  1)    end),
    
    --Move window backward within screen/Swap Positions
    awful.key({ modkey, "Control"   }, "Left", function () awful.client.swap.byidx( -1)    end),
    
    --Change Screen focus/not window forward
    awful.key({ modkey, }, "j", function () awful.screen.focus_relative( 1) end),
    
    --Change Screen focus/not window backward
    --~ awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    
    --Move to urgent window/kind of useless
    --~ awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    
    --Move to previous window/redundant
    --~ awful.key({ modkey,           }, "Tab",
      --~ function ()
             --~ awful.client.focus.history.previous()
             --~ if client.focus then
                 --~ client.focus:raise()
             --~ end
         --~ end),
	


	-- //Standard program Shortcuts//
    
    -- Open a terminal window
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    
    -- Restart Awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    
    --Quit Awesome
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    --Increase Window size when not in Fair
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    
    --Decrease Window size when not in Fair 
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    
    --Increase # of Windows in Master during in non-Fair Layout
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster( 1)      end),
    
    --Decrease # of Windows in Master during in non-Fair Layout
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster(-1)      end),
    
    --Increase number of Columns in non-fair Layout
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol( 1)         end),
    
    -- Decrease number of Columns in non-fair layout
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol(-1)         end),
    
    --Switch Layouts forward
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    
    --Switch Layouts backward
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    --Unminimize/Restore minimized window
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Start Command Run/Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end)

    --//I assume this changes window manager settings
    --~ awful.key({ modkey }, "x",
              --~ function ()
                  --~ awful.prompt.run({ prompt = "Run Lua code: " },
                  --~ mypromptbox[mouse.screen].widget,
                  --~ awful.util.eval, nil,
                  --~ awful.util.getdir("cache") .. "/history_eval")
              --~ end)
)

clientkeys = awful.util.table.join(
    
    --Quit Program
    awful.key({ "Control",        }, "q",      function (c) c:kill()                         end),
    
    --Sets window to Floating/White Bird Icon
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    
    --Sets master window for the layout
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    
    --Moves window to Left or Right Screen
    awful.key({ modkey,           }, "Left",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "Right",      awful.client.movetoscreen                        ),
    
    --Redraw Window
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    
    --Set window the only one visible on tag
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    
    --Toggle Window Fullscreen
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    
    --Minimize Window
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    
    --Maximize Window by floating
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

--////Change Tags on both screens using number row
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        
        -- Change viewport on both screens
        awful.key({ "Mod1" }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            -- awful.tag.viewonly(tags[screen][i])
                            awful.tag.viewonly(tags[1][i])
                            awful.tag.viewonly(tags[2][i])
                        end
                  end),
        
        --Highlight/tag another screen. /useless
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        
        --Moves selected window to another viewport and switches viewports
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                          local screen = mouse.screen
		          if tags[screen][i] then
                              -- awful.tag.viewonly(tags[screen][i])
                            awful.tag.viewonly(tags[1][i])
                            awful.tag.viewonly(tags[2][i])  
                          end
	   	      end	
                  end),
        
        --Sets the tag for the selected window
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },		
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "pinentry", "Gimp" },
      properties = { floating = true } },
-- Set applications to specific tags, Clementine goes to tag 4 of screen 1    
    { rule = { class = "Clementine" },
      properties = { tag = tags[1][4] } },
	{ rule = { instance = "Navigator" },
	  properties = { floating = false } },
	{ rule = { instance = "libreoffice" },
	  properties = { floating = false } },
	{ rule = { class = "Geany" },
	  except = { name = "Find" },
	  properties = { floating = false } },
	{ rule = { instance = "plugin-container" },
	  properties = { floating = true,
					 focus = true } }	  
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    --~ c:add_signal("mouse::enter", function(c)
        --~ if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            --~ and awful.client.focus.filter(c) then
            --~ client.focus = c
        --~ end
    --~ end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Custom Autostart apps
awful.util.spawn_with_shell("xrandr --output DVI-I-3 --rotation left --left-of DVI-I-2")
awful.util.spawn_with_shell("/home/che/Scripts/onelaunchy.sh")
awful.util.spawn_with_shell("dropbox start -i")
awful.util.spawn_with_shell("xset s off")
awful.util.spawn_with_shell("mintupdate-launcher")
awful.util.spawn_with_shell("/home/che/Scripts/onewicd.sh")
awful.util.spawn_with_shell("xbindkeys_autostart")
awful.util.spawn_with_shell("start-pulseaudio-x11")
awful.util.spawn_with_shell("xfce4-power-manager")
awful.util.spawn_with_shell("xfsettingsd")
awful.util.spawn_with_shell("clementine")
awful.util.spawn_with_shell("firefox")
awful.util.spawn_with_shell("/home/che/Scripts/cloudbackups.sh")
--awful.util.spawn_with_shell("")
-- }}}
