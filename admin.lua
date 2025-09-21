local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1419319473625894952/sVUGKUCm2i4-bPGW9EzVEY88y2Awo87ZNnHfjqngeKnFjeX5pWiFbyQkMk5SuObx2_HH"

-- Lista de eventos que NÃO serão enviados
local eventBlacklist = {
    "Heartbeat", -- exemplo de evento que quer ignorar
    -- adicione outros eventos que quiser bloquear
}

-- Função para enviar para webhook
local function enviarParaWebhook(eventName, player, detalhes)
    -- verifica se o evento está bloqueado
    for _, bloqueado in pairs(eventBlacklist) do
        if eventName == bloqueado then
            return
        end
    end

    local data = {
        username = "Game Event Logger",
        embeds = {{
            title = "📌 Event Log",
            description = "Evento detectado no jogo",
            color = 16753920, -- laranja
            fields = {
                {name = "Evento", value = eventName, inline = true},
                {name = "Jogador", value = player and player.Name or "N/A", inline = true},
                {name = "Detalhes", value = detalhes or "Nenhum detalhe", inline = false}
            },
            footer = {text = "Sistema de monitoramento"},
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    local jsonData = HttpService:JSONEncode(data)
    HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
end

-- Exemplo de monitoramento: quando um jogador entra
Players.PlayerAdded:Connect(function(player)
    enviarParaWebhook("PlayerAdded", player, "Jogador entrou no jogo")
    
    -- Exemplo: monitorar quando o personagem é carregado
    player.CharacterAdded:Connect(function(char)
        enviarParaWebhook("CharacterAdded", player, "Personagem do jogador foi carregado")
    end)
end)

-- Exemplo: monitorar remoção de pets (se existir)
game:GetService("Workspace").ChildRemoved:Connect(function(child)
    local player = Players:GetPlayerFromCharacter(child)
    enviarParaWebhook("ChildRemoved", player, "Objeto removido: "..child.Name)
end)

-- Aqui você pode adicionar qualquer outro evento que quiser logar
-- Exemplo: Workspace.ChildAdded, Touched, RemoteEvents, etc.
