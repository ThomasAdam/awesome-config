-- default rc.lua for shifty
--
-- Standard awesome library
require("awful")
require("awful.autofocus")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- shifty - dynamic tagging library
require("shifty")
require("teardrop")
require("obvious.popup_run_prompt")
obvious.popup_run_prompt.set_prompt_string("Run: ")

-- useful for debugging, marks the beginning of rc.lua exec
print("Entered rc.lua: " .. os.time())

-- Variable definitions
-- Themes define colours, icons, and wallpapers
-- The default is a dark theme
theme_path = "/global/users/thomas/.config/awesome/themes/fence/theme.lua"
-- Uncommment this for a lighter theme
-- theme_path = "/usr/share/awesome/themes/sky/theme"

-- Actually load theme
beautiful.init(theme_path)

-- This is used later as the default terminal and editor to run.
browser = "chrome"
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key, I suggest you to remap
-- Mod4 to another key using xmodmap or other tools.  However, you can use
-- another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.fair,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false

-- Shifty configured tags.
shifty.config.tags = {
	web = {
		layout      = layouts[2],
		mwfact    = 0.50,
		exclusive   = false,
		position    = 1,
		screen      = 1,
		init	    = true,
		leave_kills = true,
	},
	main = {
		layout    = layouts[2],
		mwfact    = 0.50,
		exclusive = false,
		position  = 2,
		slave     = true,
		screen    = 2,
		init      = true,
		leave_kills = true,
	},
	chat = {
		layout	  = layouts[5],
		position  = 3,
		screen    = 2,
		init      = true,
		leave_kills = true,
	},
	media = {
		layout    = layouts[1],
		exclusive = false,
		position  = 4,
		screen    = 1,
		init      = true
	},
	office = {
		layout	  = awful.layout.suit.float,
		exclusive = false,
		position  = 5,
		screen    = 2,
		init	  = true,
		leave_kills = true
	},
	VBox = {
		layout	  = awful.layout.suit.float,
		exclusive = false,
		position  = 6,
		screen    = 2,
		init	  = true,
		leave_kills = true
	}
}

-- SHIFTY: application matching rules
-- order here matters, early rules will be applied first
shifty.config.apps = {
	{
		match = {
			"Chrome",
			"Navigator",
			"Vimperator",
			"Gran Paradiso",
		},
		tag = "web",
		slave = true,
		float = false,
	},
	{
		match = {
			"Mplayer.*",
		},
		tag = "media",
		nopopup = true,
	},
	{
		match = {
			"MPlayer",
			"Gnuplot",
			"galculator",
		},
		float = true,
	},
	{
		match = {
			"irc.*",
		},
		tag = "chat",
		nopopup = "true"
	},
	{
		match = {
			terminal,
		},
		honorsizehints = false,
		slave = true
	},
	{
		-- float rules.
		match = {
			"Npviewer.bin",
			"Xchat",
			"XConsole",
			"Agave",
		},
		float = true,
	},
	{
		match = {""},
		buttons = awful.util.table.join(
		awful.button({}, 1, function (c) client.focus = c; c:raise() end),
		awful.button({modkey}, 1, function(c)
			client.focus = c
			c:raise()
			awful.mouse.client.move(c)
		end),
		awful.button({modkey}, 3, awful.mouse.client.resize)
		)
	},
}

-- SHIFTY: default tag creation rules
-- parameter description
--  * floatBars : if floating clients should always have a titlebar
--  * guess_name : should shifty try and guess tag names when creating
--                 new (unconfigured) tags?
--  * guess_position: as above, but for position parameter
--  * run : function to exec when shifty creates a new tag
--  * all other parameters (e.g. layout, mwfact) follow awesome's tag API
shifty.config.defaults = {
	layout = awful.layout.suit.floating,
	ncol = 1,
	guess_name = true,
	guess_position = true,
	init = true
}

--  Wibox
-- Create a textbox widget
mytextclock = awful.widget.textclock({align = "right"},
	'<span background="#0B00A3" color="white">%a %b %d, %H:%M</span>')
spacer       = widget({ type = "textbox"  })
spacer.text  = '<span color="white">|</span>'

