RegisterNetEvent('SC:PlayerLoaded', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer.getMeta('services') then
        xPlayer.setMeta('services', {actual = 0, total = 0, admin = nil, reason = nil})
    else
        return
    end
end)

lib.addCommand('jail', {
    help = 'Putting the selected ID player in jail',
    params = {
        {
            name = 'ID',
            type = 'playerId',
            help = 'Player ID',
        },
        {
            name = 'Servicios',
            type = 'number',
            help = 'Number of services',
            optional = false,
        },
        {
            name = 'reason',
            type = 'longString',
            help = "Jail reason",
            optional = false,
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local xPlayer = ESX.GetPlayerFromId(source)
    local adminName = xPlayer.getName()
    local targetPlayer = ESX.GetPlayerFromId(args.ID)
    local identifier = targetPlayer.getIdentifier()
    local name = targetPlayer.getName()
    local reasono = args.reason
    local actions_count = args.Servicios
    
    if targetPlayer.getMeta('services') and targetPlayer.getMeta('services', total) then
        return TriggerClientEvent('esx:showNotification', source, name.. ' Ya esta en servicios comunitarios.')
    end

    ESX.TriggerClientEvent('joinJail', args.ID)
    ESX.TriggerClientEvent('esx:showNotification', -1, name.. ' Ha entrado a servicios comunitarios por:' ..reasono)
    targetPlayer.setMeta('services', {actual = actions_count, total = actions_count, admin = adminName, reason = reasono})
    
end)


lib.addCommand('unjail', {
    help = 'Remove the services to the selected player ID',
    params = {
        {
            name = 'ID',
            type = 'playerId',
            help = 'Player ID',
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local xPlayer = ESX.GetPlayerFromId(args.ID)
    local targetPlayer = ESX.GetPlayerFromId(args.ID)
    local name = xPlayer.getName()
    local identifier = targetPlayer.getIdentifier()

    ESX.TriggerClientEvent('leaveJail', args.ID)
    TriggerClientEvent('esx:showNotification', -1, name.. ' Ha salido de los servicios comunitarios.')

    targetPlayer.clearMeta('services')

end)

lib.callback.register('SaveData', function(source, services, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()

    if services == 0 then
        xPlayer.setMeta('services', nil)
    end

    xPlayer.setMeta('services', {actual = services, total = data.total, admin = data.admin, reason = data.reason})
    


    return true
end)
