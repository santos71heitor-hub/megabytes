-- Aimbot Web Slinger (com UseItem)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Normalmente o UseItem fica em ReplicatedStorage ou dentro de RemoteEvents
-- Ajuste o caminho se estiver em outro lugar
local UseItem = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UseItem")

-- Função para calcular a distância
local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Encontrar o jogador mais próximo
local function getClosestPlayer()
    local closestPlayer
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = getDistance(LocalPlayer.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position)
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- Função para disparar a teia
local function shootWeb(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    if not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    -- Usa o RemoteEvent UseItem
    UseItem:FireServer("Web Slinger", targetPlayer.Character.HumanoidRootPart.Position)
end

-- Quando clicar, dispara no mais próximo
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local closest = getClosestPlayer()
        if closest then
            shootWeb(closest)
        end
    end
end)
