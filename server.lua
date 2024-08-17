local discordBotToken = Config.BotToken
local guildId = Config.GuildId

-- Function to get the Discord member's nickname
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

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    local playerId = source
    local src = source
    local license
    local discordId

    
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if string.match(identifier, "license:") then
            license = identifier
        elseif string.match(identifier, "discord:") then
            discordId = string.gsub(identifier, "discord:", "")
        end
    end

    if not discordId then
        deferrals.done("You need to link your Discord account to your FiveM account.")
        return
    end
    
    getDiscordNickname(discordId, function(nickname)
        if nickname then
            if nickname == name then
                deferrals.done() -- Allow player to connect
            else
                deferrals.done("Your Discord nickname does not match your FiveM username.")
            end
        else
            deferrals.done("Failed to retrieve your Discord nickname.")
        end
    end)
end)