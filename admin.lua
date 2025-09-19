-- Aimbot automático ao entrar no servidor
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuração
local AIM_RADIUS = 300 -- pixels de distância máxima para selecionar jogador próximo

-- Função para calcular jogador mais próximo do mouse
local function getClosestPlayer(mousePos)
    local closestPlayer = nil
    local shortestDist = AIM_RADIUS

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local charPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(charPos)
            if onScreen then
                local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Função para disparar teia
local function shootWeb(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        -- Substitua abaixo pelo método real do lançador de teia
        -- Ex: LancaTeia(targetPlayer.Character.HumanoidRootPart.Position)
    end
end

-- Função para disparar laser
local function shootLaser(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        -- Substitua abaixo pelo método real do laser
        -- Ex: DisparaLaser(targetPlayer.Character.HumanoidRootPart.Position)
    end
end

-- Ativar aimbot automaticamente
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local targetPlayer = getClosestPlayer(mousePos)
        if targetPlayer then
            shootWeb(targetPlayer)
            shootLaser(targetPlayer)
        end
    end
end)
