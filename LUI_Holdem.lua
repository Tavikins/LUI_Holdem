-----------------------------------------------------------------------------------------------
-- Client Lua Script for LUI_Hold'em
-- Copyright (c) NCsoft. All rights reserved
-- Made by Loui NaN
-- Proud Warrior of Bloodpact on EU-Jabbit
-----------------------------------------------------------------------------------------------

require "Window"
require "Apollo"
require "Unit"
require "GameLib"
require "GroupLib"
require "GuildLib"
require "ICCommLib"
require "ICComm"
require "MailSystemLib"
require "ChatSystemLib"
require "ChatChannelLib"
require "Sound"

local LUI_Holdem = {}
local JSON = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage
local card = Apollo.GetPackage("Holdem:Card").tPackage
local lookup = Apollo.GetPackage("Holdem:Lookup").tPackage
local analysis = Apollo.GetPackage("Holdem:Analysis").tPackage

function LUI_Holdem:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.version = 1.01
    self.defaults = {
    	["blinds"] = 100,
    	["cash"] = 10000000,
	}
    self.active = false
    self.keys = {}
	self.guild = {}
    self.settings = {
        ["hide"] = true,
        ["combat"] = true,
        ["alert"] = true,
        ["sound"] = true,
        ["check"] = false,
    }
    self.game = {}
    self.cards = {}
	self.validcards = {}
    self.colors = {
        ["fold"] = "xkcdDarkRed",
        ["check"] = "xkcdDarkYellow",
        ["call"] = "xkcdDirtyBlue",
        ["raise"] = "xkcdFrogGreen",
        ["all in"] = "xkcdFrogGreen",
        ["won"] = "xkcdYellowishGreen",
        ["side"] = "xkcdRustyOrange",
    }
    self.welcome = {
        [1] = "Huhu!",
        [2] = "Good evening!",
        [3] = "Hi!",
        [4] = "Greetings!",
        [5] = "Hello!",
        [6] = "Yo!",
        [7] = "Howdy!",
        [8] = "Sup?",
        [9] = "Look who it is!",
        [10] = "Hey there!"
    }
    self.levels = {
    	[1] = {
    		blind = 1,
    		ante = false,
    	},
    	[2] = {
    		blind = 2,
    		ante = false,
    	},
    	[3] = {
    		blind = 4,
    		ante = false,
    	},
    	[4] = {
    		blind = 6,
    		ante = 12,
    	},
    	[5] = {
    		blind = 8,
    		ante = 8,
    	},
    	[6] = {
    		blind = 12,
    		ante = 8,
    	},
    	[7] = {
    		blind = 16,
    		ante = 8,
    	},
    	[8] = {
    		blind = 24,
    		ante = 6,
    	},
    	[9] = {
    		blind = 32,
    		ante = 5.333333333,
    	},
    	[10] = {
    		blind = 40,
    		ante = 5,
    	},
    	[11] = {
    		blind = 60,
    		ante = 6,
    	},
    	[12] = {
    		blind = 80,
    		ante = 8,
    	},
    	[13] = {
    		blind = 120,
    		ante = 6,
    	},
    	[14] = {
    		blind = 160,
    		ante = 8,
    	},
    	[15] = {
    		blind = 240,
    		ante = 6,
    	},
	}

    self.players = {
        [1] = {
            active = false
        },
        [2] = {
            active = false
        },
        [3] = {
            active = false
        },
        [4] = {
            active = false
        },
        [5] = {
            active = false
        },
        [6] = {
            active = false
        },
        [7] = {
            active = false
        },
        [8] = {
            active = false
        },
        [9] = {
            active = false
        },
        [10] = {
            active = false
        },
    }

    self.playerFrames = {
    	[1] = {
    		anchorPoints = {0.6,0,0.6,0},
    		anchorOffsets = {-134,0,126,180},
    		cardPosition = "Bottom",
    	},
    	[2] = {
    		anchorPoints = {1,0,1,0},
    		anchorOffsets = {-400,70,-140,250},
    		cardPosition = "Bottom",
    	},
    	[3] = {
    		anchorPoints = {1,0.5,1,0.5},
    		anchorOffsets = {-270,-110,-10,70},
    		cardPosition = "Top",
    	},
    	[4] = {
    		anchorPoints = {1,1,1,1},
    		anchorOffsets = {-400,-250,-140,-70},
    		cardPosition = "Top",
    	},
    	[5] = {
    		anchorPoints = {0.6,1,0.6,1},
    		anchorOffsets = {-134,-180,126,0},
    		cardPosition = "Top",
    	},
    	[6] = {
    		anchorPoints = {0.4,1,0.4,1},
    		anchorOffsets = {-126,-180,134,0},
    		cardPosition = "Top",
    	},
    	[7] = {
    		anchorPoints = {0,1,0,1},
    		anchorOffsets = {140,-250,400,-70},
    		cardPosition = "Top",
    	},
    	[8] = {
    		anchorPoints = {0,0.5,0,0.5},
    		anchorOffsets = {10,-110,270,70},
    		cardPosition = "Top",
    	},
    	[9] = {
    		anchorPoints = {0,0,0,0},
    		anchorOffsets = {140,70,400,250},
    		cardPosition = "Bottom",
    	},
    	[10] = {
    		anchorPoints = {0.4,0,0.4,0},
    		anchorOffsets = {-126,0,134,180},
    		cardPosition = "Bottom",
    	},
	}

	self.buttons = {
		colors = {
			red = "xkcdDullRed",
			blue = "UI_WindowTextCraftingBlueResistor",
			yellow = "xkcdDullYellow",
		},
		positions = {
			[1] = {
                anchorPoints = {0.55,0.15,0.55,0.15},
                anchorOffsets = {-47,0,-11,36},
            },
            [2] = {
                anchorPoints = {0.8,0.35,0.8,0.35},
                anchorOffsets = {-98,-57,-62,-21},
            },
            [3] = {
                anchorPoints = {0.8,0.5,0.8,0.5},
                anchorOffsets = {-32,-18,4,18},
            },
            [4] = {
                anchorPoints = {0.8,0.65,0.8,0.65},
                anchorOffsets = {-108,31,-72,67},
            },
            [5] = {
                anchorPoints = {0.55,0.8,0.55,0.8},
                anchorOffsets = {-47,-36,-11,0},
            },
            [6] = {
                anchorPoints = {0.45,0.8,0.45,0.8},
                anchorOffsets = {11,-36,47,0},
            },
            [7] = {
                anchorPoints = {0.2,0.65,0.2,0.65},
                anchorOffsets = {72,31,108,67},
            },
            [8] = {
                anchorPoints = {0.2,0.5,0.2,0.5},
                anchorOffsets = {-4,-18,32,18},
            },
            [9] = {
                anchorPoints = {0.2,0.35,0.2,0.35},
                anchorOffsets = {72,-67,-108,-31},
            },
            [10] = {
                anchorPoints = {0.45,0.15,0.45,0.15},
                anchorOffsets = {11,0,47,36},
            }
		}
	}

	self.cash = {
		[1] = {
    		anchorPoints = {0.6,0.35,0.6,0.35},
    		anchorOffsets = {-134,-45,-4,-15},
    	},
    	[2] = {
    		anchorPoints = {0.75,0.35,0.75,0.35},
    		anchorOffsets = {-205,-15,-45,15},
    	},
    	[3] = {
    		anchorPoints = {0.75,0.5,0.75,0.5},
    		anchorOffsets = {-155,-15,5,15},
    	},
    	[4] = {
    		anchorPoints = {0.75,0.65,0.75,0.65},
    		anchorOffsets = {-205,-15,-45,15},
    	},
    	[5] = {
    		anchorPoints = {0.6,0.65,0.6,0.65},
    		anchorOffsets = {-134,16,-4,46},
    	},
    	[6] = {
    		anchorPoints = {0.4,0.65,0.4,0.65},
    		anchorOffsets = {-86,16,34,46},
            grow = true,
    	},
    	[7] = {
    		anchorPoints = {0.25,0.65,0.25,0.65},
    		anchorOffsets = {-55,-15,80,15},
            grow = true,
    	},
    	[8] = {
    		anchorPoints = {0.25,0.5,0.25,0.5},
    		anchorOffsets = {-85,-15,30,15},
            grow = true,
    	},
    	[9] = {
    		anchorPoints = {0.25,0.35,0.25,0.35},
    		anchorOffsets = {-55,-15,80,15},
            grow = true,
    	},
    	[10] = {
    		anchorPoints = {0.4,0.35,0.4,0.35},
    		anchorOffsets = {-86,-45,34,-15},
            grow = true,
    	},
	}

	self.seats = {
    	[1] = {
    		anchorPoints = {0.6,0,0.6,0},
    		anchorOffsets = {-74,90,76,134},
    	},
    	[2] = {
    		anchorPoints = {1,0,1,0},
    		anchorOffsets = {-340,130,-190,174},
    	},
    	[3] = {
    		anchorPoints = {1,0.5,1,0.5},
    		anchorOffsets = {-260,-22,-110,22},
    	},
    	[4] = {
    		anchorPoints = {1,1,1,1},
    		anchorOffsets = {-340,-174,-190,-130},
    	},
    	[5] = {
    		anchorPoints = {0.6,1,0.6,1},
    		anchorOffsets = {-74,-134,76,-90},
    	},
    	[6] = {
    		anchorPoints = {0.4,1,0.4,1},
    		anchorOffsets = {-76,-134,74,-90},
    	},
    	[7] = {
    		anchorPoints = {0,1,0,1},
    		anchorOffsets = {190,-174,340,-130},
    	},
    	[8] = {
    		anchorPoints = {0,0.5,0,0.5},
    		anchorOffsets = {110,-22,260,22},
    	},
    	[9] = {
    		anchorPoints = {0,0,0,0},
    		anchorOffsets = {190,130,340,174},
    	},
    	[10] = {
    		anchorPoints = {0.4,0,0.4,0},
    		anchorOffsets = {-76,90,74,134},
    	},
	}

    return o
end

function LUI_Holdem:Init()
    local tDependencies = {
        "ChatLog",
        "BetterChatLog",
        "ChatFixed",
        "ImprovedChatLog",
        "FixedChatLog",
        "ChatAdvanced",
        "ChatSplitter",
        "ChatLinks"
    }

	Apollo.RegisterAddon(self, nil, nil, tDependencies)
end

function LUI_Holdem:OnDependencyError(strDependency, strError)
    -- ignore dependency errors, because we only did set dependecies to ensure to get loaded after the specified addons
    return true
end

function LUI_Holdem:OnLoad()
	Apollo.LoadSprites("cards.xml")
	Apollo.LoadSprites("tables.xml")
	Apollo.LoadSprites("sprites.xml")

	self.xmlDoc = XmlDoc.CreateFromFile("LUI_Holdem.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterCreated", self)
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
	Apollo.RegisterEventHandler("ToggleLUIHoldem", "OnToggleMenu", self)
	Apollo.RegisterEventHandler("GuildRoster", "OnGuildRoster", self)
	Apollo.RegisterEventHandler("UnitEnteredCombat", "OnEnteredCombat", self)
	Apollo.RegisterEventHandler("ChatMessage", "OnChatMessage", self)
    Apollo.RegisterEventHandler("PlayerCurrencyChanged", "OnPlayerCurrencyChanged", self)

	Apollo.RegisterTimerHandler("LUI_Holdem_Connect", "Connect", self)
	Apollo.RegisterTimerHandler("LUI_Holdem_Connect_Game", "ConnectToHost", self)
	Apollo.RegisterTimerHandler("LUI_Holdem_JoinGlobal", "JoinGlobalChannel", self)
    Apollo.RegisterTimerHandler("LUI_Holdem_JoinChat", "JoinChatChannel", self)
    Apollo.RegisterTimerHandler("LUI_Holdem_JoinGame", "OnJoinWait", self)
	Apollo.RegisterTimerHandler("LUI_Holdem_Join", "JoinChannel", self)
	Apollo.RegisterTimerHandler("LUI_Holdem_Notification", "OnNotification", self)
    Apollo.RegisterTimerHandler("LUI_Holdem_Alert", "OnAlert", self)
    Apollo.RegisterTimerHandler("LUI_Holdem_Wait", "OnWait", self)
    Apollo.RegisterTimerHandler("LUI_Holdem_Next", "OnNextPlayer", self)
    Apollo.RegisterTimerHandler("LUI_Holdem_Showdown", "OnShowdownTimer", self)

	self.broadcast = ApolloTimer.Create(30, true, "Broadcast", self)
	self.broadcast:Stop()
end

function LUI_Holdem:OnDocLoaded()
	if self.xmlDoc == nil then
		return
	end

    -- Load Defaults
    self:LoadDefaults()

	Apollo.RegisterSlashCommand("poker", "OnSlashCommand", self)

	local player = GameLib.GetPlayerUnit()

	if player ~= nil then
		self.name = player:GetName()
	end

    aChatLog = Apollo.GetAddon("ChatLog")

    if not aChatLog then
        aChatLog = Apollo.GetAddon("BetterChatLog")
    end

    if not aChatLog then
        aChatLog = Apollo.GetAddon("ChatFixed")
    end

    if not aChatLog then
        aChatLog = Apollo.GetAddon("ImprovedChatLog")
    end

    if not aChatLog then
        aChatLog = Apollo.GetAddon("FixedChatLog")
    end

    if aChatLog and aChatLog.OnChatMessage then
        fChatLog_OnChatMessage = aChatLog.OnChatMessage
        aChatLog.OnChatMessage = self.ChatLog_OnChatMessage
    end

    -- Find Default Chat Channels
    for idx, channelCurrent in ipairs(ChatSystemLib.GetChannels()) do
        if channelCurrent:GetName() == "Loot" then
            self.say = channelCurrent:GetUniqueId()
        elseif channelCurrent:GetName() == "Beute" then
            self.say = channelCurrent:GetUniqueId()
        elseif channelCurrent:GetName() == "Butin" then
            self.say = channelCurrent:GetUniqueId()
        elseif channelCurrent:GetName() == "System" then
            self.system = channelCurrent:GetUniqueId()
        elseif channelCurrent:GetName() == "Systeme" then
            self.system = channelCurrent:GetUniqueId()
        elseif channelCurrent:GetName() == "Whisper" then
            self.whisper = channelCurrent
        elseif channelCurrent:GetName() == "Flüstern" then
            self.whisper = channelCurrent
        elseif channelCurrent:GetName() == "Murmurer" then
            self.whisper = channelCurrent
        end
    end

	self:Build()
end

function LUI_Holdem:System(message)
    if self.system then
        ChatSystemLib.PostOnChannel(self.system,message,"")
    else
        Print(message)
    end
end

function LUI_Holdem:Whisper(user,message)
    if self.whisper then
        self.whisper:Send(tostring(user) .. " " ..tostring(message))
    end
end

function LUI_Holdem:Say(message)
    if self.say then
        ChatSystemLib.PostOnChannel(self.say,message,"")
    else
        Print(message)
    end
end

function LUI_Holdem.ChatLog_OnChatMessage(self, channelCurrent, tMessage)
    if string.match(channelCurrent:GetName(), "LUI") then
        return
    else
        fChatLog_OnChatMessage(self, channelCurrent, tMessage)
    end
end

function LUI_Holdem:OnCharacterCreated()
	local player = GameLib.GetPlayerUnit()

	if player ~= nil then
		self.name = player:GetName()
	end

	self:Build()
end

function LUI_Holdem:Build()
	if not self.isBuild and self.name ~= nil then
        self:LeaveAllChannels()
        self:Connect()
		self:JoinGlobalChannel()
    	self:BuildTable()
		self:BuildLobby()
        self:BuildLog()
		self.isBuild = true
	end
end

function LUI_Holdem:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn","LUI Holdem", {"ToggleLUIHoldem", "", "CRB_MinimapSprites:sprMM_VendorGeneral" })
end

function LUI_Holdem:OnSlashCommand()
	self:OnToggleMenu()
end

function LUI_Holdem:OnToggleMenu()
    if self.wndAlert:IsShown() then
        self.wndAlert:Show(false)
    end

    Event_FireGenericEvent("InterfaceMenuList_NewAddOn","LUI Holdem", {"ToggleLUIHoldem", "", "CRB_MinimapSprites:sprMM_VendorGeneral" })

	if self.wndTable and self.wndTable:IsEnabled() then
		if self.wndLobby and self.wndLobby:IsShown() then
			self.wndLobby:Close()
		end

		if self.wndTable:IsShown() then
			self.wndTable:Close()
		else
			self.wndTable:Invoke()
		end
	else
		if self.wndLobby then
			if self.wndTable and self.wndTable:IsShown() then
				self.wndTable:Close()
			end

			if self.wndLobby:IsShown() then
				self.wndLobby:Close()
			else
				self.wndLobby:Invoke()
			end
		else
			self:OnLoad()
		end
	end
end

function LUI_Holdem:LoadDefaults()
    self.settings = self:InsertDefaults(self.settings, self:Copy(self.defaults))
end

function LUI_Holdem:OnSave(eType)
    if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return
    end

    return self.settings
end

function LUI_Holdem:OnRestore(eType, tSavedData)
    if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return
    end

    if tSavedData ~= nil and tSavedData ~= "" then
        self.settings = self:Extend(self.settings, tSavedData)
    end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # ICCOM STUFF
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:JoinGlobalChannel()
    local chatActive = false

    for idx, channelCurrent in ipairs(ChatSystemLib.GetChannels()) do
    	if channelCurrent:GetName() == "LUIHoldem" then
    		chatActive = true
    		self.global = channelCurrent
    	end
    end

    if not chatActive then
    	ChatSystemLib.JoinChannel("LUIHoldem")
    end

    if self.global then
    	self:HideChannel(self.global:GetUniqueId())
    else
    	Apollo.CreateTimer("LUI_Holdem_JoinGlobal", 1, false)
    end
end

function LUI_Holdem:LeaveAllChannels()
    for idx, channelCurrent in ipairs(ChatSystemLib.GetChannels()) do
        if (string.find(channelCurrent:GetName(),"LUI") or string.find(channelCurrent:GetName(),"Table")) and channelCurrent:GetName() ~= "LUIHoldem" then
            channelCurrent:Leave()
        end
    end
end

