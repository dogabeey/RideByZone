local prefix = "rbz__"

local ok = C_ChatInfo.RegisterAddonMessagePrefix(prefix)

SLASH_RBZ1 = "/ridebyzone"
SLASH_RBZ2 = "/rbz"

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON_LOGGED")
frame:RegisterEvent("PARTY_LEADER_CHANGED")
frame:RegisterEvent("ADDON_LOADED")

function SlashCmdList.RBZ(msg,editbox)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	if(cmd) then
		if(cmd == "mount") then
			local favMount = RBZ_GLOB[C_Map.GetBestMapForUnit("player")]
			if favMount then
				C_MountJournal.SummonByID(favMount)
			else
				SendSystemMessage("You have not set a favorite mount for this zone yet, so a favorite random mount will be summoned instead. type '/rbz add' while mounted to define your current mount as favorite.")
				C_MountJournal.SummonByID(0)
			end
		elseif(cmd == "add") then
			local mountID = GetMountID()
			if mountID then
				RBZ_GLOB[C_Map.GetBestMapForUnit("player")] = mountID
			end
		elseif(cmd == "help") then
			SendSystemMessage("/rbz add: Assign your active mount for the map you're in.\n/rbz mount: Summon the mount that is assigned for the current map. If none set, a favorite random mount will be summoned instead.")
		else
			SendSystemMessage("There is no such sub-command.")
		end
	else
	end
end

function GetMountID()
	local mountIDs = C_MountJournal.GetMountIDs()
	for _,k in ipairs(mountIDs) do 
		local mountName, spellID = C_MountJournal.GetMountInfoByID(k)
		for i = 1,40 do
			if select(10,UnitBuff("player", i)) == spellID then
				print(k .. " " .. mountName)
				return k
			end
		end
	end
	SendSystemMessage("You are not mounted.")
	return nil
end

function DefineConfig(args)
	if(args[1]) then
		local found = nil
		args[1] = string.upper(args[1])
		for k, v in pairs(RBZ_GLOB_LIST) do
			if (v == args[1]) then
				found = v
				break 
			end
		end
		if(found) then
			local data = SeperateString(found,".")
			local real_data = nil
			if(data[4]) then
				real_data = RBZ_GLOB[data[1]][data[2]][data[3]][data[4]]
			elseif(data[3]) then
				real_data = RBZ_GLOB[data[1]][data[2]][data[3]]
			elseif(data[2]) then
				real_data = RBZ_GLOB[data[1]][data[2]]
			elseif(data[1]) then
				real_data = RBZ_GLOB[data[1]]
			end
			if(args[2]) then
				if(data[4]) then
					RBZ_GLOB[data[1]][data[2]][data[3]][data[4]] = args[2]
				elseif(data[3]) then
					RBZ_GLOB[data[1]][data[2]][data[3]] = args[2]
				elseif(data[2]) then
					RBZ_GLOB[data[1]][data[2]]= args[2]
				elseif(data[1]) then
					RBZ_GLOB[data[1]]= args[2]
				end
				SendSystemMessage("Changed " .. args[1] .. " value to " .. args[2])
			else
				SendSystemMessage(args[1] .. ": " .. real_data)
			end
		else
			SendSystemMessage("There is no such configuration.")
		end
	else
		SendSystemMessage("|cff1ec456Syntax: rbz config <config_string> [<new_value>]. You can find config strings under <addonFolder>/definitions.lua (Type without RBZ_GLOB. part).|r")
	end
end

function PrintTable(tab)
	local text = ""
	for k,v in pairs(tab) do
		text = text .. v
	end
	return text
end

function SeperateString(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={} ; local i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end
