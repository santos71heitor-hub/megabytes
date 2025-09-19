-- Aimbot simplificado para teia e laser
----------------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Função para calcular distância entre dois vetores
local function distance3D(a, b)
    return (a - b).Magnitude
end

-- Função para encontrar o jogador mais próximo ao mouse
local function getClosestPlayer(mousePos, maxDistance)
    local closestPlayer = nil
    local shortestDist = maxDistance or math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local charPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(charPos)
            if onScreen then
                local mouseVec = Vector2.new(mousePos.X, mousePos.Y)
                local playerVec = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (mouseVec - playerVec).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Função para ativar teia no jogador
local function shootWeb(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    -- Substitua abaixo pela função real do lançador de teia
    -- Exemplo genérico:
    -- LancaTeia(targetPlayer.Character.HumanoidRootPart.Position)
end

-- Função para ativar laser no jogador
local function shootLaser(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    -- Substitua abaixo pela função real do laser
    -- Exemplo genérico:
    -- DisparaLaser(targetPlayer.Character.HumanoidRootPart.Position)
end

-- Evento de clique do mouse
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local targetPlayer = getClosestPlayer(mousePos, 300) -- raio de 300 pixels do clique
        if targetPlayer then
            shootWeb(targetPlayer)
            shootLaser(targetPlayer)
        end
    end
end)