function LUI_Holdem:JoinChatChannel()
    local name = not self.game.host and self.name or self.game.host
    local channelName = "Table".. string.gsub(string.sub(name,1,string.find(name," ") -1),'[^a-zA-Z]','')

    if string.len(channelName) > 19  then
        channelName = string.sub(channelName,1,19)
    end

    local chatActive = false

    for idx, channelCurrent in ipairs(ChatSystemLib.GetChannels()) do
        if channelCurrent:GetName() == channelName then
            chatActive = true
            self.chatroom = channelCurrent
            self.chatroomID = channelCurrent:GetUniqueId()
        end
    end

    if not chatActive then
        if self.chatroom then
            self.chatroom:Leave()
            self.chatroom = nil
        end

        ChatSystemLib.JoinChannel(channelName)
    end

    if self.chatroom then
        self.chatroom:Post("You joined "..self.game.name..".")
        self.chatroom:Post("Use /"..self.chatroom:GetCommand().." to chat with other players.")
        self.chatroom:Send(self.welcome[math.random(10)])
    else
        Apollo.CreateTimer("LUI_Holdem_JoinChat", 1, false)
    end
end

function LUI_Holdem:JoinChannel()
	local name = not self.game.host and self.name or self.game.host
    local channelName = "LUI".. string.gsub(string.sub(name,1,string.find(name," ") -1),'[^a-zA-Z]','')

    if string.len(channelName) > 19  then
        channelName = string.sub(channelName,1,19)
    end

	local chatActive = false

    for idx, channelCurrent in ipairs(ChatSystemLib.GetChannels()) do
    	if channelCurrent:GetName() == channelName then
    		chatActive = true
    		self.chat = channelCurrent
    	end
    end

	if not chatActive then
		if self.chat then
			self.chat:Leave()
            self.chat = nil
		end

		ChatSystemLib.JoinChannel(channelName)
	end

	if self.chat then
    	self:HideChannel(self.chat:GetUniqueId())
    	self:Join()
    else
    	Apollo.CreateTimer("LUI_Holdem_Join", 1, false)
   	end
end

function LUI_Holdem:Join()
	if self.name == self.game.host then
    	self.broadcast:Start()
		self:Broadcast()

		self.wndLobby:FindChild("Loading"):Show(false)
		self:ShowTable()
	else
		if not self.game.locked then
			local tMessage = {
				sender = self.name,
				action = "join",
			}

			self:Send(tMessage,true)
		end
    end
end

function LUI_Holdem:HideChannel(id)
    if not aChatLog then
        return
    end

    if not aChatLog.tChatWindows then
        return
    end

	for key, wnd in pairs(aChatLog.tChatWindows) do
    	local tData = wnd:GetData()

    	if tData.tViewedChannels and tData.tViewedChannels[id] then
    		tData.tViewedChannels[id] = false

    		aChatLog:HelperRemoveChannelFromAll(id)
    	end
    end
end

function LUI_Holdem:Connect()
    if not self.comm then
        self.comm = ICCommLib.JoinChannel("LUIHoldem", ICCommLib.CodeEnumICCommChannelType.Global)
    end

    if self.comm:IsReady() then
        self.comm:SetReceivedMessageFunction("OnICCommMessageReceived", self)
        self.comm:SetSendMessageResultFunction("OnICCommSendMessageResult", self)
    else
    	Apollo.CreateTimer("LUI_Holdem_Connect", 3, false)
    end
end

function LUI_Holdem:ConnectToHost()
	local name = not self.game.host and self.name or self.game.host
	local ctype = nil

	if self.game.gameType == "Guild" then
		ctype = ICCommLib.CodeEnumICCommChannelType.Guild
	elseif self.game.gameType == "Group" then
		ctype = ICCommLib.CodeEnumICCommChannelType.Group
	else
		ctype = ICCommLib.CodeEnumICCommChannelType.Global
	end

	if not self.gamecom then
        local channelName = "LUI".. string.gsub(string.sub(name,1,string.find(name," ") -1),'[^a-zA-Z]','')
        local guild = nil

        if string.len(channelName) > 19  then
            channelName = string.sub(channelName,1,19)
        end

        if ctype == ICCommLib.CodeEnumICCommChannelType.Guild then
            for _,g in pairs(GuildLib.GetGuilds()) do
                if g:GetType() == GuildLib.GuildType_Guild then
                    guild = g
                end
            end
        end

		self.gamecom = ICCommLib.JoinChannel(channelName, ctype, guild)
	end

	if self.gamecom:IsReady() then
		self.gamecom:SetReceivedMessageFunction("OnGameMessageReceived", self)
		self:Join()
    else
    	Apollo.CreateTimer("LUI_Holdem_Connect_Game", 3, false)
    end
end

function LUI_Holdem:SendSplitMessage(tMessage,isTable)
    local len = string.len(tostring(JSON.encode(tostring(JSON.encode(tMessage)))))

	local string = tostring(JSON.encode(tMessage))
	local parts = math.ceil(len / 400)
    local partLen = math.ceil(string.len(string) / parts)
	local last = false
	local max = 0

	for i = 1, parts do
		if string.len(string) > partLen then
			max = partLen
		else
			max = string.len(string)
		end

		if i == parts then
			last = true
		else
			last = false
		end

		local send = {
			sender = self.name,
			part = i,
			last = last,
			action = tMessage.action,
			content = string.sub(string,1,max)
		}

		if isTable == true then
			self.chat:Send(tostring(JSON.encode(send)))
		else
			self.global:Send(tostring(JSON.encode(send)))
		end

		if max ~= string.len(string) then
			string = string.sub(string,max+1,string.len(string))
		end
	end
end

function LUI_Holdem:Send(tMessage,isTable)
	local strMsg = JSON.encode(tMessage)

	if isTable == true then
		if self.game.conn == "ICComm" then
			if not self.gamecom then
				self:ConnectToHost()
		    end

		    self.gamecom:SendMessage(tostring(strMsg))
		else
		    if not self.chat then
		    	self.JoinChannel()
		    end

		    if string.len(tostring(strMsg)) > 450 then
		    	self:SendSplitMessage(tMessage,isTable)
		    else
		    	self.chat:Send(tostring(strMsg))
		    end
		end
	else
		if self.game.conn == "ICComm" then
		    if self.comm then
		        self:Connect()
		    end

		    self.comm:SendMessage(tostring(strMsg))
		else
		    if self.global then
		   		self:JoinGlobalChannel()
		   	end

		   	if string.len(tostring(strMsg)) > 450 then
		   		self:SendSplitMessage(tMessage,isTable)
		    else
		    	self.global:Send(tostring(strMsg))
		    end
		end
	end
end

function LUI_Holdem:Broadcast()
	if self.game.conn == "ICComm" and self.busy ~= nil and self.busy == true then
		return
	end

	local tMessage = {
		action = "insert",
        version = self.version,
        name = self.game.name,
        host = self.game.host,
        conn = self.game.conn,
        game = self.game.gameType,
        locked = self.game.locked,
        count = self.game.playerCount,
        buyIn = self.game.buyIn,
        realm = self.game.realm,
        faction = self.game.faction
	}

	self:Send(tMessage)
	self.busy = false
end

function LUI_Holdem:OnICCommSendMessageResult(iccomm, eResult, idMessage)
	self.busy = true
end

function LUI_Holdem:OnICCommMessageReceived(channel, strMessage, idMessage)
	local message = JSON.decode(strMessage)

	if type(message) ~= "table" then
		return
	end

	if not self.comm then
		return
	end

	self:OnGlobalMessage(message)
end

function LUI_Holdem:OnGameMessageReceived(channel, strMessage, idMessage)
	local message = JSON.decode(strMessage)

	if type(message) ~= "table" then
		return
	end

	if not self.gamecom then
		return
	end

	self:OnGameMessage(message)
end

function LUI_Holdem:OnChatMessage(channelCurrent, tMessage)
	local strMessage = ""

	for idx, tSegment in ipairs(tMessage.arMessageSegments) do
		strMessage = strMessage .. tSegment.strText
	end

	local message = JSON.decode(strMessage)

	if type(message) ~= "table" then
		return
	end

	if message.part ~= nil then
		if not self.messages then
			self.messages = {}
		end

		local idx = 0

		for k,v in pairs(self.messages) do
			if v.sender == message.sender and v.action == message.action then
				idx = k
			end
		end

		if idx > 0 then
			if message.last == false then
				self.messages[idx].content = self.messages[idx].content .. message.content
			else
				local completeMessage = JSON.decode(self.messages[idx].content .. message.content)

				if self.chat and self.chat:GetUniqueId() == channelCurrent:GetUniqueId() then
					self:OnGameMessage(completeMessage)
				elseif self.global and self.global:GetUniqueId() == channelCurrent:GetUniqueId() then
					self:OnGlobalMessage(completeMessage)
				end

				table.remove(self.messages,idx)
			end
		else
			table.insert(self.messages,{
				sender = message.sender,
				action = message.action,
				content = message.content
			})
		end
	else
		if self.chat and self.chat:GetUniqueId() == channelCurrent:GetUniqueId() then
			self:OnGameMessage(message)
		elseif self.global and self.global:GetUniqueId() == channelCurrent:GetUniqueId() then
			self:OnGlobalMessage(message)
		end
	end
end

function LUI_Holdem:OnGlobalMessage(message)
	if not message or not message.action then
		return
	end

	if message.action == "insert" then
		self:AddGame(message)
	elseif message.action == "delete" then
		self:RemoveGame(message)
    elseif message.action == "confirm-join" then
        self:JoinGame(message)
	end
end

function LUI_Holdem:OnGameMessage(message)
	if not message or not message.action then
		return
	end

    if message.action == "join" then
        self:AddPlayer(message)
    elseif message.action == "new-round" then
        if not self.active == true then
            self.active = true
            self.timer:Start()
            self.wndTable:FindChild("Spectator"):Show(false)
        end
    elseif message.action == "confirm-join" then
        self:JoinGame(message)
    elseif message.action == "deny-join" then
        self:OnDeny(message)
    elseif message.action == "join-table" then
        self:JoinTable(message)
    elseif message.action == "lock-table" then
        self:LockTable(message)
    elseif message.action == "kick" then
        self:OnKick(message)
    elseif message.action == "sitout" then
        self:OnSitout(message)
    elseif message.action == "leave-table" then
        self:PlayerLeftTable(message)
    elseif message.action == "start" then
        self:OnStart()
    elseif message.action == "pause" then
        if not self.active == true and message.value == false then
            self.game.time = os.time() - (self.game.blindRaise * 60) + message.remaining
        end
    elseif message.action == "blind-raise" then
        if not self.active == true then
            self.game.time = os.time()
        end
    end

    if not self.active == true then
        return
    end

    if message.action == "new-round" then
        self:StartRound(message)
    elseif message.action == "pause" then
		self:OnPause(message)
	elseif message.action == "blind-raise" then
		self:OnBlindRaise(message)
    elseif message.action == "result" then
        self:OnRoundResult(message)
	elseif message.action == "cards" then
		self:OnReceiveCards(message)
    elseif message.action == "flop" then
        self:OnReceiveFlop(message)
    elseif message.action == "turn" then
        self:OnReceiveTurn(message)
    elseif message.action == "river" then
        self:OnReceiveRiver(message)
    elseif message.action == "fold" then
        self:OnAction(message)
    elseif message.action == "check" then
        self:OnAction(message)
    elseif message.action == "call" then
        self:OnAction(message)
    elseif message.action == "raise" then
        self:OnAction(message)
    elseif message.action == "stop" then
        self:OnStop(message)
    elseif message.action == "rebuy" then
        self:OnRebuy(message)
    elseif message.action == "showdown" then
        self:OnStartShowdown(message)
	end
end

function LUI_Holdem:OnDeny(message)
	if message.recipient ~= self.name then
		return
	end

	if self.gamecom then
		self.gamecom = nil
	end

    if self.chat then
        self.chat:Leave()
    end

	self.wndLobby:FindChild("Loading"):Show(false)
	self:System(message.reason)
end

function LUI_Holdem:JoinGame(message)
	if message.recipient ~= self.name then
		return
	end

    if message.game ~= nil then
        self.game = self:Extend(self.game, message.game)
        self.players = message.players
        self.current = message.current
    else
        self.game.active = message.active
        self.game.time = message.time
        self.game.blindRaise = message.blindRaise
        self.game.rebuy = message.rebuy
        self.game.actionTimer = message.actionTimer
        self.players = message.players
        self.key = message.key
    end

	self.wndLobby:FindChild("Loading"):Show(false)
	self:ShowTable()
end

function LUI_Holdem:LockTable(message)
	self.game.closed = message.value

	-- Update all open seats
    if not self.seat then
    	for i = 1, 10 do
    		if self.players[i].active == false then
    			self.wndSeats[i]:Show(not self.game.closed)
    		end
    	end
    end
end

