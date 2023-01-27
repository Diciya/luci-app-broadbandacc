local m, s, o
local uci = luci.model.uci.cursor()

m = Map("broadband", "%s - %s" %{translate("Broadband"), translate("Settings")}, translate("The network speed-up service is provided by the speed test network, with uplink and downlink speed-up functions, and the plug-in has the function of network uninterrupted acceleration."))
m:append(Template("broadband/status"))

s = m:section(NamedSection, "general", "general", translate("General Settings"))
s.anonymous = true
s.addremove = false

button_restart = s:option (Button, "_button_restart", translate("重启插件")) 
button_restart.inputtitle = translate ( "点击重启")
button_restart.inputstyle = "apply" 
function button_restart.write (self, section, value)
	luci.sys.call ( "/etc/init.d/broadband restart > /dev/null")
end 

button_cleanlog = s:option (Button, "_button_cleanlog", translate("日志清理")) 
button_cleanlog.inputtitle = translate ( "点击清理")
button_cleanlog.inputstyle = "apply" 
function button_cleanlog.write (self, section, value)
	luci.sys.call ( "cat /dev/null > /var/log/broadband.log > /dev/null")
end 

o = s:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s:option(Flag, "logging", translate("Enable Logging"))

o = s:option(ListValue, "network", translate("Upgrade interface"),translate("It is not recommended to increase the speed of non-dial-up interfaces, and the acceleration may be interrupted"))
uci:foreach("network","interface",function(section)
	if section[".name"]~="loopback" then
		o:value(section[".name"])
	end
end)

s:option(Flag, "more", translate("More Options"),
	translate("Options for advanced users"))
	
o = s:option(Flag, "verbose", translate("Enable verbose logging"))
o:depends("more", 1)

return m
