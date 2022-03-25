--[[
	SysTimeTimers b1.0

	Functions:
		- systimetimers.Create( string timerName, number timerDelay, number timerRepeat, function timerFunction, boolean pauseOnRun )
		- .Destroy ( string timerName )
		- .Remove ( string timerName )
		- .Pause ( string timerName )
		- .Resume ( string timerName )
		- .Simple ( string timerName, function timerFunction )
		- .Toggle ( string timerName )
		- .GetQueue() - This contains all the timers with all their statuses and whatnot, don't modify these values unless you know what you're doing!

	todo:
		- Add all of the functions from timer.*
		- Better error handling
		- (M) make in C++

]]

AddCSLuaFile() -- ;(
module("systimetimers", package.seeall)

if SERVER then
	CreateConVar("stt_ignore_hibernation_warning", 0, nil, "If set to 1, will not show a warning about hibernation on timer creation", 0, 1)
end

systimetimers.Queue = {

}

function systimetimers.GetQueue()
	return systimetimers.Queue or {}
end

function systimetimers.Create(timerName, timerDelay, timerRepeat, timerFunction, pauseOnRun)
	if not timerName then error("[SysTimeTimers] You didn't specify a timer name!") return end
	if not timerDelay then error("[SysTimeTimers] You didn't specify a timer delay!") return end
	if not timerRepeat then error("[SysTimeTimers] You didn't specify a timer repeat amount (0 = Infinite)!") return end
	if not timerFunction then error("[SysTimeTimers] You didn't specify a timer function!") return end

	if timerRepeat <= 0 then timerRepeat = math.huge end

	systimetimers.Queue[timerName] = {
		["RunEvery"] = math.Clamp(timerDelay, 0.01, math.huge),
		["LastRun"] = SysTime(),
		["RunAmount"] = timerRepeat,
		["RunAmountTotal"] = 0,
		["Paused"] = pauseOnRun or false,
		["Func"] = timerFunction
	}

	if SERVER then
		if (GetConVar_Internal("stt_ignore_hibernation_warning"):GetString() ~= "1") and (GetConVar_Internal("sv_hibernate_think"):GetString() ~= "1") then
			ErrorNoHalt("[SysTimeTimers - WARN] Please ensure \"sv_hibernate_think\" is set to \"1\" as timers will not progress when the server is empty, you can also use stt_ignore_hibernation_warning 1 to disable this warning!")
		end
	end
end

function systimetimers.Destroy(timerName)
	if not timerName then error("[SysTimeTimers] You didn't specify a timer name!") return end
	if not systimetimers.Queue[timerName] then error(string.format("[SysTimeTimers] There is no timer named \"%s\"", tostring(timerName))) return end

	table.Empty(systimetimers.Queue[timerName])
	systimetimers.Queue[timerName] = nil
	collectgarbage("collect")
end

systimetimers.Remove = systimetimers.Destroy

function systimetimers.Pause(timerName)
	if not timerName then error("[SysTimeTimers] You didn't specify a timer name!") return end
	if not systimetimers.Queue[timerName] then error(string.format("[SysTimeTimers] There is no timer named \"%s\"", tostring(timerName))) return end

	systimetimers.Queue[timerName]["Paused"] = true
end

function systimetimers.Resume(timerName)
	if not timerName then error("[SysTimeTimers] You didn't specify a timer name!") return end
	if not systimetimers.Queue[timerName] then error(string.format("[SysTimeTimers] There is no timer named \"%s\"", tostring(timerName))) return end

	systimetimers.Queue[timerName]["Paused"] = false
end

function systimetimers.Toggle(timerName)
	if not timerName then error("[SysTimeTimers] You didn't specify a timer name!") return end
	if not systimetimers.Queue[timerName] then error(string.format("[SysTimeTimers] There is no timer named \"%s\"", tostring(timerName))) return end

	systimetimers.Queue[timerName]["Paused"] = (not systimetimers.Queue[timerName]["Paused"])
end

function systimetimers.Simple(timerDelay, timerFunction)
	if not timerDelay then error("[SysTimeTimers] You didn't specify a timer delay!") return end
	if not timerFunction then error("[SysTimeTimers] You didn't specify a timer function!") return end

	systimetimers.Create("_stt_simple_"..tostring(SysTime())..tostring(math.random()), timerDelay, 1, timerFunction, false)
end

local function systimetimers_doTimers()
	for k, v in pairs(systimetimers.Queue) do
		if v["Paused"] then return end
		local nextRun = v["LastRun"] + v["RunEvery"]
		if SysTime() >= nextRun then
			v["LastRun"] = SysTime()
			v["RunAmountTotal"] = v["RunAmountTotal"] + 1
			
			local t_s, t_o = pcall(function()
				v["Func"]()
			end)

			if t_s ~= true then
				systimetimers.Destroy(k)
				ErrorNoHaltWithStack(string.format("SysTimeTimers Error: %s", tostring(t_o)))
				return
			end

			if v["RunAmountTotal"] >= v["RunAmount"] then
				systimetimers.Destroy(k)
			end
		end
	end
end

hook.Add("Think", "_systimers_doTimers_", systimetimers_doTimers)
