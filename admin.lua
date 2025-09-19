-- Aimbot Web Slinger
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = game:GetService("Workspace")

-- Função para calcular a distância entre dois vetores
local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Função para encontrar o jogador mais próximo
local function getClosestPlayer()
    local closestPlayer = nil
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

    local tool = LocalPlayer.Backpack:FindFirstChild("Web Slinger") or LocalPlayer.Character:FindFirstChild("Web Slinger")
    if tool then
        -- Aqui você precisa disparar o RemoteEvent ou função do seu jogo
        -- Exemplo genérico:
        if tool:FindFirstChild("ShootEvent") then
            tool.ShootEvent:FireServer(targetPlayer.Character.HumanoidRootPart.Position)
        else
            -- Caso o disparo seja feito com clique, simular clique no mouse
            tool:Activate()
        end
    end
end

-- Detecta clique do mouse e dispara no jogador mais próximo
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local closest = getClosestPlayer()
        if closest then
            shootWeb(closest)
        end
    end
end)
