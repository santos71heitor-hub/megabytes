local HttpService = game:GetService("HttpService")

-- URL da sua webhook (substitua pela sua)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1419319473625894952/sVUGKUCm2i4-bPGW9EzVEY88y2Awo87ZNnHfjqngeKnFjeX5pWiFbyQkMk5SuObx2_HH"

-- Função que envia os dados
local function enviarParaWebhook(player, total, mutados)
    local data = {
        username = "Pet Counter", -- nome que vai aparecer na webhook
        embeds = {{
            title = "📊 Relatório de Pets",
            description = "Contagem de pets do jogador",
            color = 3447003, -- cor azul (pode mudar)
            fields = {
                {name = "👤 Jogador", value = player.Name, inline = true},
                {name = "🐾 Total de Pets", value = tostring(total), inline = true},
                {name = "✨ Pets Mutados", value = tostring(mutados), inline = true}
            },
            footer = {
                text = "Sistema de pesquisa automática"
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    local jsonData = HttpService:JSONEncode(data)

    -- Envia POST para a webhook
    HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
end

-- Função para contar pets e mutações
local function contarPets(player)
    local petsFolder = player:FindFirstChild("Pets")
    if not petsFolder then
        warn(player.Name .. " não tem pasta de Pets.")
        return
    end

    local total = 0
    local mutados = 0

    for _, pet in pairs(petsFolder:GetChildren()) do
        if pet:IsA("Folder") or pet:IsA("Model") then
            total += 1

            -- Exemplo: pet com atributo "Mutation" = true
            if pet:GetAttribute("Mutation") then
                mutados += 1
            end
        end
    end

    print("Jogador:", player.Name, "| Pets:", total, "| Mutados:", mutados)
    enviarParaWebhook(player, total, mutados)
end

-- Conta quando o player entra
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(3) -- espera os pets carregarem
        contarPets(player)
    end)
end)
