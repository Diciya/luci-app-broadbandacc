module("luci.controller.broadband", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/broadband") then
		return
	end
	
	entry({"admin", "services", "broadband"}, alias("admin", "services", "broadband", "general"), _("Broadband"), 90).dependent = true
	entry({"admin", "services", "broadband", "general"}, cbi("broadband"), _("Settings"), 1).leaf = true
	entry({"admin", "services", "broadband", "shop"}, template("broadband/shopview"), _("Shop"), 2).leaf = true
	entry({"admin", "services", "broadband", "log"}, template("broadband/logview"), _("Log"), 3).leaf = true
	entry({"admin", "services", "broadband", "status"}, call("action_status")).leaf = true
	entry({"admin", "services", "broadband", "logdata"}, call("action_log")).leaf = true	
end

local function bdacc_running()
	return luci.sys.call("(ps | grep broadband.sh | grep -v 'grep') >/dev/null" ) == 0
end

function action_status()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		run_state = bdacc_running(),
		down_state = nixio.fs.readfile("/var/state/broadband_down_state") or "",
		up_state = nixio.fs.readfile("/var/state/broadband_up_state") or ""
	})
end

function action_log()
	local uci = require "luci.model.uci".cursor()
	local util = require "luci.util"
	local log_data = { }

	log_data.syslog = util.trim(util.exec("logread | grep broadband"))
	if uci:get("broadband", "general", "logging") ~= "0" then
		log_data.client = nixio.fs.readfile("/var/log/broadband.log") or ""
	end
	uci:unload("broadband")

	luci.http.prepare_content("application/json")
	luci.http.write_json(log_data)
end
