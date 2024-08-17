local discordBotToken = Config.BotToken
local guildId = Config.GuildId

local function getDiscordNickname(discordId, callback)
    local url = string.format("https://discord.com/api/v10/guilds/%s/members/%s", guildId, discordId)
    local headers = {
        ["Authorization"] = "Bot " .. discordBotToken
    }

    PerformHttpRequest(url, function (errorCode, resultData, resultHeaders)
        if errorCode == 200 then
            local data = json.decode(resultData)
            callback(data.nick or data.user.username)
        else
            callback(nil)
        end
    end, "GET", "", headers)
end

function GetPlayerDiscordId(playerId, callback)
    local identifiers = GetPlayerIdentifiers(playerId)
    local discordId = nil

    for _, id in ipairs(identifiers) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end

    if discordId then
        callback(discordId)
    else
        callback(nil)
    end
end

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    local playerId = source
    print("Player connecting: " .. name .. " (ID: " .. playerId .. ")")

    deferrals.defer()

    GetPlayerDiscordId(playerId, function(discordId)
        if not discordId then
            print("Discord ID not found for player ID: " .. playerId)
            deferrals.done("You need to link your Discord account to your FiveM account.")
            return
        end

        print("Fetching Discord nickname for ID: " .. discordId)
        getDiscordNickname(discordId, function(nickname)
            if nickname then
                print("Fetched Discord nickname: " .. nickname)
                if nickname == name then
                    print("Nickname matches FiveM username. Allowing connection.")
                    deferrals.done()
                    sendToDiscord()
                else
                    print("Nickname does not match FiveM username. Denying connection.")
                    deferrals.done("Your Discord nickname does not match your FiveM username.")
                end
            else
                print("Failed to retrieve Discord nickname for ID: " .. discordId)
                deferrals.done("Failed to retrieve your Discord nickname.")
            end
        end)
    end)
end)