-- Create a systray
mysystray = widget({type = "systray", align = "right"})

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({}, 1, awful.tag.viewonly),
awful.button({modkey}, 1, awful.client.movetotag),
awful.button({}, 3, function(tag) tag.selected = not tag.selected end),
awful.button({modkey}, 3, awful.client.toggletag),
awful.button({}, 4, awful.tag.viewnext),
awful.button({}, 5, awful.tag.viewprev)
)

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({}, 1, function(c)
	if c == client.focus then
		c.minimized = true
	else
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		client.focus = c
		c:raise()
	end
end),
awful.button({}, 3, function()
	if instance then
		instance:hide()
		instance = nil
	else
		instance = awful.menu.clients({width=250})
	end
end),
awful.button({}, 4, function()
	awful.client.focus.byidx(1)
	if client.focus then client.focus:raise() end
end),
awful.button({}, 5, function()
	awful.client.focus.byidx(-1)
	if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] =
	awful.widget.prompt({layout = awful.widget.layout.leftright})
	-- Create an imagebox widget which will contains an icon indicating which
	-- layout we're using.  We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
	awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
	awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
	awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
	awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s,
	awful.widget.taglist.label.all,
	mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist.new(function(c)
		return awful.widget.tasklist.label.currenttags(c, s)
	end,
	mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({position = "top", screen = s, height = 16})
	-- Add widgets to the wibox - order matters
	mywibox[s].widgets = {
		{
			mytaglist[s],
			spacer,
			layout = awful.widget.layout.horizontal.leftright
		},
		mylayoutbox[s],
		spacer,
		mytextclock,
		s == 1 and mysystray or nil,
		s == 2 and nil or spacer,
		mytasklist[s],
		spacer,
		layout = awful.widget.layout.horizontal.rightleft
	}

	mywibox[s].screen = s
end

-- SHIFTY: initialize shifty
-- the assignment of shifty.taglist must always be after its actually
-- initialized with awful.widget.taglist.new()
shifty.taglist = mytaglist
shifty.init()

-- Mouse bindings
root.buttons(awful.util.table.join(
awful.button({}, 4, awful.tag.viewnext),
awful.button({}, 5, awful.tag.viewprev)
))

-- Key bindings
globalkeys = awful.util.table.join(
-- Tags
awful.key({modkey, "Control"}, "Left", awful.tag.viewprev),
awful.key({modkey, "Control"}, "Right", awful.tag.viewnext),
awful.key({modkey,}, "Escape", awful.tag.history.restore),

-- Shifty: keybindings specific to shifty
awful.key({modkey, "Shift"}, "d", shifty.del), -- delete a tag
awful.key({modkey, "Shift"}, "n", shifty.send_prev), -- client to prev tag
awful.key({modkey}, "n", shifty.send_next), -- client to next tag
awful.key({modkey, "Control"},
"n",
function()
	local t = awful.tag.selected()
	local s = awful.util.cycle(screen.count(), t.screen + 1)
	awful.tag.history.restore()
	t = shifty.tagtoscr(s, t)
	awful.tag.viewonly(t)
end),
awful.key({modkey}, "a", shifty.add), -- creat a new tag
awful.key({modkey,}, "r", shifty.rename), -- rename a tag
awful.key({modkey,}, "z", shifty.shift_prev), -- shift tag left
awful.key({modkey,}, "x", shifty.shift_next), -- shift tag right


awful.key({modkey,}, "j",
function()
	awful.client.focus.byidx(1)
	if client.focus then client.focus:raise() end
end),
awful.key({modkey,}, "k",
function()
	awful.client.focus.byidx(-1)
	if client.focus then client.focus:raise() end
end),

-- Layout manipulation
awful.key({modkey, "Shift"}, "j",
function() awful.client.swap.byidx(1) end),
awful.key({modkey, "Shift"}, "k",
function() awful.client.swap.byidx(-1) end),
awful.key({modkey, "Control"}, "j", function() awful.screen.focus(1) end),
awful.key({modkey, "Control"}, "k", function() awful.screen.focus(2) end),
awful.key({modkey,}, "u", awful.client.urgent.jumpto),
awful.key({modkey,}, "Tab",
function()
	awful.client.focus.history.previous()
	if client.focus then
		client.focus:raise()
	end
end),

-- Standard program
awful.key({modkey,}, "Return", function() awful.util.spawn(terminal) end),
awful.key({modkey,}, "/", function () teardrop("xterm -e 'tmux -2 -u a -tspecial'", "top", 0.5 ) end),
awful.key({modkey, "Control"}, "r", awesome.restart),
awful.key({modkey, "Shift"}, "q", awesome.quit),

awful.key({modkey,}, "l", function() awful.tag.incmwfact(0.05) end),
awful.key({modkey,}, "h", function() awful.tag.incmwfact(-0.05) end),
awful.key({modkey, "Shift"}, "h", function() awful.tag.incnmaster(1) end),
awful.key({modkey, "Shift"}, "l", function() awful.tag.incnmaster(-1) end),
awful.key({modkey, "Control"}, "h", function() awful.tag.incncol(1) end),
awful.key({modkey, "Control"}, "l", function() awful.tag.incncol(-1) end),
awful.key({modkey,}, "space", function() awful.layout.inc(layouts, 1) end),
awful.key({modkey, "Shift"}, "space",
function() awful.layout.inc(layouts, -1) end),

awful.key({ modkey, "Control" }, "x", obvious.popup_run_prompt.run_prompt),
awful.key({ modkey }, "F7", function() awful.util.spawn("amixer set Master toggle") end),
awful.key({ modkey }, "F8", function() awful.util.spawn("mpc prev") end),
awful.key({ modkey }, "F9", function() awful.util.spawn("mpc next") end),
awful.key({ modkey }, "F10", function() awful.util.spawn("mpc toggle") end),
awful.key({ modkey }, "F11", function() awful.util.spawn("amixer set Master 2-") end),
awful.key({ modkey }, "F12", function() awful.util.spawn("amixer set Master 2+") end)
)
-- Prompt
--awful.key({modkey, "Control"}, "x", function()
--    awful.prompt.run({prompt = "Run: "},
--    mypromptbox[mouse.screen].widget,
--    awful.util.spawn, awful.completion.shell,
--    awful.util.getdir("cache") .. "/history")
--    end)
--)