function LUI_Holdem:AddPlayer(message)
	if self.game.host ~= self.name then
		return
	end

	local tMessage = {}
	local pass = true

	if self.game.locked ~= nil and self.game.locked == true then
		if self.password ~= self:Decode(tostring(message.password),5) then
			pass = false
		end
	end

	if pass == true then
        -- Check if player is returning to table
        local exists = false

        for i = 1, 10 do
            if self.players[i].name and self.players[i].name == message.sender then
                exists = true
                break
            end
        end

        if exists == true then
            -- Send him all the game data
            local players = self:Copy(self.players)
            local game = self:Copy(self.game)

            game.cards = nil
            game.name = nil
            game.host = nil
            game.conn = nil
            game.gameType = nil
            game.locked = nil
            game.playerCount = nil
            game.buyIn = nil
            game.realm = nil
            game.faction = nil

            for k,player in pairs(players) do
                if player.active == true then
                    if player.name ~= message.sender then
                        player.cards = nil
                        player.key = nil
                    end
                end
            end

            tMessage = {
                action = "confirm-join",
                recipient = message.sender,
                game = game,
                current = self.current,
                players = players,
            }

            self:Send(tMessage)
        else
            -- Add new player
            local players = {}

            for i = 1, 10 do
                if self.players[i].active == true then
                    table.insert(players,{
                        active = true,
                        name = self.players[i].name,
                        cash = self.players[i].cash
                    })
                else
                    table.insert(players,{
                        active = false
                    })
                end
            end

            local key = {math.random(100),math.random(100),math.random(100),math.random(100),0}
            self:SaveKey(message.sender,key)

            tMessage = {
                action = "confirm-join",
                recipient = message.sender,
                time = self.game.time,
                active = self.game.active,
                blindRaise = self.game.blindRaise,
                rebuy = self.game.rebuy,
                actionTimer = self.game.actionTimer,
                players = players,
                key = key
            }

            self:Send(tMessage,true)
        end
	else
		tMessage = {
            action = "deny-join",
			recipient = message.sender,
			reason = "Wrong Password."
		}

        self:Send(tMessage,true)
	end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # LOBBY
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:BuildLobby()
	if not self.wndLobby then
		self.wndLobby = Apollo.LoadForm(self.xmlDoc, "LobbyForm", nil, self)
    end

    -- Build Alert Window
    if not self.wndAlert then
        self.wndAlert = Apollo.LoadForm(self.xmlDoc, "Alert", nil, self)
        self.wndAlert:Show(false,true)
    end

	-- Preselect Lobby Tab
	self.wndLobby:FindChild("LobbyBtn"):SetCheck(true)
	self.wndLobby:FindChild("NewGameBtn"):SetCheck(false)

	-- Show Lobby
	self.wndLobby:FindChild("Lobby"):Show(true, true)
	self.wndLobby:FindChild("NewGame"):Show(false, true)

	-- Name Textbox
	self.wndLobby:FindChild("NameText"):SetText(tostring(self.name) .. "'s' Poker Round")

	--Lib Dropdown
	self.wndLobby:FindChild("LibDropdown"):AttachWindow(self.wndLobby:FindChild("LibDropdown"):FindChild("ChoiceContainer"))
	self.wndLobby:FindChild("LibDropdown"):FindChild("ChoiceContainer"):Show(false)
	self.wndLobby:FindChild("LibDropdown"):SetText("Chat System")

	for _,button in pairs(self.wndLobby:FindChild("LibDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
		if button:GetName() == "Chat" then
			button:SetCheck(true)
		else
			button:SetCheck(false)
		end
	end

	-- Game Type Dropdown
	self.wndLobby:FindChild("TypeDropdown"):AttachWindow(self.wndLobby:FindChild("TypeDropdown"):FindChild("ChoiceContainer"))
	self.wndLobby:FindChild("TypeDropdown"):FindChild("ChoiceContainer"):Show(false)
	self.wndLobby:FindChild("TypeDropdown"):SetText("Public")

	for _,button in pairs(self.wndLobby:FindChild("TypeDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
		if button:GetName() == "Global" then
			button:SetCheck(true)
		else
			button:SetCheck(false)
		end
	end

	-- Blind Raise Dropdown
	self.wndLobby:FindChild("BlindDropdown"):AttachWindow(self.wndLobby:FindChild("BlindDropdown"):FindChild("ChoiceContainer"))
	self.wndLobby:FindChild("BlindDropdown"):FindChild("ChoiceContainer"):Show(false)
	self.wndLobby:FindChild("BlindDropdown"):SetText("Every 20 Minutes")

	for _,button in pairs(self.wndLobby:FindChild("BlindDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
		if button:GetText() == "Every 20 Minutes" then
			button:SetCheck(true)
		else
			button:SetCheck(false)
		end
	end

    -- Timer Dropdown
    self.wndLobby:FindChild("TimerDropdown"):AttachWindow(self.wndLobby:FindChild("TimerDropdown"):FindChild("ChoiceContainer"))
    self.wndLobby:FindChild("TimerDropdown"):FindChild("ChoiceContainer"):Show(false)
    self.wndLobby:FindChild("TimerDropdown"):SetText("30 Seconds")

    for _,button in pairs(self.wndLobby:FindChild("TimerDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
        if button:GetText() == "30 Seconds" then
            button:SetCheck(true)
        else
            button:SetCheck(false)
        end
    end

	-- Rebuy Dropdown
	self.wndLobby:FindChild("RebuyDropdown"):AttachWindow(self.wndLobby:FindChild("RebuyDropdown"):FindChild("ChoiceContainer"))
	self.wndLobby:FindChild("RebuyDropdown"):FindChild("ChoiceContainer"):Show(false)
	self.wndLobby:FindChild("RebuyDropdown"):SetText("Unlimited Rebuy")

	for _,button in pairs(self.wndLobby:FindChild("RebuyDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
		if button:GetName() == "3" then
			button:SetCheck(true)
		else
			button:SetCheck(false)
		end
	end

	-- Buy In Slider
	self.wndLobby:FindChild("BuyInSetting"):FindChild("CashWindow"):SetAmount(0,true)
	self.wndLobby:FindChild("CashSlider"):SetMinMax(0,self:Round(GameLib.GetPlayerCurrency():GetAmount(), -6) - 1000000,1000000)
	self.wndLobby:FindChild("CashSlider"):SetValue(0)

    -- Hide Donation Form
    self.wndLobby:FindChild("DonateForm"):Show(false,true)
    self.wndLobby:FindChild("DonateBtn"):Show(GameLib.GetRealmName() == "Jabbit",true)
    self.wndLobby:FindChild("DonateForm"):FindChild("DonateSendBtn"):Enable(false)

	-- Hide Loading
	self.wndLobby:FindChild("Loading"):Show(false,true)

	-- Hide Password Prompt
	self.wndLobby:FindChild("Password"):Show(false,true)

	-- Hide Lobby
	self.wndLobby:Show(false, true)
end

function LUI_Holdem:OnDonate(wndHandler, wndControl)
    self.wndLobby:FindChild("DonateForm"):Show(wndHandler:IsChecked())
end

function LUI_Holdem:OnDonationChanged(wndHandler, wndControl)
    local amount = self.wndLobby:FindChild("DonateForm"):FindChild("CashWindow"):GetAmount()
    local recipient = "Loui NaN"

    if GameLib.GetPlayerUnit():GetFaction() ~= 166 then
        recipient = "RC Loui"
    end

    if amount >= 10000 then
        self.wndLobby:FindChild("DonateForm"):FindChild("DonateSendBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.SendMail, recipient, "Jabbit", "LUI Hold'em Donation", tostring(self.name) .. " donated something for you!", nil, MailSystemLib.MailDeliverySpeed_Instant, 0, self.wndLobby:FindChild("DonateForm"):FindChild("CashWindow"):GetCurrency())
        self.wndLobby:FindChild("DonateForm"):FindChild("DonateSendBtn"):Enable(true)
    else
        self.wndLobby:FindChild("DonateForm"):FindChild("DonateSendBtn"):Enable(false)
    end
end

function LUI_Holdem:OnDonationSent()
    self.wndLobby:FindChild("DonateBtn"):SetCheck(false)
    self.wndLobby:FindChild("DonateForm"):Show(false)
    self:Say("Thank you very much!!! <3")
end

function LUI_Holdem:OnLobbyTabBtn(wndHandler, wndControl)
	local strFormName = string.sub(wndControl:GetName(),0,-4)

	for _,child in pairs(self.wndLobby:FindChild("Container"):GetChildren()) do
		child:Show(strFormName == child:GetName())
	end
end

function LUI_Holdem:OnCashAmountChanged(wndHandler, wndControl)
	self.wndLobby:FindChild("BuyInSetting"):FindChild("CashWindow"):SetAmount(wndHandler:GetValue())

    if wndHandler:GetValue() > 0 then
        -- Update Type Dropdown
        if self.wndLobby:FindChild("TypeDropdown"):GetText() == "Public" then
            self.wndLobby:FindChild("TypeDropdown"):SetText("Group Only")

            -- Update Dropdown Choices
            for _,button in pairs(self.wndLobby:FindChild("TypeDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
                if button:GetName() == "Global" then
                    button:SetCheck(false)
                elseif button:GetName() == "Group" then
                    button:SetCheck(true)
                else
                    button:SetCheck(false)
                end
            end
        end

        -- Disable Dropdown Choice
        for _,button in pairs(self.wndLobby:FindChild("TypeDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
            if button:GetName() == "Global" then
                button:Enable(false)
            end
        end
    else
        -- Enable Dropdown Choice
        for _,button in pairs(self.wndLobby:FindChild("TypeDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
            if button:GetName() == "Global" then
                button:Enable(true)
            end
        end
    end
end

function LUI_Holdem:RemoveGame(message)
	self.wndLobby:FindChild("Password"):Show(false,true)

	for _,game in pairs(self.wndLobby:FindChild("Lobby"):GetChildren()) do
		if game:FindChild("GameName"):GetText() == message.game then
			game:Destroy()
		end
	end
end

function LUI_Holdem:AddGame(message)
    if not message then
        return
    end

    if not message.host or not message.name or not message.conn then
        return
    end

    if message.host == self.name then
        return
    end

	local crossrealm = false

	if GameLib.GetRealmName() ~= message.realm or GameLib.GetPlayerUnit():GetFaction() ~= message.faction then
		crossrealm = true

		if message.buyIn > 0 then
			return
		end

		if message.game ~= "Global" then
			return
		end

        if message.conn ~= "ICComm" then
            return
        end
	end

	for _,game in pairs(self.wndLobby:FindChild("Lobby"):GetChildren()) do
		if game:FindChild("GameName"):GetText() == message.name then
            game:FindChild("PlayerName"):SetText(message.host .. " (".. tostring(message.count or 0) .. "/10)")
			return
		end
	end

	if message.game == "Guild" and not self:IsInGuild(message.host) then
		return
	end

	if message.game == "Group" and not self:IsInGroup(message.host) then
		return
	end

    -- Create Game Entry
    local wndGame = Apollo.LoadForm(self.xmlDoc, "GameItem", self.wndLobby:FindChild("Lobby"), self)

    wndGame:FindChild("GameName"):SetText(message.name)
    wndGame:FindChild("PlayerName"):SetText(message.host .. " (".. tostring(message.count or 0) .. "/10)")
    wndGame:FindChild("CashWindow"):SetAmount(message.buyIn)
    wndGame:FindChild("PayBtn"):Show(false,true)

    -- Set Game Data
    local gameData = {
        version = message.version,
        name = message.name,
        host = message.host,
        conn = message.conn,
        gameType = message.game,
        locked = message.locked,
        playerCount = message.count,
        buyIn = message.buyIn,
        realm = message.realm,
        faction = message.faction
    }

    wndGame:FindChild("JoinGame"):SetData(gameData)

    if message.locked == true then
    	wndGame:FindChild("JoinGame"):FindChild("Lock"):Show(true,true)
    else
    	wndGame:FindChild("JoinGame"):FindChild("Lock"):Show(false,true)
    end

    if message.buyIn == 0 then
    	wndGame:FindChild("CashWindow"):Show(false,true)

    	local offsetLeft,offsetTop,offsetRight,offsetBottom = wndGame:FindChild("JoinGame"):GetAnchorOffsets()
		wndGame:FindChild("JoinGame"):SetAnchorOffsets(offsetLeft,20,offsetRight,-20)
    else
        wndGame:FindChild("CashWindow"):Show(true,true)
	end

    wndGame:FindChild("JoinGame"):Show(true,true)

	self.wndLobby:FindChild("Lobby"):ArrangeChildrenVert(0)
end

function LUI_Holdem:OnCreateGame()
	local gameName = self.wndLobby:FindChild("NameText"):GetText()
	local password = self.wndLobby:FindChild("Frame"):FindChild("PasswordText"):GetText()
	local locked = false
	local gameLib = "ICComm"
	local gameType = "Group"
    local rebuy = 1
	local blindRaise = 20
    local actionTimer = 45
	local playerName = self.name
	local playerRealm = GameLib.GetRealmName()
	local playerFaction = GameLib.GetPlayerUnit():GetFaction()
	local maxCurrency = GameLib.GetPlayerCurrency():GetAmount()
	local nAmount = self.wndLobby:FindChild("CashWindow"):GetAmount()

	if password ~= nil and password ~= "" then
		locked = true
	end

	-- Check Game Name
	if not gameName or gameName == "" then
		gameName = tostring(playerName .. "'s' Poker Round")
	end

	-- Check Game Lib
	for _,button in pairs(self.wndLobby:FindChild("LibDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
		if button:IsChecked() then
			gameLib = button:GetName()
		end
	end

	-- Check Game Type
	for _,button in pairs(self.wndLobby:FindChild("TypeDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
		if button:IsChecked() then
			gameType = button:GetName()
		end
	end

    -- Check Action Timer
    for _,button in pairs(self.wndLobby:FindChild("TimerDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
        if button:IsChecked() then
            actionTimer = tonumber(button:GetName())
        end
    end

	-- Check Blind Raise Interval
	for _,button in pairs(self.wndLobby:FindChild("BlindDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
		if button:IsChecked() then
			blindRaise = tonumber(button:GetName())
		end
	end

	-- Check Rebuy Setting
	for _,button in pairs(self.wndLobby:FindChild("RebuyDropdown"):FindChild("ChoiceContainer"):GetChildren()) do
		if button:IsChecked() then
			rebuy = tonumber(button:GetName())
		end
	end

	self.game = {
		name = gameName,
		locked = locked,
		host = playerName,
		realm = playerRealm,
		faction = playerFaction,
		conn = gameLib,
		buyIn = nAmount,
		gameType = gameType,
		blindRaise = blindRaise,
        actionTimer = actionTimer,
		rebuy = rebuy,
		playerCount = 1,
	}

	if locked then
		self.password = password
	end

    -- Create Key for Host
    local key = {math.random(100),math.random(100),math.random(100),math.random(100),0}
    self:SaveKey(self.name,key)
    self.key = key

	self.wndLobby:FindChild("Loading"):Show(true)

	if gameLib == "ICComm" then
		self:ConnectToHost()
	else
		self:JoinChannel()
	end

    -- Join Chat Channel
    self:JoinChatChannel()
end

function LUI_Holdem:OnJoinWait()
    self.jointimer = nil

    for _,game in pairs(self.wndLobby:FindChild("Lobby"):GetChildren()) do
        game:FindChild("JoinGame"):Enable(true)
    end
end

function LUI_Holdem:OnJoinGame(wndHandler, wndControl)
    if self.jointimer then
        return
    end

    -- Disable Join Buttons
    Apollo.CreateTimer("LUI_Holdem_JoinGame", 10, false)
    self.jointimer = true

    for _,game in pairs(self.wndLobby:FindChild("Lobby"):GetChildren()) do
        game:FindChild("JoinGame"):Enable(false)
    end

	self.game = wndControl:GetData()

    if self.game.version ~= self.version then
        if self.game.version > self.version then
            self:System("Could not join table: Please update LUI Hold'em.")
        else
            if GameLib.GetRealmName() == self.game.realm and GameLib.GetPlayerUnit():GetFaction() == self.game.faction then
                self:Whisper(self.game.host,"Could not join table: You are using an older version of LUI Hold'em.")
            else
                self:System("Could not join table: "..self.game.host.." is using an older version of LUI Hold'em.")
            end
        end

        return
    end

    if self.game.locked ~= nil and self.game.locked == true then
		self:RequestPassword()
	else
		self.wndLobby:FindChild("Loading"):Show(true)

		if self.game.conn == "ICComm" then
			self:ConnectToHost()
		else
			self:JoinChannel()
		end

        -- Join Chat Channel
        self:JoinChatChannel()
	end
end

function LUI_Holdem:RequestPassword()
	self.wndLobby:FindChild("Password"):FindChild("PasswordText"):SetText("")
	self.wndLobby:FindChild("Password"):FindChild("PasswordText"):SetFocus()
	self.wndLobby:FindChild("Password"):Show(true)
end

function LUI_Holdem:OnEnterPassword(wndHandler, wndControl)
	self.wndLobby:FindChild("Password"):Show(false)
	self.wndLobby:FindChild("Loading"):Show(true)

	if self.game.conn == "ICComm" then
		self:ConnectToHost()
	else
		self:JoinChannel()
	end

	local tMessage = {
		sender = self.name,
		password = self:Encode(tostring(self.wndLobby:FindChild("Password"):FindChild("PasswordText"):GetText()),5),
		action = "join",
	}

	self:Send(tMessage,true)
end

function LUI_Holdem:OnClosePasswordLobby()
	self.wndLobby:FindChild("Password"):Show(false)
end

function LUI_Holdem:OnDropdownToggle(wndHandler, wndControl)
	if wndHandler ~= wndControl then
		return
	end
	wndControl:FindChild("ChoiceContainer"):Show(wndControl:IsChecked())
end

function LUI_Holdem:OnDropdownChoose(wndHandler, wndControl)
	local dropdown = wndControl:GetParent():GetParent()
	dropdown:SetText(wndControl:GetText())
	wndControl:GetParent():Close()
end

function LUI_Holdem:OnPlayerCurrencyChanged()
    local cash = GameLib.GetPlayerCurrency():GetAmount()

    if self.wndLobby then
        -- Update New Game Max BuyIn Value
        self.wndLobby:FindChild("CashSlider"):SetMinMax(0,self:Round(cash, -6) - 1000000,1000000)
    end

    if self.wndCashout then
        -- Update Cashout Players Buttons
        for _,cashout in pairs(self.wndCashout:FindChild("Container"):GetChildren()) do
            if cashout:FindChild("CashWindow"):GetAmount() > cash then
                cashout:FindChild("PayBtn"):Enable(false)
            else
                cashout:FindChild("PayBtn"):Enable(true)
            end
        end
    end

    if self.wndTable and self.game and self.game.buyIn and self.game.buyIn > 0 then
        -- Update PlayerSeats
        for i = 1, 10 do
            if self.game.buyIn > cash then
                self.wndSeats[i]:FindChild("JoinGame"):Enable(false)
                self.wndSeats[i]:SetTooltip("Not enough funds.")
            else
                self.wndSeats[i]:FindChild("JoinGame"):Enable(true)
                self.wndSeats[i]:SetTooltip("")
            end
        end
    end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # TABLE
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:BuildTable()
	if not self.wndTable then
		self.wndTable = Apollo.LoadForm(self.xmlDoc, "TableForm", nil, self)
    end

    -- Set Minimum Dimensions
    self.wndTable:SetSizingMinimum(1400, 959)

	if self.wndPlayers ~= nil then
		for i = 1, 10 do
            self.wndPlayers[i]:FindChild("Glow"):Show(false,true)
			self.wndPlayers[i]:FindChild("Active"):Show(false,true)
            self.wndPlayers[i]:FindChild("PlayerAction"):Show(false,true)
			self.wndPlayers[i]:FindChild("CardHolder"):Show(false,true)
			self.wndPlayers[i]:Show(false,true)
		end
	end

	if self.wndSeats ~= nil then
		for i = 1, 10 do
			self.wndSeats[i]:Show(false,true)
		end
	end

	if self.wndCash ~= nil then
		for i = 1, 10 do
			self.wndCash[i]:Show(false,true)
            self.wndCash[i]:FindChild("CashWindow"):SetAmount(0,true)
		end
	end

	self.wndPlayers = {}
	self.wndSeats = {}
	self.wndCash = {}

	for i = 1, 10 do
		-- Create Table Seats
		self.wndSeats[i] = Apollo.LoadForm(self.xmlDoc, "PlayerSeat", self.wndTable:FindChild("Table"), self)
		self.wndSeats[i]:SetAnchorPoints(unpack(self.seats[i].anchorPoints))
		self.wndSeats[i]:SetAnchorOffsets(unpack(self.seats[i].anchorOffsets))
		self.wndSeats[i]:FindChild("Button"):SetData(i)
        self.wndSeats[i]:FindChild("JoinGame"):SetData(i)
        self.wndSeats[i]:FindChild("CashWindow"):Show(false,true)
		self.wndSeats[i]:Show(false,true)

		-- Create Player Frames
		self.wndPlayers[i] = Apollo.LoadForm(self.xmlDoc, "PlayerItem:"..self.playerFrames[i].cardPosition, self.wndTable:FindChild("Table"), self)
		self.wndPlayers[i]:SetAnchorPoints(unpack(self.playerFrames[i].anchorPoints))
		self.wndPlayers[i]:SetAnchorOffsets(unpack(self.playerFrames[i].anchorOffsets))
        self.wndPlayers[i]:FindChild("Glow"):Show(false,true)
		self.wndPlayers[i]:FindChild("Active"):Show(false,true)
        self.wndPlayers[i]:FindChild("PlayerAction"):Show(false,true)
		self.wndPlayers[i]:FindChild("CardHolder_Back"):Show(false,true)
		self.wndPlayers[i]:FindChild("CardHolder"):Show(false,true)
		self.wndPlayers[i]:Show(false,true)

		-- Create Cash Items
		self.wndCash[i] = Apollo.LoadForm(self.xmlDoc, "CashItem", self.wndTable:FindChild("Table"), self)
		self.wndCash[i]:SetAnchorPoints(unpack(self.cash[i].anchorPoints))
		self.wndCash[i]:SetAnchorOffsets(unpack(self.cash[i].anchorOffsets))
        self.wndCash[i]:FindChild("CashWindow"):SetAmount(0,true)
		self.wndCash[i]:Show(false,true)
	end

    -- Set Table Sprite
    for _,table in pairs(self.wndTable:FindChild("TableSprite"):GetChildren()) do
        if table:GetName() == "Sprite0" then
            table:Show(true,true)
        else
            table:Show(false,true)
        end
    end

    -- Cards
    self.wndTable:FindChild("CardHolder"):Show(false,true)

    for _,card in pairs(self.wndTable:FindChild("CardHolder"):GetChildren()) do
        card:Show(false,true)
    end

	-- Pot
	self.wndTable:FindChild("Pot"):Show(false,true)

	-- Buttons
	self.wndTable:FindChild("DealerButton"):Show(false,true)
	self.wndTable:FindChild("BigBlindButton"):Show(false,true)
	self.wndTable:FindChild("SmallBlindButton"):Show(false,true)

	-- Notification & Loading
	self.wndTable:FindChild("Loading"):Show(false,true)
	self.wndTable:FindChild("Notification"):Show(false,true)

    -- Clock & Blinds
    self.wndTable:FindChild("Blinds"):Show(false,true)
    self.wndTable:FindChild("Clock"):Show(false,true)

    -- Rebuy Form
    self.wndRebuy = self.wndTable:FindChild("RebuyForm")
    self.wndRebuy:Show(false,true)

    -- Cashout Form
    self.wndCashout = self.wndTable:FindChild("CashForm")
    self.wndCashout:Show(false,true)

    for _,cashout in pairs(self.wndCashout:FindChild("Container"):GetChildren()) do
        cashout:Destroy()
    end

    -- Spectator
    self.wndTable:FindChild("Spectator"):Show(false,true)

	-- Options
	self.wndTable:FindChild("HideCheckbox"):SetData("hide")
	self.wndTable:FindChild("HideCheckbox"):SetCheck(self.settings.hide)

	self.wndTable:FindChild("PauseCheckbox"):SetData("combat")
	self.wndTable:FindChild("PauseCheckbox"):SetCheck(self.settings.combat)

	self.wndTable:FindChild("NotificationCheckbox"):SetData("alert")
	self.wndTable:FindChild("NotificationCheckbox"):SetCheck(self.settings.alert)

	self.wndTable:FindChild("SoundCheckbox"):SetData("sound")
	self.wndTable:FindChild("SoundCheckbox"):SetCheck(self.settings.sound)

    self.wndTable:FindChild("CheckCheckbox"):SetData("check")
    self.wndTable:FindChild("CheckCheckbox"):SetCheck(self.settings.check)

	-- Create Cards
	local colors = {
		"S",
		"H",
		"D",
		"C"
	}

	for i = 2, 14 do
		for k,v in ipairs(colors) do
			local card = {
                valid = true,
				rank = i,
				suit = k,
				sprite = string.upper(v) .. tostring(i),
			}

			table.insert(self.cards,card)
			table.insert(self.validcards,card)
		end
	end

	-- Show Blocker
    self.wndTable:FindChild("Blocker1"):Show(true,true)
    self.wndTable:FindChild("Blocker2"):Show(true,true)

    -- Disable Table
    self.wndTable:Enable(false)

    -- Hide Table
	self.wndTable:Show(false, true)

	-- Prepare Timer
	self.timer = ApolloTimer.Create(1, true, "OnTimer", self)
	self.timer:Stop()
end

function LUI_Holdem:ShowTable()
	self.wndTable:FindChild("Label"):SetText(self.game.name)
	self.wndTable:Enable(true)

    if self:IsPlaying() == true then
        -- Check all seats
        for i = 1, 10 do
            if self.players[i].active == false then
                 self.wndSeats[i]:Show(false,true)
            else
                if self.players[i].name and self.players[i].name == self.name then
                    -- Update Player Data
                    self.seat = i
                    self.active = true
                    self.key = self.players[self.seat].key

                    -- Start Timers
                    self.timer:Start()

                    if self.game.actionTimer > 0 then
                        self:ShowTimer()
                    end

                    -- Make sure seat is hidden
                    self.wndSeats[i]:Show(false,true)

                    -- Prepare Player Frame
                    self.wndPlayers[i]:FindChild("PlayerName"):FindChild("Text"):SetText(self.name)
                    self.wndPlayers[i]:FindChild("CashWindow"):SetAmount(self.players[i].cash)
                    self.wndPlayers[i]:Show(true)

                    if self.game.active == true then
                        -- Position Dealer Button
                        self.wndTable:FindChild("DealerButton"):SetAnchorPoints(unpack(self.buttons.positions[self.game.dealer].anchorPoints))
                        self.wndTable:FindChild("DealerButton"):SetAnchorOffsets(unpack(self.buttons.positions[self.game.dealer].anchorOffsets))

                        -- Position Small Blind Button
                        self.wndTable:FindChild("SmallBlindButton"):SetAnchorPoints(unpack(self.buttons.positions[self.game.small].anchorPoints))
                        self.wndTable:FindChild("SmallBlindButton"):SetAnchorOffsets(unpack(self.buttons.positions[self.game.small].anchorOffsets))

                        -- Position Big Blind Button
                        self.wndTable:FindChild("BigBlindButton"):SetAnchorPoints(unpack(self.buttons.positions[self.game.big].anchorPoints))
                        self.wndTable:FindChild("BigBlindButton"):SetAnchorOffsets(unpack(self.buttons.positions[self.game.big].anchorOffsets))

                        -- Show Buttons
                        self.wndTable:FindChild("DealerButton"):Show(self.game.playerCount > 2)
                        self.wndTable:FindChild("SmallBlindButton"):Show(true)
                        self.wndTable:FindChild("BigBlindButton"):Show(true)

                        -- Update Active Player Icon & Border
                        for i = 1, 10 do
                            self.wndPlayers[i]:FindChild("Glow"):Show(self.current == i and self.seat == i)
                            self.wndPlayers[i]:FindChild("Active"):Show(self.current == i)
                        end

                        -- Update Table Sprite
                        for _,table in pairs(self.wndTable:FindChild("TableSprite"):GetChildren()) do
                            if table:GetName() == "Sprite"..tostring(self.current) then
                                table:Show(true,true)
                            else
                                table:Show(false,true)
                            end
                        end

                        -- Show Community Cards
                        if self.game.communityCards and #self.game.communityCards > 0 then
                            self.wndTable:FindChild("CardHolder"):Show(true,true)

                            for k,v in pairs(self.game.communityCards) do
                                self.wndTable:FindChild("CardHolder"):FindChild("Card"..tostring(k)):SetSprite(self.cards[v].sprite)
                                self.wndTable:FindChild("CardHolder"):FindChild("Card"..tostring(k)):Show(true)
                            end
                        end

                        -- Update Pot
                        self:UpdatePot()

                        -- Update Player Frames
                        for i = 1, 10 do
                            if self.players[i].active == true then
                                if self:IsPlayingRound(i) then
                                    if self.seat ~= i then
                                        self.wndPlayers[i]:FindChild("CardHolder"):Show(false,true)
                                        self.wndPlayers[i]:FindChild("CardHolder_Back"):Show(true,true)
                                    end
                                else
                                    self.wndPlayers[i]:SetOpacity(0.5)
                                    self.wndPlayers[i]:FindChild("CardHolder"):Show(false,true)
                                    self.wndPlayers[i]:FindChild("CardHolder_Back"):Show(false,true)
                                end

                                -- Update Player Pots
                                self:UpdatePlayerPot(i)

                                if self.seat == i then
                                    self.wndPlayers[self.seat]:FindChild("CardHolder"):Show(true,true)
                                    self.wndPlayers[self.seat]:FindChild("CardHolder_Back"):Show(false,true)

                                    for k,v in pairs(self.players[i].cards) do
                                        self.wndPlayers[self.seat]:FindChild("CardHolder"):FindChild("Card"..tostring(k)):SetSprite(self.cards[v].sprite)
                                        self.wndPlayers[self.seat]:FindChild("CardHolder"):FindChild("Card"..tostring(k)):Show(true,true)
                                    end
                                end
                            end
                        end
                    end

                    -- Reset Bet Settings
                    self.wndTable:FindChild("BetSetting"):FindChild("CashWindow"):SetAmount(0)
                    self.wndTable:FindChild("BetSetting"):FindChild("CashSlider"):SetValue(0)

                    -- Reset Nav
                    self:ResetNav()
                    self:UpdateNav(self.current == self.seat)

                    -- Check Top Nav
                    self:CheckButtons()
                    self:CheckBlinds()
                else
                    self.wndPlayers[i]:Show(true,true)
                    self.wndPlayers[i]:FindChild("PlayerName"):FindChild("Text"):SetText(self.players[i].name)
                    self.wndPlayers[i]:FindChild("CashWindow"):SetAmount(self.players[i].cash)
                end
            end
        end
    else
        -- Show open seats
        for i = 1, 10 do
            if self.players[i].active == false then
                if self.game.buyIn > 0 and self.name ~= self.game.host then
                    local strMessage = tostring(self.name) .. "  joins the table!"
                    local nDeliverySpeed = MailSystemLib.MailDeliverySpeed_Instant

                    self.wndSeats[i]:FindChild("CashWindow"):SetAmount(self.game.buyIn)
                    self.wndSeats[i]:FindChild("JoinGame"):SetActionData(GameLib.CodeEnumConfirmButtonType.SendMail, self.game.host, self.game.realm, self.game.name, strMessage, nil, nDeliverySpeed, 0, self.wndSeats[i]:FindChild("CashWindow"):GetCurrency())
                    self.wndSeats[i]:FindChild("JoinGame"):Show(true,true)
                    self.wndSeats[i]:FindChild("Button"):Show(false,true)

                    if self.game.buyIn > GameLib.GetPlayerCurrency():GetAmount() then
                        self.wndSeats[i]:FindChild("JoinGame"):Enable(false)
                        self.wndSeats[i]:SetTooltip("Not enough funds.")
                    else
                        self.wndSeats[i]:FindChild("JoinGame"):Enable(true)
                        self.wndSeats[i]:SetTooltip("")
                    end
                else
                    self.wndSeats[i]:FindChild("JoinGame"):Show(false,true)
                    self.wndSeats[i]:FindChild("Button"):Show(true,true)
                end

                self.wndSeats[i]:Show(not self.game.closed,true)
            else
                self.wndPlayers[i]:Show(true,true)
                self.wndPlayers[i]:FindChild("PlayerName"):FindChild("Text"):SetText(self.players[i].name)
                self.wndPlayers[i]:FindChild("CashWindow"):SetAmount(self.players[i].cash)
            end
        end

        -- Reset Seat
        self.seat = nil

        -- Reset Bet Settings
        self.wndTable:FindChild("BetSetting"):FindChild("CashWindow"):SetAmount(0)
        self.wndTable:FindChild("BetSetting"):FindChild("CashSlider"):SetValue(0)

        -- Reset Nav
        self:ResetNav()
        self:UpdateNav(false)

        -- Show Spectator Warning
        if self.game.active == true then
            self.wndTable:FindChild("Spectator"):Show(true,true)
        end

        -- Hide Top Nav
        self.wndTable:FindChild("Blinds"):Show(false,true)
        self.wndTable:FindChild("Clock"):Show(false,true)
        self:HideButtons()
    end

	-- Show Table
	self:OnToggleMenu()
end

function LUI_Holdem:JoinTable(message)
	local cash = (self.game.buyIn and self.game.buyIn > 0) and self.game.buyIn or self.defaults["cash"]
	local num = message.seat

	-- Override Player Data
	self.players[num].active = true
	self.players[num].cash = cash
	self.players[num].name = message.sender

    -- Notify Host
    if self.name ~= message.sender and self.name == self.game.host and (self.game.buyIn and self.game.buyIn > 0) then
        self:Say("You received" .. self:GetCurrencyString(self:GetCurrency(self.game.buyIn)) .. " from " .. message.sender.. ".")
    end

    -- Update Key
    if self.name == self.game.host then
        self:UpdateKey(message.sender,num)
    end

    -- Update Player Count
	if not self.game.playerCount then
		self.game.playerCount = 1
	else
        if message.sender ~= self.game.host then
            self.game.playerCount = self.game.playerCount + 1
        end
	end

    -- Log Event
    self:Log(message.sender .. " joins the table.")

	-- Make sure seat is hidden
	self.wndSeats[num]:Show(false,true)

	-- Prepare Player Frame
	self.wndPlayers[num]:FindChild("PlayerName"):FindChild("Text"):SetText(message.sender)
	self.wndPlayers[num]:FindChild("CashWindow"):SetAmount(cash)
	self.wndPlayers[num]:Show(true)

    if self.game.host == self.name then
        if not self.game.active == true and self.game.playerCount > 1 then
            self.wndTable:FindChild("BtnStart"):Show(true,true)
        end
    end
end

function LUI_Holdem:OnChooseSeat(wndHandler, wndControl)
	-- Hide all seats
	for i = 1, 10 do
		self.wndSeats[i]:Show(false,true)
	end

    -- Notify Player
    if self.name ~= self.game.host and (self.game.buyIn and self.game.buyIn > 0) then
        self:Say("You sent" .. self:GetCurrencyString(self:GetCurrency(self.game.buyIn)) .. " to " .. self.game.host .. ".")
    end

	-- Save Seat Number
	self.seat = wndControl:GetData()

	local tMessage = {
		sender = self.name,
		action = "join-table",
		seat = self.seat
	}

	self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
	   self:JoinTable(tMessage)
    end
end

function LUI_Holdem:OnLeaveTable(wndHandler, wndControl)
	local tMessage = {}
    local name = self.name

    if type(wndHandler) == "string" then
        name = wndHandler
    end

	if self.game.host == name then
        if self.game.buyIn > 0 and self.game.pot and self.game.pot > 0 and #self.game.players then
            self:System("You cannot leave now!")
            return
        end

        -- Get amount of ppl that should be payed out
        local num = 0

        for i = 1, 10 do
            if self.players[i].active == true and self.players[i].name ~= name then
                local cash = (self.players[i].cash or 0) + (self.players[i].pot or 0)

                if cash > 0 then
                    num = num + 1
                end
            end
        end

		if self.game.buyIn > 0 and num > 0 then
            -- Cash out
            self:ShowCashout()
            return
        end

        -- Stop broadcasting
        self.broadcast:Stop()

        -- Notify Lobby
        tMessage = {
            action = "delete",
            game = self.game.name
        }

        self:Send(tMessage)
	end

    if self.name == name then
        -- Disable Player
        self.active = false

        -- Stop Timer
        self.timer:Stop()
        self.broadcast:Stop()

        -- Leave Table
        self:LeaveTable()
    end

	-- Notify Table
	tMessage = {
		sender = name,
		action = "leave-table",
	}

	self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
       self:PlayerLeftTable(tMessage)
    end
end

function LUI_Holdem:PlayerLeftTable(message)
	for i = 1, 10 do
		if self.players[i].name == message.sender then
            -- Cash out
            if self.game.host == self.name then
                local cash = self.players[i].cash + (self.players[i].pot or 0)

                if self.players[i].active == true and self.game.buyIn > 0 and cash > 0 then
                    self:AddCashout(i)
                    self.wndCashout:FindChild("Container"):ArrangeChildrenVert(0)

                    if not self.wndCashout:IsShown() then
                        self.wndCashout:Show(true)
                    end
                end
            end

            -- Check if game is running
            if self.game.active and self.game.players and self:IsPlayingRound(i) then

                -- Get player sitting next
                local nextPlayer = 0

                for v = 1, #self.players do
                    local num = (v + i) > #self.players and ((v + i) - #self.players) or (v + i)

                    if self.players[num].active == true then
                        nextPlayer = num
                        break
                    end
                end

                -- Check if player is current player in action
                if self.current == i then
                    self.players[i].afk = true

                    -- Fold on behalf of player that left
                    if self.name == self.game.host then
                        self:OnPlayerAction("fold")
                    end
                else
                    -- Remove from active players
                    for k,v in pairs(self.game.players) do
                        if v == i then
                            table.remove(self.game.players,k)
                            break
                        end
                    end
                end

                -- Hide Dealer Button
                if nextPlayer ~= 0 and self.game.dealer == i then
                    self.game.dealer = nextPlayer
                    self.wndTable:FindChild("DealerButton"):Show(false,true)
                end

                -- Hide Small Blind Button
                if self.game.small == i then
                    self.wndTable:FindChild("SmallBlindButton"):Show(false,true)
                end

                -- Hide Big Blind Button
                if self.game.big == i then
                    self.wndTable:FindChild("BigBlindButton"):Show(false,true)
                end

                -- Reset Cash
                self.wndCash[i]:Show(false,true)
                self.wndCash[i]:FindChild("CashWindow"):SetAmount(0,true)
            end

    		-- Reset Player Data
    		self.players[i].name = ""
    		self.players[i].active = false
    		self.players[i].cash = 0
            self.players[i].pot = 0

    		-- Reset Player Frame
    		self.wndPlayers[i]:Show(false)
            self.wndPlayers[i]:FindChild("Glow"):Show(false,true)
            self.wndPlayers[i]:FindChild("Active"):Show(false,true)
            self.wndPlayers[i]:FindChild("PlayerAction"):Show(false,true)
            self.wndPlayers[i]:FindChild("CardHolder_Back"):Show(false,true)
            self.wndPlayers[i]:FindChild("CardHolder"):Show(false,true)

            -- Restore Player Count
            self.game.playerCount = self.game.playerCount - 1

            -- Open Seat for spectators
            if not self.seat then
                self.wndSeats[i]:Show(true)
            end

            break
		end
    end

    -- Update Log
    if message.sender == self.name then
        self:LeaveChannel()
        self:ClearLog()
    else
        self:Log(message.sender .. " left the table.")
    end

    -- Update Buttons
    self:CheckButtons()

    -- Quit Game
    if self.game.host == message.sender then
        -- Stop Timer
        self.timer:Stop()
        self.broadcast:Stop()

        self:System("Host has left the game.")
        self:LeaveChannel()
        self:LeaveTable()
    end
end

function LUI_Holdem:LeaveTable()
	-- Reset Game Data
    self.game = nil
    self.seat = nil
    self.active = false
    self.key = nil
    self.password = nil

    -- Reset Player Data
    for i = 1, 10 do
    	self.players[i] = {
            active = false
        }

    	-- Hide Player Frame
    	self.wndPlayers[i]:Show(false,true)

    	-- Hide Cash Items
    	self.wndCash[i]:Show(false,true)
        self.wndCash[i]:FindChild("CashWindow"):SetAmount(0,true)
    end

    -- Clear Log
    self:ClearLog()

    -- Rebuild Stuff
    self:BuildTable()

    -- Go back to Lobby
    self:OnToggleMenu()
end

function LUI_Holdem:LeaveChannel()
    -- Leave ICComm channel
    if self.gamecom then
        self.gamecom = nil
    end

    -- Leave Game channel
    if self.chat then
        self.chat:Leave()
    end

    -- Leave Chat channel
    if self.chatroom then
        self.chatroom:Leave()
    end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # ROUND
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:PrepareRound()
	self.game.players = {}

	-- Gather Players
	for i = 1, 10 do
		if self.players[i].active == true and self.players[i].cash > 0 then
			table.insert(self.game.players,i)
		end
	end

	-- Set first step
	self.game.round = 1

	-- Set Buttons
    local previousDealer = 0

	if not self.game.dealer then
		previousDealer = math.random(1,#self.game.players)
    else
        for k,v in pairs(self.game.players) do
            if v == self.game.dealer then
                previousDealer = k
                break
            end
        end
	end

	local dealer = (previousDealer + 1) > #self.game.players and 1 or (previousDealer + 1)
	local small = (dealer + 1) > #self.game.players and 1 or (dealer + 1)
	local big = (small + 1) > #self.game.players and 1 or (small + 1)

	if small > #self.game.players then
		small = small - #self.game.players
	end

	if big > #self.game.players then
		big = big - #self.game.players
	end

	self.game.dealer = self.game.players[dealer]
	self.game.small = self.game.players[small]
	self.game.big = self.game.players[big]

	-- Initial Level
	if not self.game.level then
		self.game.level = 1
	end

	-- Check for Levelup
	if self.game.remaining and self.game.remaining <= 0 then
		self.game.level = self.game.level + 1

		local tMessage = {
			action = "blind-raise",
            level = self.game.level
		}

		self:Send(tMessage,true)

        if self.game.conn == "ICComm" then
            self:OnBlindRaise(tMessage)
        end
	end

	-- Set Blinds
	if self.game.buyIn > 0 then
		self.game.blind = self.game.buyIn / self.defaults["blinds"] * self.levels[self.game.level].blind
	else
		self.game.blind = self.defaults["cash"] / self.defaults["blinds"] * self.levels[self.game.level].blind
	end

	if self.levels[self.game.level].ante ~= false then
		self.game.ante = self:Round(self.game.blind / self.levels[self.game.level].ante, -4)
	else
		self.game.ante = 0
	end

    -- Create Cash Array
    local cash = {}

    for i = 1, 10 do
        table.insert(cash,self.players[i].cash or 0)
    end

	local tMessage = {
		action = "new-round",
		players = self.game.players,
        round = self.game.round,
        level = self.game.level,
        dealer = self.game.dealer,
        small = self.game.small,
        big = self.game.big,
        blind = self.game.blind,
        ante = self.game.ante,
        cash = cash,
	}

	self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
	   self:StartRound(tMessage)
    end
end

function LUI_Holdem:StartRound(message)
    -- Update Game Data
    self.game.players = message.players
    self.game.round = message.round
    self.game.level = message.level
    self.game.dealer = message.dealer
    self.game.small = message.small
    self.game.big = message.big
    self.game.blind = message.blind
    self.game.ante = message.ante
	self.game.cards = self.cards

    -- Sync Cash
    for i = 1, 10 do
        self.players[i].cash = message.cash[i]
    end

    -- Position Dealer Button
    self.wndTable:FindChild("DealerButton"):SetAnchorPoints(unpack(self.buttons.positions[self.game.dealer].anchorPoints))
    self.wndTable:FindChild("DealerButton"):SetAnchorOffsets(unpack(self.buttons.positions[self.game.dealer].anchorOffsets))

    -- Position Small Blind Button
    self.wndTable:FindChild("SmallBlindButton"):SetAnchorPoints(unpack(self.buttons.positions[self.game.small].anchorPoints))
    self.wndTable:FindChild("SmallBlindButton"):SetAnchorOffsets(unpack(self.buttons.positions[self.game.small].anchorOffsets))

    -- Position Big Blind Button
    self.wndTable:FindChild("BigBlindButton"):SetAnchorPoints(unpack(self.buttons.positions[self.game.big].anchorPoints))
    self.wndTable:FindChild("BigBlindButton"):SetAnchorOffsets(unpack(self.buttons.positions[self.game.big].anchorOffsets))

	-- Show Buttons
	self.wndTable:FindChild("DealerButton"):Show(self.game.playerCount > 2)
	self.wndTable:FindChild("SmallBlindButton"):Show(true)
	self.wndTable:FindChild("BigBlindButton"):Show(true)

	-- Reset Game Data
    self.game.pot = 0
    self.game.showdown = false
    self.game.communityCards = nil

    -- Reset Pot
	self.wndTable:FindChild("Pot"):Show(false,true)
	self.wndTable:FindChild("PotWindow"):SetAmount(0)

    -- Reset Community Cards
    self.wndTable:FindChild("CardHolder"):Show(false,true)

    for _,card in pairs(self.wndTable:FindChild("CardHolder"):GetChildren()) do
        card:Show(false,true)
    end

    for i = 1, 10 do
        -- Reset Player Opacity
        if self.players[i].active == true and self.players[i].cash > 0 and not self.players[i].afk then
            self.wndPlayers[i]:SetOpacity(1)
        else
            self.wndPlayers[i]:SetOpacity(0.5)
        end

        -- Reset Player Data
        self.players[i].allin = false
        self.players[i].pot = 0
        self.players[i].sidepot = nil
        self.players[i].hand = 0
        self.players[i].cards = {}

        -- Reset Player Cards
        self.wndPlayers[i]:FindChild("CardHolder"):Show(false,true)
        self.wndPlayers[i]:FindChild("CardHolder_Back"):Show(false,true)

        for _,card in pairs(self.wndPlayers[i]:FindChild("CardHolder"):GetChildren()) do
            card:Show(false,true)
        end
    end

	-- Check Blinds
	self:CheckBlinds()

    -- Check Buttons
    self:CheckButtons()

	-- Shuffle Cards
	if self.game.host == self.name then
		self.game.cards = self:Shuffle()
	end

    local initialPet = self.game.blind

	for _,player in pairs(self.game.players) do
		-- Put in Big Blind
		if self.game.big == player then
            local bigBlind = self.game.blind

            if bigBlind > self.players[player].cash then
                bigBlind = self.players[player].cash
                initialPet = self.players[player].cash
            end

			self:PutMoneyIn(player,bigBlind)
		end

		-- Put in Small Blind
		if self.game.small == player then
            local smallBlind = self.game.blind / 2

            if smallBlind > self.players[player].cash then
                smallBlind = self.players[player].cash
            end

			self:PutMoneyIn(player,smallBlind)
		end

		-- Put in Ante
		if self.game.ante > 0 then
            local ante = self.game.ante

            if ante > self.players[player].cash then
                ante = self.players[player].cash
            end

			self:PutMoneyIn(player,ante,true)
		end
	end

	-- Show Pot
	if self.game.ante > 0 then
		self:UpdatePot()
	end

    -- Set Big Blind as current player
    self.current = self.game.big

    -- Set Big Blind as current bet
    self.game.bet = {
        min = self.game.blind,
        amount = initialPet,
        from = self:GetFirstPlayer(),
        orig = 0,
        start = true
    }

    -- Log Event
    self:Log("-- New Round --")

    -- Deal Cards
    if self.game.host == self.name then
        local cards = {}

        for _,player in pairs(self.game.players) do
            if not self.players[player].afk then
                local playerCards = {}

                for k = 1, 2 do
                    local card = self:GetCard()

                    table.insert(playerCards,self:Crypt(tostring(card),self.players[player].key))
                    table.insert(self.players[player].cards,card)
                end

                table.insert(cards,{
                    seat = player,
                    cards = playerCards
                })
            end
        end

        local tMessage = {
            action = "cards",
            cards = cards
        }

        self:Send(tMessage, true)

        if self.game.conn == "ICComm" then
            self:OnReceiveCards(tMessage)
        end
    end
end

function LUI_Holdem:UpdatePot()
    if self.game.pot then
        self.wndTable:FindChild("Pot"):Show(true)
        self.wndTable:FindChild("PotWindow"):SetAmount(self.game.pot)
    else
        self.wndTable:FindChild("Pot"):Show(false)
        self.wndTable:FindChild("PotWindow"):SetAmount(0)
    end
end

function LUI_Holdem:OnReceiveCards(message)
    -- Hide all cards
    for i = 1, 10 do
        self.wndPlayers[i]:FindChild("CardHolder"):Show(false,true)
        self.wndPlayers[i]:FindChild("CardHolder_Back"):Show(false,true)
    end

    -- Show Player Cards
    for _,player in pairs(message.cards) do
        if self.seat and self.seat == player.seat then
            for k,v in pairs(player.cards) do
                self.wndPlayers[player.seat]:FindChild("CardHolder"):FindChild("Card"..tostring(k)):SetSprite(self.cards[tonumber(self:Crypt(v,self.key,true))].sprite)
                self.wndPlayers[player.seat]:FindChild("CardHolder"):FindChild("Card"..tostring(k)):Show(true,true)
            end

            self.wndPlayers[player.seat]:FindChild("CardHolder"):Show(true,true)
            self.wndPlayers[player.seat]:FindChild("CardHolder_Back"):Show(false,true)
        else
            self.wndPlayers[player.seat]:FindChild("CardHolder_Back"):Show(true,true)
        end
    end

    -- Find first player
    self.current = self:GetFirstPlayer()

    -- Put first Player in action
    self:OnNextPlayer()
end

function LUI_Holdem:OnReceiveFlop(message)
    self.wndTable:FindChild("CardHolder"):Show(true,true)

    for k,v in pairs(message.cards) do
        self.wndTable:FindChild("CardHolder"):FindChild("Card"..tostring(k)):SetSprite(self.cards[v].sprite)
        self.wndTable:FindChild("CardHolder"):FindChild("Card"..tostring(k)):Show(true)
    end

    if self.game.showdown and self.game.showdown == true then
        self:OnShowdown()
    else
        -- Find first player
        self.current = self:GetFirstPlayer()

        -- Put first Player in action
        self:OnNextPlayer()
    end
end

function LUI_Holdem:OnReceiveTurn(message)
    self.wndTable:FindChild("CardHolder"):FindChild("Card4"):SetSprite(self.cards[message.card].sprite)
    self.wndTable:FindChild("CardHolder"):FindChild("Card4"):Show(true)

    if self.game.showdown and self.game.showdown == true then
        self:OnShowdown()
    else
        -- Find first player
        self.current = self:GetFirstPlayer()

        -- Put first Player in action
        self:OnNextPlayer()
    end
end

function LUI_Holdem:OnReceiveRiver(message)
    self.wndTable:FindChild("CardHolder"):FindChild("Card5"):SetSprite(self.cards[message.card].sprite)
    self.wndTable:FindChild("CardHolder"):FindChild("Card5"):Show(true)

    if self.game.showdown and self.game.showdown == true then
        self:OnShowdown()
    else
        -- Find first player
        self.current = self:GetFirstPlayer()

        -- Put first Player in action
        self:OnNextPlayer()
    end
end

function LUI_Holdem:OnShowdown()
    if self.game.host == self.name then
        self.game.round = self.game.round + 1
        Apollo.CreateTimer("LUI_Holdem_Showdown", 3, false)
    end
end

function LUI_Holdem:UpdatePlayerPot(player)
    local pot = self.players[player].pot
    local currency = 1

    if pot == 0 then
        self.wndCash[player]:FindChild("CashWindow"):SetAmount(0,true)
        self.wndCash[player]:Show(false)
        return
    end

    if pot >= 1000000 then
        if math.mod(pot, 1000000) == 0 then
            currency = 1
        else
            if math.mod(pot, 10000) == 0 then
                currency = 2
            else
                currency = 3
            end
        end
    else
        if math.mod(pot, 10000) == 0 then
            currency = 2
        end
    end

    if currency > 1 and self.cash[player].grow == true then
        local left,top,right,bottom = unpack(self.cash[player].anchorOffsets)
        self.wndCash[player]:SetAnchorOffsets(left,top,right + (20 * (currency - 1)),bottom)
    end

    self.wndCash[player]:FindChild("CashWindow"):SetAmount(pot,true)
    self.wndCash[player]:Show(true)
end

function LUI_Holdem:PutMoneyIn(player,amount,ante)
	self.players[player].pot = self.players[player].pot + amount
	self.players[player].cash = self.players[player].cash - amount

	self.wndPlayers[player]:FindChild("CashWindow"):SetAmount(self.players[player].cash)

	if not ante then
        self:UpdatePlayerPot(player)
	else
		if not self.game.pot then
			self.game.pot = 0
		end

		self.game.pot = self.game.pot + amount
	end
end

function LUI_Holdem:OnTimerEnd()
    if self.current == self.seat then
        self:ResetNav()
        self:UpdateNav(false)
    end

    if self.players[self.current].warned == true then
        self.players[self.current].afk = true
    else
        self.players[self.current].warned = true
    end

    if self.players[self.current].afk == true and self.current == self.seat then
        self.wndTable:FindChild("BtnSitout"):SetCheck(true)
    end

    if self.game.host == self.name then
        self:OnPlayerAction("check")
    end
end

function LUI_Holdem:OnPlayerAction(wndHandler, wndControl)
    self:ResetNav()
    self:UpdateNav(false)

    local action = ""
    local forced = false

    if type(wndHandler) == "string" then
        action = string.lower(wndHandler)
        forced = true
    else
        action = string.lower(string.sub(wndControl:GetName(),4))
    end

    if self.wndAlert:IsShown() then
        self.wndAlert:Show(false)
        Event_FireGenericEvent("InterfaceMenuList_NewAddOn","LUI Holdem", {"ToggleLUIHoldem", "", "CRB_MinimapSprites:sprMM_VendorGeneral" })
    end

    if not self.players[self.current].afk == true and self.settings.check == true and action == "fold" then
        -- Check/Fold
        if self.game.bet.amount == 0 or self.game.bet.amount == self.players[self.current].pot then
            action = "check"
        end
    end

    if action == "check" and forced == true and not self.players[self.current].afk == true then
        -- Check if AutoCheck is possible
        if self.game.bet.amount >= 0 and self.game.bet.amount ~= self.players[self.current].pot then
            action = "fold"
        end
    elseif action == "check" and forced == true and self.players[self.current].afk == true then
        -- Player was set to afk because of inactivity
        action = "fold"
    end

    local tMessage = {
        action = action,
        forced = forced,
        amount = self.wndTable:FindChild("BetSetting"):FindChild("CashWindow"):GetAmount()
    }

    self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
        self:OnAction(tMessage)
    end
end

function LUI_Holdem:OnAction(message)
    local cash = self.players[self.current].cash
    local text = message.action
    local color = message.action

    if not message.forced then
        self.players[self.current].warned = false
    end

    if message.action == "fold" then
        -- On Fold
        self:Log(self.players[self.current].name .. " folds.")
        self.wndPlayers[self.current]:FindChild("CardHolder_Back"):Show(false)
    elseif message.action == "check" then
        self:Log(self.players[self.current].name .. " checks.")
    elseif message.action == "call" then
        -- On Call
        local amount = self.game.bet.amount - self.players[self.current].pot

        if amount >= cash then
            self:Log(self.players[self.current].name .. " calls. (All In)")
            self:PutMoneyIn(self.current, cash)
            text = "call all in"
            color = "all in"
        else
            self:Log(self.players[self.current].name .. " calls.")
            self:PutMoneyIn(self.current, amount)
        end
    elseif message.action == "raise" then
        -- On Raise
        local bet = {}

        if self.game.bet.amount <= 0 then
            text = "bet"
        end

        if message.amount == cash then
            text = text .. " all in"
            color = "all in"

            if message.amount >= self.game.bet.min then
                bet.min = message.amount - self.game.bet.amount
                bet.amount = message.amount + self.players[self.current].pot
                bet.from = self.current
                bet.orig = 0
            else
                bet.min = self.game.bet.min
                bet.amount = message.amount + self.players[self.current].pot
                bet.from = self.current
                bet.orig = self.game.bet.from
            end

            self.game.bet = bet
            self:Log(self.players[self.current].name .. " raises to"..self:GetCurrencyString(self:GetCurrency(message.amount))..". (All In)")
            self:PutMoneyIn(self.current, message.amount)
        else
            bet.min = message.amount - self.game.bet.amount
            bet.amount = message.amount
            bet.from = self.current
            bet.orig = 0

            self.game.bet = bet
            self:Log(self.players[self.current].name .. " raises to"..self:GetCurrencyString(self:GetCurrency((message.amount - self.players[self.current].pot)))..".")
            self:PutMoneyIn(self.current, (message.amount - self.players[self.current].pot))
        end
    end

    if self.wndPlayers[self.current]:GetOpacity() > 0.5 then
        -- Show Action Animation
        self.wndPlayers[self.current]:FindChild("PlayerAction"):FindChild("BG"):SetText(string.upper(text))
        self.wndPlayers[self.current]:FindChild("PlayerAction"):FindChild("BG"):SetBGColor(self.colors[color])
        self.wndPlayers[self.current]:FindChild("PlayerAction"):SetBGColor(self.colors[color])
        self.wndPlayers[self.current]:FindChild("PlayerAction"):Show(true)
        self:ShowAction(self.current)
    end

    -- Hide Timer
    if self.game.actionTimer > 0 then
        self.actionTimer:Stop()
        self.wndPlayers[self.current]:FindChild("Bar"):Show(false)
    end

    -- Save current player
    local oldPlayer = self.current

    -- Find next player
    self.current = self:GetNextPlayer()

    if message.action == "fold" then
        -- Remove player from active players
        for k,v in pairs(self.game.players) do
            if v == oldPlayer then
                table.remove(self.game.players,k)
                break
            end
        end

        -- Move Bet to next player
        if self.game.bet.from == oldPlayer then
            self.game.bet.from = self.current
        end
    end

    -- Check if we have at least 2 players playing
    if #self.game.players <= 1 then
        self:OnRoundFinished(true)
        return false
    end

    if self.current == 0 then
        -- End of Round
        self:OnRoundFinished()
    else
        -- Put next Player in action
        Apollo.CreateTimer("LUI_Holdem_Next", 1, false)
    end
end

function LUI_Holdem:OnNextPlayer()
    -- Autofold if sitting out
    if self.players[self.current].afk and self.players[self.current].afk == true then
        if self.current == self.seat then
            self:ResetNav()
            self:UpdateNav(false)
        end

        if self.game.host == self.name then
            self:OnPlayerAction("fold")
        end

        return
    end

    -- Autochecking if allin
    if self.players[self.current].cash == 0 then
        if self.current == self.seat then
            self:ResetNav()
            self:UpdateNav(false)
        end

        if self.game.host == self.name then
            self:OnPlayerAction("check")
        end

        return
    end

    -- Show Progress bar
    if self.game.actionTimer > 0 then
        self.players[self.current].timer = os.time()
        self:ShowTimer()
    end

    -- Update Active Player Icon & Border
    for i = 1, 10 do
        self.wndPlayers[i]:FindChild("Glow"):Show(self.current == i and self.seat == i)
        self.wndPlayers[i]:FindChild("Active"):Show(self.current == i)
    end

    -- Update Table Sprite
    for _,table in pairs(self.wndTable:FindChild("TableSprite"):GetChildren()) do
        if table:GetName() == "Sprite"..tostring(self.current) then
            table:Show(true,true)
        else
            table:Show(false,true)
        end
    end

    if self.seat ~= self.current then
       return
    end

	Sound.Play(180)

    local cash = self.players[self.current].cash

    if self.game.bet.amount > 0 then
        -- We are calling or raising
        local call_amount = self.game.bet.amount - self.players[self.current].pot
        local raise_amount = self.game.bet.amount + self.game.bet.min
        local call_text = "Call"..self:GetCurrencyString(self:GetCurrency(call_amount))
        local raise_text = "Raise to"..self:GetCurrencyString(self:GetCurrency(raise_amount))

        if call_amount >= cash then
            call_text = "Call All In"
        end

        if raise_amount >= cash then
            raise_text = "Raise All In"
        end

        local noRaiseAllowed = false

        -- Check for illegal raises
        if self.game.bet.orig and self.game.bet.orig > 0 then
            if self.game.bet.orig == self.current then
                noRaiseAllowed = true
            else
                local players = {}

                -- Get all players sitting between raise and allin
                for i = 1, 9 do
                    local num = (self.game.bet.orig + i) > #self.players and ((self.game.bet.orig + i) - #self.game.players) or (self.game.bet.orig + i)

                    if num == self.game.bet.from then
                        break
                    else
                        table.insert(player,i)
                    end
                end

                -- Check if we are one of them
                for _,v in pairs(players) do
                    if self.current == v then
                        noRaiseAllowed = true
                    end
                end
            end
        end

        -- We are allowed to call and raise
        self.wndTable:FindChild("BtnCheck"):Enable(false)
        self.wndTable:FindChild("BtnCall"):Enable(true)
        self.wndTable:FindChild("BtnRaise"):Enable(true)

        self.wndTable:FindChild("BtnCall"):SetText(call_text)
        self.wndTable:FindChild("BtnRaise"):SetText(raise_text)

        if call_amount == 0 then
            -- We are not allowed to call but can check instead
            self.wndTable:FindChild("BtnCheck"):Enable(true)
            self.wndTable:FindChild("BtnCall"):Enable(false)
            self.wndTable:FindChild("BtnCall"):SetText("Call")
        end

        if noRaiseAllowed == true or call_amount >= cash then
            -- We are not allowed to raise
            self.wndTable:FindChild("BtnRaise"):Enable(false)
            self.wndTable:FindChild("BtnRaise"):SetText("Raise")
        end
    else
        -- We are betting
        local bet_amount = self.game.blind
        local bet_text = "Bet"..self:GetCurrencyString(self:GetCurrency(self.game.blind))

        if bet_amount >= cash then
            bet_text = "Bet All In"
        end

        self.wndTable:FindChild("BtnCheck"):Enable(true)
        self.wndTable:FindChild("BtnCall"):Enable(false)
        self.wndTable:FindChild("BtnRaise"):Enable(true)

        self.wndTable:FindChild("BtnCall"):SetText("Call")
        self.wndTable:FindChild("BtnRaise"):SetText(bet_text)
    end

    -- Enable Main Nav and Betting Nav
    self:UpdateNav(true)

    if self.wndTable:FindChild("BtnRaise"):IsEnabled() == true then
        -- We can raise
        local minRaise = self.game.bet.amount + self.game.bet.min

        if minRaise < self.game.blind then
            minRaise = self.game.blind
        end

        if minRaise >= cash then
            -- Disable Betting Nav
            self.wndTable:FindChild("Blocker2"):Show(true,true)
            self.wndTable:FindChild("BetSetting"):FindChild("CashWindow"):SetAmount(cash,true)
        else
            local totalMoney = (self.game.buyIn and self.game.buyIn > 0) and self.game.buyIn or self.defaults["cash"]
            local tick = totalMoney / self.defaults["blinds"] / 2

            -- Get temporarely size of pot
            local pot = self.game.pot

            for i = 1, 10 do
                pot = pot + self.players[i].pot
            end

            local halfPot = pot / 2

            if pot < minRaise then
                pot = minRaise
            end

            if pot > cash then
                pot = cash
            end

            if halfPot < minRaise then
                halfPot = minRaise
            end

            if halfPot > cash then
                halfPot = cash
            end

            self.wndTable:FindChild("BetSetting"):FindChild("BetBtn1"):SetData(minRaise)
            self.wndTable:FindChild("BetSetting"):FindChild("BetBtn3"):SetData(pot)
            self.wndTable:FindChild("BetSetting"):FindChild("BetBtn4"):SetData(cash)

            if self.game.round == 1 then
                self.wndTable:FindChild("BetSetting"):FindChild("BetBtn2"):SetText("3x BB")
                self.wndTable:FindChild("BetSetting"):FindChild("BetBtn2"):SetData(minRaise + (self.game.blind * 3))
            else
                self.wndTable:FindChild("BetSetting"):FindChild("BetBtn2"):SetData(halfPot)
                self.wndTable:FindChild("BetSetting"):FindChild("BetBtn2"):SetText("1/2")
            end

            self.wndTable:FindChild("BetSetting"):FindChild("CashWindow"):SetAmount(minRaise,true)
            self.wndTable:FindChild("BetSetting"):FindChild("CashSlider"):SetMinMax(minRaise,cash,tick)
            self.wndTable:FindChild("BetSetting"):FindChild("CashSlider"):SetValue(minRaise)
        end
    else
        -- Disable Betting Nav
        self.wndTable:FindChild("Blocker2"):Show(true,true)
    end

    -- Show Player Notification
    self:NotifyPlayer()
end

function LUI_Holdem:GetFirstPlayer()
    local current = 0
    local nextPlayer = 0

    for k,v in pairs(self.game.players) do
        if self.current == v then
            current = k
            break
        end
    end

    for i = 1, 9 do
        local num = (current + i) > #self.game.players and ((current + i) - #self.game.players) or (current + i)

        if self.players[self.game.players[num]].active == true then
            if self.players[self.game.players[num]].cash > 0 then
                nextPlayer = self.game.players[num]
                break
            end
        end
    end

    return nextPlayer
end

function LUI_Holdem:GetNextPlayer()
    local player = self.current
    local nextPlayer = 0
    local current = 0

    for k,v in pairs(self.game.players) do
        if player == v then
            current = k
            break
        end
    end

    for i = 1, 9 do
        local num = (current + i) > #self.game.players and ((current + i) - #self.game.players) or (current + i)

        if self.game.bet then
            if self.game.bet.start and self.game.bet.start == true then
                self.game.bet.start = false
            else
                if self.game.bet.from and self.game.players[num] == self.game.bet.from then
                    break
                end
            end
        end

        if self.game.players[num] == player then
            break
        end

        if self.players[self.game.players[num]].active == true then
            if self.players[self.game.players[num]].cash > 0 then
                nextPlayer = self.game.players[num]
                break
            end
        end
    end

    return nextPlayer
end

function LUI_Holdem:OnRoundFinished(canceled)
    -- Reset Table Sprite
    for _,table in pairs(self.wndTable:FindChild("TableSprite"):GetChildren()) do
        if table:GetName() == "Sprite0" then
            table:Show(true,true)
        else
            table:Show(false,true)
        end
    end

    -- Start next betting round
    self.game.round = self.game.round + 1

    -- Check all pots, create sidepots, refund stuff if necessary
    self:CheckPots()

    -- Update Pot
    self:UpdatePot()

    for i = 1, 10 do
        -- Remove Active Player Border
        self.wndPlayers[i]:FindChild("Glow"):Show(false)

        -- Remove Active Icon
        self.wndPlayers[i]:FindChild("Active"):Show(false)

        -- Hide Cash
        self.wndCash[i]:Show(false,true)
        self.wndCash[i]:FindChild("CashWindow"):SetAmount(0,true)

        -- Reset Player Pots
        self.players[i].pot = 0
    end

    -- Start at player next to dealer again
    self.current = self.game.dealer

    -- Should we start we showdown?
    local num = 0

    -- Count active players that are not all in (needed for showdown)
    for _,i in pairs(self.game.players) do
        if self.players[i].cash > 0 then
            num = num + 1
        end
    end

    if num > 1 then
        self.game.showdown = false
    else
        self.game.showdown = true
    end

    if not self.game.showdown then
        -- Reset Bet
        self.game.bet = {
            min = self.game.blind,
            amount = 0,
            from = self:GetFirstPlayer(),
            start = true,
            orig = 0
        }
    end

    if self.game.host ~= self.name then
        return
    end

    if canceled then
        -- Buiild Result
        local result = {}

        if #self.game.players > 0 then
            result = {
                [1] = {
                    size = self.game.pot,
                    players = {
                        [1] = {
                            seat = self.game.players[1] or 0
                        }
                    }
                }
            }
        end

        -- Broadcast Result
        local tMessage = {
            action = "result",
            result = result,
            canceled = true
        }

        self:Send(tMessage, true)

        if self.game.conn == "ICComm" then
            self:OnRoundResult(tMessage)
        end

        return
    end

    if self.game.showdown == true then
        local cards = {}

        for _,v in pairs(self.game.players) do
            table.insert(cards,{
                seat = v,
                cards = self.players[v].cards
            })
        end

        local tMessage = {
            action = "showdown",
            cards = cards
        }

        self:Send(tMessage, true)

        if self.game.conn == "ICComm" then
            self:OnStartShowdown(tMessage)
        end
    else
        self:OnNextRound()
    end
end

function LUI_Holdem:OnNextRound()
    if self.game.round == 2 then
        -- Reset community cards
        self.game.communityCards = {}

        -- Burn 1 card
		self:GetCard()		

        for i = 1, 3 do
            -- Create flop
            table.insert(self.game.communityCards,self:GetCard())
        end

        local tMessage = {
            action = "flop",
            cards = self.game.communityCards
        }

        self:Send(tMessage, true)

        if self.game.conn == "ICComm" then
            self:OnReceiveFlop(tMessage)
        end
    elseif self.game.round == 3 then
        -- Burn 1 card
		self:GetCard()
		
        -- Create turn card
        local turn = self:GetCard()

        -- Add turn card to community cards
        table.insert(self.game.communityCards,turn)

        local tMessage = {
            action = "turn",
            card = turn
        }

        self:Send(tMessage, true)

        if self.game.conn == "ICComm" then
            self:OnReceiveTurn(tMessage)
        end
    elseif self.game.round == 4 then
        -- Burn 1 card
		self:GetCard()		

        -- Create river card
        local river = self:GetCard()

        -- Add river card to community cards
        table.insert(self.game.communityCards,river)

        local tMessage = {
            action = "river",
            card = river
        }

        self:Send(tMessage, true)

        if self.game.conn == "ICComm" then
            self:OnReceiveRiver(tMessage)
        end
    elseif self.game.round == 5 then
        self:Evaluate()
    end
end

function LUI_Holdem:Evaluate()
    -- Build Community Cards
    local board = {}
    local pots = {}

    for _,c in pairs(self.game.communityCards) do
        table.insert(board,card:new(self.cards[c].rank, self.cards[c].suit))
    end

    -- Evaluate player hands
    for _,player in pairs(self.game.players) do
        local hand = {}

        -- Build Hand
        for _,c in pairs(self.players[player].cards) do
            table.insert(hand,card:new(self.cards[c].rank, self.cards[c].suit))
        end

        -- Get Hand Power
        self.players[player].hand = analysis:evaluate(hand, board)

        -- Gather Sidepots
        if self.players[player].sidepot and self.players[player].sidepot > 0 and self.players[player].sidepot ~= self.game.pot then
            local i = 0

            for k,v in pairs(pots) do
                if v.size == self.players[player].sidepot then
                    i = k
                    break
                end
            end

            if i == 0 then
                table.insert(pots,{
                    size = self.players[player].sidepot,
                    players = {}
                })
            end
        end
    end

    local pot = self.game.pot

    if #pots >= 1 then
        -- Order sidepots according to its size (ASC)
        table.sort(pots, function(a,b) return a.size < b.size end)

        -- Calculate pot sizes
        local sidepot = 0

        for i = 1, #pots do
            if i == 1 then
                sidepot = pots[i].size
            else
                pots[i].size = pots[i].size - sidepot
                sidepot = sidepot + pots[i].size
            end
        end

        -- Calculate final pot
        pot = pot - sidepot
    end

    if pot > 0 then
        table.insert(pots,{
            size = pot,
            players = {}
        })
    end

    -- Set players which are competing for each pot
    for i = 1, #pots do
        for _,v in pairs(self.game.players) do
            if self.players[v].sidepot ~= nil then
                if self.players[v].sidepot >= pots[i].size then
                    table.insert(pots[i].players,v)
                    self.players[v].sidepot = self.players[v].sidepot - pots[i].size
                end
            else
                table.insert(pots[i].players,v)
            end
        end
    end

    -- Determine winners
    for i = 1, #pots do
        local winner = {}
        local hand = 0

        for _,v in pairs(pots[i].players) do
            if self.players[v].hand < hand or hand == 0 then
                hand = self.players[v].hand
                winner = {}

                table.insert(winner,{
                    seat = v,
                    cards = self.players[v].cards
                })
            elseif self.players[v].hand == hand then
                table.insert(winner,{
                    seat = v,
                    cards = self.players[v].cards
                })
            end
        end

        pots[i].players = winner
    end

    -- Broadcast Result
    local tMessage = {
        action = "result",
        result = pots
    }

    self:Send(tMessage, true)

    if self.game.conn == "ICComm" then
        self:OnRoundResult(tMessage)
    end
end

function LUI_Holdem:OnRoundResult(message)
    local winners = {}

    for k,pot in pairs(message.result) do
        for _,v in pairs(pot.players) do
            -- Show Overlay
            local text = "WON"
            local color = "won"
            local count = #pot.players

            if k == 1 then
                if count > 1 then
                    text = "WON (SPLIT)"
                end
            else
                color = "side"
                text = "WON SIDEPOT"

                if count > 1 then
                    text = "WON SIDEPOT (SPLIT)"
                end
            end

            -- Check if this player already won something
            local won = false

            for _,winner in pairs(winners) do
                if winner == v.seat then
                    won = true
                end
            end

            if not won then
                -- Add player to winner list
                table.insert(winners,v.seat)

                -- Show Overlay
                self.wndPlayers[v.seat]:FindChild("PlayerAction"):FindChild("BG"):SetText(text)
                self.wndPlayers[v.seat]:FindChild("PlayerAction"):FindChild("BG"):SetBGColor(self.colors[color])
                self.wndPlayers[v.seat]:FindChild("PlayerAction"):SetBGColor(self.colors[color])
                self.wndPlayers[v.seat]:FindChild("PlayerAction"):Show(true)
                self:ShowAction(v.seat,6)

                -- Show Cards
                if not message.canceled then
                    for cardIterator,card in pairs(v.cards) do
                        self.wndPlayers[v.seat]:FindChild("CardHolder"):FindChild("Card"..tostring(cardIterator)):SetSprite(self.cards[card].sprite)
                        self.wndPlayers[v.seat]:FindChild("CardHolder"):FindChild("Card"..tostring(cardIterator)):Show(true,true)
                    end

                    self.wndPlayers[v.seat]:FindChild("CardHolder_Back"):Show(false,true)
                    self.wndPlayers[v.seat]:FindChild("CardHolder"):Show(true,true)
                end
            end

            -- Pay Winnings
            local amount = pot.size / count

            -- Announce Winner
            local text_pot = ""
            local text_split = ""

            if k > 1 then
                if k > 2 then
                    text_pot = " Sidepot "..tostring(k-1)..":"
                else
                    text_pot = " Sidepot:"
                end
            end

            if count > 1 then
                text_split = " (Split)"
            end

            self:Log(self.players[v.seat].name .. " wins"..text_pot..self:GetCurrencyString(self:GetCurrency(amount))..text_split)

            self.players[v.seat].cash = self.players[v.seat].cash + amount
            self.wndPlayers[v.seat]:FindChild("CashWindow"):SetAmount(self.players[v.seat].cash)
        end
    end

    -- Wait a little bit before starting next round
    Apollo.CreateTimer("LUI_Holdem_Wait", 6, false)
end

function LUI_Holdem:OnStartShowdown(message)
    for _,player in pairs(message.cards) do
        for k,v in pairs(player.cards) do
            self.wndPlayers[player.seat]:FindChild("CardHolder"):FindChild("Card"..tostring(k)):SetSprite(self.cards[v].sprite)
            self.wndPlayers[player.seat]:FindChild("CardHolder"):FindChild("Card"..tostring(k)):Show(true,true)
        end

        self.wndPlayers[player.seat]:FindChild("CardHolder_Back"):Show(false,true)
        self.wndPlayers[player.seat]:FindChild("CardHolder"):Show(true,true)
    end

    for i = 1, 10 do
        self.wndPlayers[i]:FindChild("Glow"):Show(false,true)
        self.wndPlayers[i]:FindChild("Active"):Show(false,true)
        self.wndPlayers[i]:FindChild("PlayerAction"):Show(false,true)
    end

    for _,table in pairs(self.wndTable:FindChild("TableSprite"):GetChildren()) do
        if table:GetName() == "Sprite0" then
            table:Show(true,true)
        else
            table:Show(false,true)
        end
    end

    if self.game.host == self.name then
        Apollo.CreateTimer("LUI_Holdem_Showdown", 2, false)
    end
end

function LUI_Holdem:OnShowdownTimer()
    self:OnNextRound()
end

function LUI_Holdem:OnWait()
    -- Start new round
    if self.game.host == self.name then
        if self.game.playerCount >= 2 then
            local num = 0
            local winner = 0

            for i = 1, 10 do
                if self.players[i].active == true and self.players[i].cash > 0 and not self.players[i].afk then
                    num = num + 1
                    winner = i
                end
            end

            if num >= 2 then
                self:PrepareRound()
            else
                tMessage = {
                    action = "stop",
                    winner = winner
                }

                self:Send(tMessage,true)

                if self.game.conn == "ICComm" then
                    self:OnStop(tMessage)
                end
            end
        else
            tMessage = {
                action = "stop"
            }

            self:Send(tMessage,true)

            if self.game.conn == "ICComm" then
                self:OnStop(tMessage)
            end
        end
    end
end

function LUI_Holdem:CheckPots()
    if #self.game.players > 1 then
        local first = 0
        local player = 0
        local second = 0
        local diff = 0

        for _,i in pairs(self.game.players) do
            if self.players[i].pot > first then
                second = first
                first = self.players[i].pot
                player = i
            else
                if self.players[i].pot == first or self.players[i].pot > second then
                    second = self.players[i].pot
                end
            end
        end

        if first > 0 and second > 0 and first ~= second then
            diff = first - second
        end

        if diff > 0 then
            -- One player paid more then others
            self.players[player].pot = self.players[player].pot - diff
            self.players[player].cash = self.players[player].cash + diff

            self.wndPlayers[player]:FindChild("CashWindow"):SetAmount(self.players[player].cash)
            self:UpdatePlayerPot(player)
        end
    end

    -- Create Sidepots if needed
    for _,i in pairs(self.game.players) do
        if self.players[i].cash == 0 and not self.players[i].sidepot then
            local sidepot = 0

            for _,player in pairs(self.game.players) do
                if self.players[player].pot >= self.players[i].pot then
                    sidepot = sidepot + self.players[i].pot
                else
                    sidepot = sidepot + self.players[player].pot
                end
            end

            self.players[i].sidepot = self.game.pot + sidepot
        end
    end

    for i = 1, 10 do
        -- Update Main Pot
        self.game.pot = self.game.pot + self.players[i].pot

        -- Reset Player Pots
        self.players[i].pot = 0
    end
end

function LUI_Holdem:NotifyPlayer()
    if not self.wndTable:IsShown() and not self.players[self.seat].afk then
        -- Change Icon
        Event_FireGenericEvent("InterfaceMenuList_NewAddOn","LUI Holdem", {"ToggleLUIHoldem", "", "ClientSprites:sprItem_NewQuest" })

        -- Show Alert
        if self.settings["alert"] == true then
            self.wndAlert:Show(true)
            Apollo.CreateTimer("LUI_Holdem_Alert", 10, false)
        end

        -- Play Sound
        if self.settings["sound"] == true then
            Sound.Play(198)
        end
    end
end

function LUI_Holdem:OnAlert()
    self.wndAlert:Show(false)
end

function LUI_Holdem:OnQuickBet(wndHandler, wndControl)
	if not self.game.blind then
		return
	end

    if not self.wndTable:FindChild("BtnRaise"):IsEnabled() then
        return
    end

	local amount = wndControl:GetData()
    local allin = false

    if amount >= self.players[self.seat].cash then
        amount = self.players[self.seat].cash
        allin = true
    end

	self.wndTable:FindChild("BetSetting"):FindChild("CashWindow"):SetAmount(amount,true)
	self.wndTable:FindChild("BetSetting"):FindChild("CashSlider"):SetValue(amount)

	local raise = self:GetCurrencyString(self:GetCurrency(amount))

    if self.game.bet and self.game.bet.amount > 0 then
        if allin then
            self.wndTable:FindChild("BtnRaise"):SetText("Raise to All In")
        else
            self.wndTable:FindChild("BtnRaise"):SetText("Raise to"..raise)
        end
    else
        if allin then
            self.wndTable:FindChild("BtnRaise"):SetText("Bet All In")
        else
            self.wndTable:FindChild("BtnRaise"):SetText("Bet"..raise)
        end
    end
end

function LUI_Holdem:OnBetSlider(wndHandler, wndControl)
    if not self.wndTable:FindChild("BtnRaise"):IsEnabled() then
        return
    end

    local amount = wndHandler:GetValue()
    local allin = false

    if amount >= self.players[self.seat].cash then
        amount = self.players[self.seat].cash
        allin = true
    end

    self.wndTable:FindChild("BetSetting"):FindChild("CashWindow"):SetAmount(wndHandler:GetValue(),true)

	local raise = self:GetCurrencyString(self:GetCurrency(amount))

    if self.game.bet and self.game.bet.amount > 0 then
        if allin then
            self.wndTable:FindChild("BtnRaise"):SetText("Raise to All In")
        else
            self.wndTable:FindChild("BtnRaise"):SetText("Raise to"..raise)
        end
    else
        if allin then
            self.wndTable:FindChild("BtnRaise"):SetText("Bet All In")
        else
            self.wndTable:FindChild("BtnRaise"):SetText("Bet"..raise)
        end
    end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # PLAYER CONTEXT MENU
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:OnButtonDown(wndHandler, wndControl, eMouseButton, x, y)
    if self.name ~= self.game.host then
        return
    end

    if wndHandler:FindChild("PlayerName"):FindChild("Text"):GetText() == self.name then
        --return
    end

    if eMouseButton == GameLib.CodeEnumInputMouse.Right then
        if self.wndMenu and self.wndMenu:IsValid() then
            self.wndMenu:Destroy()
            self.wndMenu = nil
        end

        self.wndMenu = Apollo.LoadForm(self.xmlDoc, "PlayerMenu", wndControl, self)
        self.wndMenu:SetData(wndHandler:FindChild("PlayerName"):FindChild("Text"):GetText())
        self.wndMenu:SetOpacity(1)
        self.wndMenu:Show(true)

        if wndControl:GetName() == "Top" then
            self.wndMenu:SetAnchorOffsets(150,100,350,210)
        else
            self.wndMenu:SetAnchorOffsets(150,30,350,140)
        end

        if self.game.active == true then
            self.wndMenu:FindChild("BtnSetAfk"):Enable(true)
        else
            self.wndMenu:FindChild("BtnSetAfk"):Enable(false)
        end
    end
end

function LUI_Holdem:OnBtnKick(wndHandler, wndControl)
    if not self.wndMenu then
        return
    end

    self.wndMenu:Show(false)

    if not self.wndMenu:GetData() then
        return
    end

    tMessage = {
        action = "kick",
        name = self.wndMenu:GetData()
    }

    self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
        self:OnKick(tMessage)
    end
end

function LUI_Holdem:OnKick(message)
    self:OnLeaveTable(message.name)
end

function LUI_Holdem:OnSetInactiveBtn(wndHandler, wndControl)
    if not self.wndMenu then
        return
    end

    self.wndMenu:Show(false)

    if not self.wndMenu:GetData() then
        return
    end

    -- Find Seat
    local seat = 0

    for i = 1, 10 do
        if self.players[i].name and self.players[i].name == self.wndMenu:GetData() then
            seat = i
            break
        end
    end

    if seat == 0 then
        return
    end

    tMessage = {
        action = "sitout",
        seat = seat,
        value = true
    }

    self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
        self:OnSitout(tMessage)
    end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # REBUY
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:OnBtnRebuy()
    if not self.game.rebuy then
        self:System("This table does not allow to rebuy.")
        return
    end

    if self:IsPlayingRound(self.seat) then
        self:System("You cannot rebuy while playing.")
        return
    end

    if self.players[self.seat].cash > 0 then
        self:System("You cannot rebuy! You still have gold!")
        return
    end

    if self.game.rebuy <= 2 then
        if self.players[self.seat].rebuy and self.players[self.seat].rebuy == self.game.rebuy then
            self:System("You have no rebuys left.")
            return
        end
    end

    if not self.wndRebuy then
        self.wndRebuy = self.wndTable:FindChild("RebuyForm")
    end

    if self.game.buyIn and self.game.buyIn > 0 then
        local strMessage = tostring(self.name) .. "  rebuys into the table!"
        local nDeliverySpeed = MailSystemLib.MailDeliverySpeed_Instant

        self.wndRebuy:FindChild("ButtonReal"):FindChild("ButtonText"):SetText("Rebuy"..self:GetCurrencyString(self:GetCurrency(self.game.buyIn)))

        self.wndRebuy:FindChild("CashWindow"):SetAmount(self.game.buyIn)
        self.wndRebuy:FindChild("ButtonReal"):SetActionData(GameLib.CodeEnumConfirmButtonType.SendMail, self.game.host, self.game.realm, self.game.name, strMessage, nil, nDeliverySpeed, 0, self.wndRebuy:FindChild("CashWindow"):GetCurrency())

        self.wndRebuy:FindChild("Button"):Show(false,true)
        self.wndRebuy:FindChild("ButtonReal"):Show(true,true)
    else
        self.wndRebuy:FindChild("Button"):FindChild("ButtonText"):SetText("Rebuy"..self:GetCurrencyString(self:GetCurrency(self.defaults["cash"])))
        self.wndRebuy:FindChild("Button"):Show(true,true)
        self.wndRebuy:FindChild("ButtonReal"):Show(false,true)
    end

    self:OnToggleRebuy()
end

function LUI_Holdem:OnSendRebuy(wndHandler, wndControl)
    -- Update Player specific Rebuy count
    if not self.players[self.seat].rebuy then
        self.players[self.seat].rebuy = 1
    else
        self.players[self.seat].rebuy = self.players[self.seat].rebuy + 1
    end

    -- Update TopNav
    self:CheckButtons()

    tMessage = {
        action = "rebuy",
        seat = self.seat
    }

    self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
        self:OnRebuy(tMessage)
    end

    self.wndRebuy:Show(false)
end

function LUI_Holdem:OnRebuy(message)
    local amount = (self.game.buyIn and self.game.buyIn > 0) and self.game.buyIn or self.defaults["cash"]

    if self.game.buyIn and self.game.buyIn > 0 then
        if message.seat == self.seat then
            -- Notify Player
            self:Say("You sent" .. self:GetCurrencyString(self:GetCurrency(self.game.buyIn)) .. " to " .. self.game.host .. ".")
        end

        if self.name == self.host then
            -- Notify Host
            self:Say("You received" .. self:GetCurrencyString(self:GetCurrency(self.game.buyIn)) .. " from " .. self.players[message.seat].name .. ".")
        end
    end

    -- Log Event
    self:Log(self.players[message.seat].name .. " did a rebuy.")

    -- Notify Table
    self:System(self.players[message.seat].name .. " did a rebuy.")

    -- Update Cash
    self.players[message.seat].cash = amount
    self.wndPlayers[message.seat]:FindChild("CashWindow"):SetAmount(amount)
end

function LUI_Holdem:OnToggleRebuy()
    if self.wndRebuy:IsShown() then
        self.wndRebuy:Show(false)
    else
        self.wndRebuy:Show(true)
    end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # CASHOUT
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:ShowCashout()
    if not self.wndCashout then
        self.wndCashout = self.wndTable:FindChild("CashForm")
    end

    for _,cashout in pairs(self.wndCashout:FindChild("Container"):GetChildren()) do
        cashout:Destroy()
    end

    local num = 0

    for i = 1, 10 do
        if self.players[i].active == true and self.players[i].name ~= self.name then
            local cash = (self.players[i].cash or 0) + (self.players[i].pot or 0)

            if cash > 0 then
                self:AddCashout(i)
                num = num + 1
            end
        end
    end

    self.wndCashout:FindChild("Container"):ArrangeChildrenVert(0)
    self.wndCashout:Show(true)
end

function LUI_Holdem:OnCashout(wndHandler, wndControl)
    wndControl:GetParent():Show(false)

    -- Update Player Cash
    local playerName = wndControl:GetParent():FindChild("GameName"):GetText()

    for i = 1, 10 do
        if self.players[i].name == playerName then
            self.players[i].cash = 0
            self.players[i].pot = 0
            self.wndPlayers[i]:FindChild("CashWindow"):SetAmount(0)
        end
    end

    -- Notify Host
    self:Say("You sent" .. self:GetCurrencyString(self:GetCurrency(wndControl:GetParent():FindChild("CashWindow"):GetAmount())) .. " to " .. playerName .. ".")

    -- Delete Cashout
    for _,cashout in pairs(self.wndCashout:FindChild("Container"):GetChildren()) do
        if cashout:FindChild("GameName"):GetText() == playerName then
            cashout:Destroy()
        end
    end

    -- Check if there is someone else to pay.
    local num = 0

    for _,cashout in pairs(self.wndCashout:FindChild("Container"):GetChildren()) do
        if cashout:IsShown() == true then
            num = num + 1
        end
    end

	if num > 0 then
		self.wndCashout:FindChild("Container"):ArrangeChildrenVert(0)
	else
		self.wndCashout:Show(false)
	end
end

function LUI_Holdem:AddCashout(user)
    -- Check if cashout already exists
    local exists = false

    for _,cashout in pairs(self.wndCashout:FindChild("Container"):GetChildren()) do
        if cashout:FindChild("GameName"):GetText() == self.players[user].name then
            exists = true
        end
    end

    if exists == true then
        return
    end

    -- Create new cashout
	local wndUser = Apollo.LoadForm(self.xmlDoc, "GameItem", self.wndCashout:FindChild("Container"), self)
	local nDeliverySpeed = MailSystemLib.MailDeliverySpeed_Instant
	local strMessage = "More luck next time!"
	local i = user
    local cash = (self.players[i].cash or 0) + (self.players[i].pot or 0)

	if cash > self.game.buyIn then
		strMessage = "Congratulations!"
	end

	local anchorLeft,anchorTop,anchorRight,anchorBottom = wndUser:FindChild("PlayerName"):GetAnchorPoints()
	local offsetLeft,offsetTop,offsetRight,offsetBottom = wndUser:FindChild("PlayerName"):GetAnchorOffsets()

	wndUser:FindChild("GameName"):SetText(self.players[i].name)
	wndUser:FindChild("PlayerName"):SetText("")
	wndUser:FindChild("CashWindow"):SetAnchorPoints(anchorLeft,anchorTop,anchorRight,anchorBottom)
	wndUser:FindChild("CashWindow"):SetAnchorOffsets(offsetLeft,offsetTop,offsetRight,offsetBottom)
	wndUser:FindChild("CashWindow"):SetTextFlags("DT_RIGHT", false)
	wndUser:FindChild("CashWindow"):SetAmount(cash)
	wndUser:FindChild("JoinGame"):Show(false)

	wndUser:FindChild("PayBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.SendMail, self.players[i].name, self.game.realm, self.game.name, strMessage, nil, nDeliverySpeed, 0, wndUser:FindChild("CashWindow"):GetCurrency())

	local offsetLeft,offsetTop,offsetRight,offsetBottom = wndUser:FindChild("PayBtn"):GetAnchorOffsets()
	wndUser:FindChild("PayBtn"):SetAnchorOffsets(offsetLeft,20,offsetRight,-20)

    if cash > GameLib.GetPlayerCurrency():GetAmount() then
        wndUser:FindChild("PayBtn"):Enable(false)
    else
        wndUser:FindChild("PayBtn"):Enable(true)
    end

    wndUser:FindChild("PayBtn"):Show(true,true)
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # TABLE SETTINGS
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:OnOptionsMenuToggle(wndHandler, wndControl)
	self.wndTable:FindChild("OptionsContainer"):Show(self.wndTable:FindChild("OptionsBtn"):IsChecked())
end

function LUI_Holdem:OnOptionsCloseClick()
	self.wndTable:FindChild("OptionsBtn"):SetCheck(false)
	self:OnOptionsMenuToggle()
end

function LUI_Holdem:OnCheckbox(wndHandler, wndControl)
	local setting = wndControl:GetData()
	local value = wndHandler:IsChecked()

	if setting then
		self.settings[setting] = value
	end
end

function LUI_Holdem:OnEnteredCombat(unit, InCombat)
	if unit:IsThePlayer() then
        if self.game.host and self.game.host == self.name then
    		if self.game.active and self.game.active == true and self.settings.combat == true then
    			local tMessage = {
    				action = "pause",
    				value = true,
    				remaining = self.game.remaining
    			}

                self.wndTable:FindChild("BtnPause"):SetCheck(true)
    			self:Send(tMessage,true)

                if self.game.conn == "ICComm" then
                    self:OnPause(tMessage)
                end
            end
        end

		if self.settings.hide == true then
			if self.wndTable and self.wndTable:IsShown() then
				self.wndTable:Close()
			end
		end
	end
end

function LUI_Holdem:OnTimer()
	if not self.game.time then
		self.game.time = os.time()
	end

	self.game.remaining = (self.game.blindRaise * 60) - (os.time() - self.game.time)
	local min = math.floor(self.game.remaining / 60)
	local sec = math.floor(self.game.remaining - (min * 60))

	self.wndTable:FindChild("Clock"):Show(true,true)

	if self.game.remaining > 0 then
		if min < 10 then
			min = "0"..tostring(min)
		end

		if sec < 10 then
			sec = "0"..tostring(sec)
		end

		self.wndTable:FindChild("Clock"):SetText(min..":"..sec)
	else
		self.wndTable:FindChild("Clock"):SetText("00:00")
	end
end

function LUI_Holdem:OnBtnPause(wndHandler, wndControl)
	local tMessage = {
		action = "pause",
		value = wndHandler:IsChecked(),
		remaining = self.game.remaining
	}

	self:Send(tMessage,true)
	self:OnPause(tMessage)
end

function LUI_Holdem:OnPause(message)
	if message.value == true then
		self.timer:Stop()
        self.actionTimer:Stop()
		self.wndTable:FindChild("Notification"):FindChild("Text"):SetText("PAUSE")
		self.wndTable:FindChild("Notification"):Show(true)
        self:UpdateNav(false)
	else
		self.game.time = os.time() - (self.game.blindRaise * 60) + message.remaining
        self.players[self.current].timer = os.time() - self.game.actionTimer + self.players[self.current].remaining
		self.timer:Start()
        self.actionTimer:Start()
		self.wndTable:FindChild("Notification"):Show(false)
        self:UpdateNav(self.current == self.seat)
	end
end

function LUI_Holdem:OnBtnSitout(wndHandler, wndControl)
    tMessage = {
        action = "sitout",
        seat = self.seat,
        value = wndHandler:IsChecked()
    }

    self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
        self:OnSitout(tMessage)
    end
end

function LUI_Holdem:OnSitout(message)
    if message.seat == self.seat then
        self.wndTable:FindChild("BtnSitout"):SetCheck(message.value)
    end

    self.players[message.seat].afk = message.value
end

function LUI_Holdem:OnBtnLock(wndHandler, wndControl)
	tMessage = {
		action = "lock-table",
		value = wndHandler:IsChecked()
	}

	self:Send(tMessage,true)

    if self.game.conn == "ICComm" then
        self:LockTable(tMessage)
    end
end

function LUI_Holdem:OnBtnStart()
	local tMessage = {
		action = "start"
	}

	self:Send(tMessage,true)
	self:OnStart()
	self:PrepareRound()
end

function LUI_Holdem:OnStart()
	self.game.active = true

    for i = 1, 10 do
        self.players[i].afk = false
    end

	self:CheckButtons()

	self.wndTable:FindChild("Clock"):SetText(tostring(self.game.blindRaise)..":00")
	self.wndTable:FindChild("Clock"):Show(true,true)

	self.wndTable:FindChild("Blinds"):SetText()
	self.wndTable:FindChild("Blinds"):Show(true,true)

	self.wndTable:FindChild("Notification"):FindChild("Text"):SetText("START")
	self.wndTable:FindChild("Notification"):Show(true)

	Apollo.CreateTimer("LUI_Holdem_Notification", 3, false)
	self.timer:Start()
end

function LUI_Holdem:OnStop(message)
    self.game.active = false

    self:CheckButtons()

    self.wndTable:FindChild("Clock"):Show(false,true)
    self.wndTable:FindChild("Blinds"):Show(false,true)
    self.timer:Stop()

    -- reset game data
    self.game = {
        name = self.game.name,
        host = self.game.host,
        conn = self.game.conn,
        gameType = self.game.gameType,
        locked = self.game.locked,
        playerCount = self.game.playerCount,
        buyIn = self.game.buyIn,
        realm = self.game.realm,
        faction = self.game.faction,
        blindRaise = self.game.blindRaise,
        actionTimer = self.game.actionTimer,
        rebuy = self.game.rebuy
    }

    -- hide stuff
    self.wndTable:FindChild("DealerButton"):Show(false,true)
    self.wndTable:FindChild("SmallBlindButton"):Show(false,true)
    self.wndTable:FindChild("BigBlindButton"):Show(false,true)

    self.wndTable:FindChild("Pot"):Show(false,true)
    self.wndTable:FindChild("PotWindow"):SetAmount(0)

    self.wndTable:FindChild("CardHolder"):Show(false,true)

    for i = 1, 10 do
        self.wndCash[i]:Show(false,true)
        self.wndCash[i]:FindChild("CashWindow"):SetAmount(0,true)

        self.wndPlayers[i]:FindChild("Glow"):Show(false,true)
        self.wndPlayers[i]:FindChild("Active"):Show(false,true)
        self.wndPlayers[i]:FindChild("PlayerAction"):Show(false,true)
        self.wndPlayers[i]:FindChild("CardHolder"):Show(false,true)
    end

    for _,card in pairs(self.wndTable:FindChild("CardHolder"):GetChildren()) do
        card:Show(false,true)
    end

    if message.winner then
        self:Log(self.players[message.winner].name .. " WON!")
        self.wndTable:FindChild("Notification"):FindChild("Text"):SetText(self.players[message.winner].name .. " WON!")
        self.wndTable:FindChild("Notification"):Show(true)
        Apollo.CreateTimer("LUI_Holdem_Notification", 3, false)
    end
end

function LUI_Holdem:HideButtons()
    self.wndTable:FindChild("BtnLeave"):Show(true,true)
    self.wndTable:FindChild("BtnSitout"):Show(false,true)
    self.wndTable:FindChild("BtnPause"):Show(false,true)
    self.wndTable:FindChild("BtnRebuy"):Show(false,true)
    self.wndTable:FindChild("BtnStart"):Show(false,true)
    self.wndTable:FindChild("BtnLock"):Show(false,true)
    self.wndTable:FindChild("BtnLog"):Show(false,true)
end

function LUI_Holdem:CheckButtons()
	local btnSitout = self.wndTable:FindChild("BtnSitout")
	local btnPause = self.wndTable:FindChild("BtnPause")
	local btnRebuy = self.wndTable:FindChild("BtnRebuy")
	local btnStart = self.wndTable:FindChild("BtnStart")
	local btnLock = self.wndTable:FindChild("BtnLock")
	local btnLog = self.wndTable:FindChild("BtnLog")

	-- Hide all buttons
	btnSitout:Show(false,true)
	btnPause:Show(false,true)
	btnRebuy:Show(false,true)
	btnStart:Show(false,true)
	btnLock:Show(false,true)
	btnLog:Show(false,true)

	if self.game.active == true and self:IsPlaying() == true then
		btnSitout:Show(true,true)
        btnLog:Show(true,true)

		if self.players[self.seat].afk ~= nil and self.players[self.seat].afk == true then
			btnSitout:SetCheck(true)
		else
			btnSitout:SetCheck(false)
		end

		if self.game.host == self.name then
			btnLock:Show(true,true)
			btnPause:Show(true,true)

			if self.game.paused ~= nil and self.game.paused == true then
				btnPause:SetCheck(true)
			else
				btnPause:SetCheck(false)
			end

			if self.game.closed ~= nil and self.game.closed == true then
				btnLock:SetCheck(true)
			else
				btnLock:SetCheck(false)
			end
		end

		if self.game.rebuy and self.game.rebuy > 0 then
            btnRebuy:Show(true,true)

            -- Reposition Log Button
            btnLog:SetAnchorPoints(1,0,1,1)
            btnLog:SetAnchorOffsets(-420,5,-285,-5)

            if self.game.rebuy <= 2 then
                if self.players[self.seat].rebuy and self.players[self.seat].rebuy >= self.game.rebuy then
                    btnRebuy:Enable(false)
                else
                    btnRebuy:Enable(true)
                end
            else
                btnRebuy:Enable(true)
            end
		else
            -- Reposition Sitout Button
			btnLog:SetAnchorPoints(1,0,1,1)
            btnLog:SetAnchorOffsets(-280,5,-145,-5)
		end
	else
		if self.game.host == self.name then
			btnStart:Show(true,true)
		end
	end
end

function LUI_Holdem:OnBlindRaise(message)
    self.game.time = nil
	self.wndTable:FindChild("Notification"):FindChild("Text"):SetText("BLIND RAISE")
	self.wndTable:FindChild("Notification"):Show(true)

    -- Log Event
    local cash = (self.game.buyIn and self.game.buyIn > 0) and self.game.buyIn or self.defaults["cash"]
    local big = cash / self.defaults["blinds"] * self.levels[message.level].blind
    local small = big / 2
    local ante = ""

    if self.levels[message.level].ante ~= false then
        ante = " /"..self:GetCurrencyString(self:GetCurrency(self:Round(big / self.levels[message.level].ante, -4)))
    end

    self:Log("Blind Raise to:"..self:GetCurrencyString(self:GetCurrency(big)).." /"..self:GetCurrencyString(self:GetCurrency(small))..ante)

	Apollo.CreateTimer("LUI_Holdem_Notification", 3, false)
end

function LUI_Holdem:CheckBlinds()
	if not self.game.blind or not self.game.active then
		self.wndTable:FindChild("Blinds"):Show(false,true)
	else
		local bigBlind = self.game.blind / 10000
		self.wndTable:FindChild("Blinds"):SetText(bigBlind .. "g / " .. bigBlind / 2 .. "g")

		if self.game.ante ~= nil and self.game.ante > 0 then
			self.wndTable:FindChild("Blinds"):SetText(bigBlind .. "g / " .. bigBlind / 2 .. "g / " .. self.game.ante / 10000 .. "g")
		end

		self.wndTable:FindChild("Blinds"):Show(true,true)
	end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # LOG
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:BuildLog()
    if not self.wndLog then
        self.wndLog = Apollo.LoadForm(self.xmlDoc, "LogForm", nil, self)
    end

    self.wndLog:Show(false,true)
end

function LUI_Holdem:OnToggleLog()
    if not self.wndLog then
        return
    end

    if self.wndLog:IsShown() then
        self.wndLog:Close()
    else
        self.wndLog:Invoke()
    end
end

function LUI_Holdem:Log(message)
    if not self.wndLog then
        return
    end

    local item = Apollo.LoadForm(self.xmlDoc, "LogItem", self.wndLog:FindChild("List"), self)
    item:FindChild("Text"):SetText(message)
    self.wndLog:FindChild("List"):ArrangeChildrenVert(0)
    local vScroll = self.wndLog:FindChild("List"):GetVScrollRange()
    self.wndLog:FindChild("List"):SetVScrollPos(vScroll)
end

function LUI_Holdem:ClearLog()
    if not self.wndLog then
        return
    end

    for _,item in pairs(self.wndLog:FindChild("List"):GetChildren()) do
        item:Destroy()
    end

    if self.wndLog:IsShown() then
        self.wndLog:Close()
    end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # GENERAL FUNCTIONS
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:SaveKey(name,key)
    local oldkey = 0

    -- Check if there is already a key
    for k,v in pairs(self.keys) do
        if v.name == name then
            oldkey = k
        end
    end

    -- Remove old key
    if oldkey ~= 0 then
        table.remove(self.keys,oldkey)
    end

    -- Insert new key
    table.insert(self.keys,{
        name = name,
        key = key
    })
end

function LUI_Holdem:UpdateKey(name,i)
    local key = nil
    local keyPos = 0

    -- Check if there is already a key
    for k,v in pairs(self.keys) do
        if v.name == name then
            key = v.key
            keyPos = k
        end
    end

    -- Remove old key
    table.remove(self.keys,keyPos)

    -- Save key
    self.players[i].key = key
end

function LUI_Holdem:IsPlayingRound(i)
    if self.game and self.game.players then
        for _,player in pairs(self.game.players) do
            if player == i then
                return true
            end
        end
    end

    return false
end

function LUI_Holdem:IsPlaying()
	for i = 1, 10 do
		if self.players[i].name == self.name then
			return true
		end
	end

	return false
end

function LUI_Holdem:OnGuildRoster(guildCurr, tRoster)
	if guildCurr:GetType() ~= GuildLib.GuildType_Guild then
		return
	end

	self.guild = {}

	for _,member in pairs(tRoster) do
		if member.fLastOnline == 0 then
			self.guild[member.strName] = true
		else
			self.guild[member.strName] = false
		end
	end
end

function LUI_Holdem:IsInGuild(host)
	for _,guild in pairs(GuildLib.GetGuilds()) do
		if guild:GetType() == GuildLib.GuildType_Guild then
			guild:RequestMembers()
		end
	end

	if self.guild[host] then
		if self.guild[host] == true then
			return true
		else
			self:System(host .. " is offline.")
			return false
		end
	else
		return false
	end
end

function LUI_Holdem:IsInGroup(host)
	if not GroupLib.InGroup(self.name) then
		return false
	end

	local count = GroupLib.GetMemberCount()
	for i = 1, count do
		local groupMember = GroupLib.GetGroupMember(i)

		if groupMember.strCharacterName == host then
			if groupMember.bIsOnline == true then
				return true
			else
				self:System(host .. " is offline.")
				return false
			end
		end
	end

	return false
end

function LUI_Holdem:OnNotification()
	self.wndTable:FindChild("Notification"):Show(false)
end

function LUI_Holdem:UpdateNav(state)
	self.wndTable:FindChild("Blocker1"):Show(not state,true)
	self.wndTable:FindChild("Blocker2"):Show(not state,true)
end

function LUI_Holdem:ResetNav()
    self.wndTable:FindChild("BtnFold"):Enable(true)
    self.wndTable:FindChild("BtnCheck"):Enable(true)
    self.wndTable:FindChild("BtnCall"):Enable(true)
    self.wndTable:FindChild("BtnRaise"):Enable(true)
    self.wndTable:FindChild("BtnCall"):SetText("Call")
    self.wndTable:FindChild("BtnRaise"):SetText("Raise")
end

function LUI_Holdem:GetCurrency(amount)
	local silver = 0
	local gold = 0
	local platinum = 0
	local currency = 1

	if (amount / 1000000) >= 1 then
		platinum = math.floor(amount / 1000000)
		amount = amount - (platinum * 1000000)
	end

	if (amount / 10000) >= 1 then
		gold = math.floor(amount / 10000)
		amount = amount - (gold * 10000)
	end

	if (amount / 100) >= 1 then
		silver = math.floor(amount / 100)
	end

	return silver,gold,platinum
end

function LUI_Holdem:GetCurrencyString(silver,gold,platinum)
	local string = ""

	if platinum >= 1 then
		string = " " .. tostring(platinum) .. "p"
	end

	if gold >= 1 then
		string = string .. " " .. tostring(gold) .. "g"
	end

	if silver >= 1 then
		string = string .. " " .. tostring(silver) .. "s"
	end

	return string
end

--[[
function LUI_Holdem:Shuffle(cards)
    math.randomseed(os.time())
    local random = {};

    while #cards > 0 do
        table.insert(random, table.remove(cards, math.random(#cards)));
    end
    return random;
end
]]
--[[
function LUI_Holdem:Shuffle(t, n)
    math.randomseed(os.time())
    if n == nil then n = 1 end
    for i = 1, #t, 1 do
        j = math.random( #t )
        _temp = t[i]
        t[i] = t[j]
        t[j] = _temp
    end
    n = n - 1
    if n > 0 then
        return self:Shuffle( t, n )
    end
    return t
end
]]

function LUI_Holdem:Shuffle()
	math.randomseed(os.time())
	for i = 1, #self.cards, 1 do
		self.validcards[i].valid = true
	end
	local deck = self.cards
	return deck
end

function LUI_Holdem:GetCard()
    local finished = false
    local card = nil
    local final = 0

    for idx = 1, #self.cards, 1 do
        local i = math.random(#self.cards)
        if self.validcards[i].valid == true then
			self.validcards[i].valid = false
            card = i
			finished = true
            break
        end
	end
    if card == nil then
    	self:Shuffle()
		card = self:GetCard()
	end
    return card
end

function LUI_Holdem:ShowTimer()
    if not self.actionTimer then
        self.actionTimer = ApolloTimer.Create(0.5, true, "OnBarTimer", self)
    end

    self.actionTimer:Stop()
    self.actionTimer:Set(0.5, true, "OnBarTimer")
    self.actionTimer:Start()
end

function LUI_Holdem:OnBarTimer()
    if self.current and self.wndPlayers[self.current] and self.players[self.current].active == true then
        local diff = os.time() - self.players[self.current].timer
        self.players[self.current].remaining = self.game.actionTimer - diff

        if self.players[self.current].remaining > 0 then
            self.wndPlayers[self.current]:FindChild("Bar"):SetMax(self.game.actionTimer)
            self.wndPlayers[self.current]:FindChild("Bar"):SetProgress(self.players[self.current].remaining)
            self.wndPlayers[self.current]:FindChild("Bar"):Show(true)
        else
            self.actionTimer:Stop()
            self.wndPlayers[self.current]:FindChild("Bar"):Show(false)
            self:OnTimerEnd()
        end
    else
        self.actionTimer:Stop()
    end
end

function LUI_Holdem:ShowAction(num,duration)
    if not self.actions then
        self.actions = {}
    end

    if not self.actions[tostring(num)] then
        self.actions[tostring(num)] = ApolloTimer.Create(duration, false, "OnActionTimer"..tostring(num), self)
    end

    if not duration then
        duration = 2
    end

    self.actions[tostring(num)]:Stop()
    self.actions[tostring(num)]:Set(duration, false, "OnActionTimer"..tostring(num))
    self.actions[tostring(num)]:Start()
end

function LUI_Holdem:OnActionTimer1()
    if self.wndPlayers[1] then
        self.wndPlayers[1]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[1]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[1]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer2()
    if self.wndPlayers[2] then
        self.wndPlayers[2]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[2]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[2]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer3()
    if self.wndPlayers[3] then
        self.wndPlayers[3]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[3]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[3]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer4()
    if self.wndPlayers[4] then
        self.wndPlayers[4]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[4]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[4]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer5()
    if self.wndPlayers[5] then
        self.wndPlayers[5]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[5]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[5]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer6()
    if self.wndPlayers[6] then
        self.wndPlayers[6]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[6]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[6]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer7()
    if self.wndPlayers[7] then
        self.wndPlayers[7]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[7]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[7]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer8()
    if self.wndPlayers[8] then
        self.wndPlayers[8]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[8]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[8]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer9()
    if self.wndPlayers[9] then
        self.wndPlayers[9]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[9]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[9]:SetOpacity(0.5)
        end
    end
end

function LUI_Holdem:OnActionTimer10()
    if self.wndPlayers[10] then
        self.wndPlayers[10]:FindChild("PlayerAction"):Show(false)

        if self.wndPlayers[10]:FindChild("PlayerAction"):FindChild("BG"):GetText() == "FOLD" then
            self.wndPlayers[10]:SetOpacity(0.5)
        end
    end
end

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #
-- # HELPER FUNCTIONS
-- #
-- #########################################################################################################################################
-- #########################################################################################################################################

function LUI_Holdem:Round(num, digits)
  local mult = 10^(digits or 0)
  return math.floor(num * mult + 0.5) / mult
end

function LUI_Holdem:Copy(t)
	local o = {}

	for k,v in pairs(t) do
		if type(v) == 'table' then
			o[k] = self:Copy(v)
		else
			o[k] = v
		end
	end

	return o
end

function LUI_Holdem:Encode(str,code)
    -- character table
    chars="1234567890!@#$%^&*()qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM ,<.>/?;:'[{]}\|`~"
    -- new code begin
    newcode=""
    -- we start
    for i=1, 999 do
        if string.sub(str,i,i) == "" then
            break
        else
            com=string.sub(str,i,i)
        end
        for x=1, 90 do
            cur=string.sub(chars,x,x)
            if com == cur then
                new=x+code
                while new > 90 do
                    new = new - 90
                end
                newcode=""..newcode..""..string.sub(chars,new,new)..""
            end
        end
    end
    return newcode
end

function LUI_Holdem:Decode(str,code)
    -- character table
    chars="1234567890!@#$%^&*()qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM ,<.>/?;:'[{]}\|`~"
    -- new code begin
    newcode=""
    -- we start
    for i=1, 999 do
        if string.sub(str,i,i) == "" then
            break
        else
            com=string.sub(str,i,i)
        end
        for x=1, 90 do
            cur=string.sub(chars,x,x)
            if com == cur then
                new=x-code
                while new < 0 do
                    new = new + 90
                end
                newcode=""..newcode..""..string.sub(chars,new,new)..""
            end
        end
    end
    return newcode
end

function LUI_Holdem:Extend(...)
    local args = {...}
    for i = 2, #args do
        for key, value in pairs(args[i]) do
            args[1][key] = value
        end
    end
    return args[1]
end

function LUI_Holdem:InsertDefaults(t,defaults)
    for k,v in pairs(defaults) do
        if t[k] == nil then
            if type(v) == 'table' then
                t[k] = self:Copy(v)
            else
                t[k] = v
            end
        else
            if type(v) == 'table' then
                t[k] = self:InsertDefaults(t[k],v)
            end
        end
    end

    return t
end

function convert(chars,dist,inv)
    local charInt = string.byte(chars);
    for i=1,dist do
        if(inv)then charInt = charInt - 1; else charInt = charInt + 1; end
        if(charInt<32)then
            if(inv)then charInt = 126; else charInt = 126; end
        elseif(charInt>126)then
            if(inv)then charInt = 32; else charInt = 32; end
        end
    end
    return string.char(charInt);
end

function LUI_Holdem:Crypt(str,k,inv)
    local enc= "";
    for i=1,#str do
        if(#str-k[5] >= i or not inv)then
            for inc=0,3 do
                if(i%4 == inc)then
                    enc = enc .. convert(string.sub(str,i,i),k[inc+1],inv);
                    break;
                end
            end
        end
    end
    if(not inv)then
        for i=1,k[5] do
            enc = enc .. string.char(math.random(32,126));
        end
    end
    return enc;
end

-----------------------------------------------------------------------------------------------
-- LUI_Holdem Instance
-----------------------------------------------------------------------------------------------
local LUI_HoldemInst = LUI_Holdem:new()
LUI_HoldemInst:Init()
