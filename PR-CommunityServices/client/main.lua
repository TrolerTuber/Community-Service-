local working = false
local animation = false
local services = nil
local trash = nil
local dontleave = false
local propp = "prop_tool_broom" 


local function start()
	lib.requestAnimDict('amb@world_human_janitor@male@idle_a', 1000)
	lib.requestModel('prop_tool_broom', 1000)

	if not HasAnimDictLoaded('amb@world_human_janitor@male@idle_a') then
		print("Failed to load animDict 'amb@world_human_janitor@male@idle_a'")
		return
	end

	ESX.Streaming.RequestAnimDict("amb@world_human_janitor@male@idle_a", function()
		local SCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
		local createobj = CreateObject(GetHashKey(propp), SCoords.x, SCoords.y, SCoords.z, 1, 1, 1)
		local netid = ObjToNet(createobj)
		
		TaskPlayAnim(PlayerPedId(), "amb@world_human_janitor@male@idle_a", "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false)
		AttachEntityToEntity(createobj, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), -0.005, 0.0, 0.0, 360.0, 360.0, 0.0, 1, 1, 0, 1, 0, 1)
		trash = netid
		FreezeEntityPosition(cache.ped, true)
		Wait(10000)
		FreezeEntityPosition(cache.ped, false)

		DetachEntity(NetToObj(trash), 1, 1)
		DeleteEntity(NetToObj(trash))
		trash = nil

		animation = false
		ClearPedTasks(cache.ped)
		
		animation = false
		
		services -= 1

		local data = {
			reason = ESX.PlayerData.metadata.services.reason,
			actuals = ESX.PlayerData.metadata.services.actual,
			total = ESX.PlayerData.metadata.services.total,
			admin = ESX.PlayerData.metadata.services.admin
		}

		local response = lib.callback.await('SaveData', false, services, data)
		
		if services == 0 then
			SendNUIMessage({
				action = 'hide'
			})
	
			working = false
			SetEntityCoords(cache.ped, Config.LeaveCoords)
		end


	end)
end


ESX.SecureNetEvent('leaveJail', function()
	services = 0

	if services == 0 then
		SendNUIMessage({
			action = 'hide'
		})

		working = false
		SetEntityCoords(cache.ped, Config.LeaveCoords)
		
		if response then
			ESX.ShowNotification('You went out, next time behave yourself!')
		end
	end
	
	services = nil

end)


ESX.SecureNetEvent('joinJail', function()
	while not ESX.PlayerData.metadata or not ESX.PlayerData.metadata.services do
		Wait(100)
	end

	SetEntityCoords(cache.ped, Config.JoinCoords)

	SendNUIMessage({
		action = 'show',
		reason = ESX.PlayerData.metadata.services.reason,
		actuals = ESX.PlayerData.metadata.services.actual,
		total = ESX.PlayerData.metadata.services.total,
		admin = ESX.PlayerData.metadata.services.admin
	})

	working = true
	services = ESX.PlayerData.metadata.services.actual
end)





CreateThread(function()
    while not ESX.PlayerLoaded or not ESX.PlayerData.metadata or not ESX.PlayerData.metadata.services do
        Wait(500)
    end
	
	Wait(500)

    SetEntityCoords(cache.ped, Config.JoinCoords)

    SendNUIMessage({
        action = 'show',
        reason = ESX.PlayerData.metadata.services.reason,
        actuals = ESX.PlayerData.metadata.services.actual,
        total = ESX.PlayerData.metadata.services.total,
        admin = ESX.PlayerData.metadata.services.admin
    })

    working = true
    services = ESX.PlayerData.metadata.services.actual
end)

for k, v in pairs(Config.Points) do
	local point = lib.points.new({
		coords = v.coords,  
		distance = 50,
	})

	function point:nearby()
		DrawMarker(21, v.coords.x, v.coords.y, v.coords.z + 0.5 - 0.98, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.5, 0.5, 0.25, 40, 150, 150, 250, false, true, 2, true, nil, nil, false)

		if self.currentDistance < 1 then
			lib.showTextUI('[E] - Sweep')
		else
			lib.hideTextUI()
		end

		if self.currentDistance < 3 and IsControlJustReleased(0, 38) then
			start()

			SendNUIMessage({
				action = 'update',
				actuals = services
			})

			ClearPedTasks(cache.ped)
		end
	end
end

----------
-- ZONA --
----------

local function disable(value)
	NetworkSetFriendlyFireOption(not value)
	SetCanAttackFriendly(cache.ped, not value, not value)
end

lib.zones.sphere({
	coords = Config.SafeZoneCoords,
	radius = Config.Radius,
	debug = Config.Debug,

	onEnter = function(self)
		disable(true)
		dontleave = false
	end,

	onExit = function(self)
		if working then
			dontleave = true

			CreateThread(function()
				while dontleave do
					SetEntityCoords(cache.ped, Config.JoinCoords)
					ESX.ShowNotification('You cant leave the jail!')

					Wait(2000)
					
				end

			end)
		else
			disable(false)
		end
	end
})