-- Client awful tagging: this is useful to tag some clients and then do stuff
-- like move to tag on them
clientkeys = awful.util.table.join(
awful.key({modkey,}, "f", function(c) c.fullscreen = not c.fullscreen  end),
awful.key({modkey, "Shift"}, "a", function(c) c:kill() end),
awful.key({modkey, "Control"}, "space", awful.client.floating.toggle),
awful.key({modkey, "Control"}, "Return",
function(c) c:swap(awful.client.getmaster()) end),
awful.key({modkey,}, "o", awful.client.movetoscreen),
awful.key({modkey, "Shift"}, "r", function(c) c:redraw() end),
awful.key({modkey}, "t", awful.client.togglemarked),
awful.key({modkey,}, "m",
function(c)
	c.maximized_horizontal = not c.maximized_horizontal
	c.maximized_vertical   = not c.maximized_vertical
end)
)

-- SHIFTY: assign client keys to shifty for use in
-- match() function(manage hook)
shifty.config.clientkeys = clientkeys
shifty.config.modkey = modkey

-- Compute the maximum number of digit we need, limited to 9
for i = 1, (shifty.config.maxtags or 9) do
	globalkeys = awful.util.table.join(globalkeys,
	awful.key({modkey}, i, function()
		local t =  awful.tag.viewonly(shifty.getpos(i))
	end),
	awful.key({modkey, "Control"}, i, function()
		local t = shifty.getpos(i)
		t.selected = not t.selected
	end),
	awful.key({modkey, "Control", "Shift"}, i, function()
		if client.focus then
			awful.client.toggletag(shifty.getpos(i))
		end
	end),
	-- move clients to other tags
	awful.key({modkey, "Shift"}, i, function()
		if client.focus then
			t = shifty.getpos(i)
			awful.client.movetotag(t)
			awful.tag.viewonly(t)
		end
	end))
end

-- Set keys
root.keys(globalkeys)

-- Hook function to execute when focusing a client.
client.add_signal("focus", function(c)
	if not awful.client.ismarked(c) then
		c.border_color = beautiful.border_focus
	end
end)

-- Hook function to execute when unfocusing a client.
client.add_signal("unfocus", function(c)
	if not awful.client.ismarked(c) then
		c.border_color = beautiful.border_normal
	end
end)
