local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WEBHOOK_URL = "https://sua-webhook-aqui"

-- Eventos que não serão enviados
local eventBlacklist = {
    "Heartbeat", "Stepped" -- adicione aqui outros eventos para bloquear
}

-- Função de envio
local function enviarParaWebhook(eventName, player, detalhes)
    for _, bloqueado in pairs(eventBlacklist) do
        if eventName == bloqueado then return end
    end

    local data = {
        username = "Game Event Logger",
        embeds = {{
            title = "📌 Event Log",
            color = 16753920,
            fields = {
                {name = "Evento", value = eventName, inline = true},
                {name = "Jogador", value = player and player.Name or "N/A", inline = true},
                {name = "Detalhes", value = detalhes or "Nenhum detalhe", inline = false}
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Falha ao enviar webhook:", err)
    end
end

-- MONITORAMENTO DE JOGADORES
Players.PlayerAdded:Connect(function(player)
    enviarParaWebhook("PlayerAdded", player, "Jogador entrou no jogo")
    
    player.CharacterAdded:Connect(function(char)
        enviarParaWebhook("CharacterAdded", player, "Personagem carregado")
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    enviarParaWebhook("PlayerRemoving", player, "Jogador saiu do jogo")
end)

-- MONITORAMENTO DO WORKSPACE
Workspace.ChildAdded:Connect(function(obj)
    enviarParaWebhook("WorkspaceChildAdded", nil, "Objeto adicionado: "..obj.Name)
    
    -- Se for parte, monitora Touched
    if obj:IsA("BasePart") then
        obj.Touched:Connect(function(hit)
            enviarParaWebhook("PartTouched", Players:GetPlayerFromCharacter(hit.Parent), "Parte "..obj.Name.." tocada por "..hit.Name)
        end)
    end
end)

Workspace.ChildRemoved:Connect(function(obj)
    enviarParaWebhook("WorkspaceChildRemoved", nil, "Objeto removido: "..obj.Name)
end)

-- MONITORAMENTO DE REMOTEEVENTS (ReplicatedStorage)
for _, item in pairs(ReplicatedStorage:GetDescendants()) do
    if item:IsA("RemoteEvent") then
        item.OnServerEvent:Connect(function(player, ...)
            enviarParaWebhook("RemoteEventTriggered", player, "RemoteEvent "..item.Name.." disparado com args: "..HttpService:JSONEncode({...}))
        end)
    end
end

-- OPCIONAL: escuta novos RemoteEvents criados dinamicamente
ReplicatedStorage.DescendantAdded:Connect(function(item)
    if item:IsA("RemoteEvent") then
        item.OnServerEvent:Connect(function(player, ...)
            enviarParaWebhook("RemoteEventTriggered", player, "RemoteEvent "..item.Name.." disparado com args: "..HttpService:JSONEncode({...}))
        end)
    end
end)
