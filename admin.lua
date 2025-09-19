local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Lista de comandos
local commands = {"rocket", "ragdoll", "balloon", "inverse", "nightvision", "jail", "jumpscare"}

-- Espera LocalPlayer e PlayerGui
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait() end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlwaysVisibleAdminPanel"
screenGui.Parent = PlayerGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,380)
frame.Position = UDim2.new(0,1660,0,580)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Borda arredondada no painel
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,15)
frameCorner.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "GlitchC V4"
title.TextColor3 = Color3.fromRGB(144,238,144)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Botão para ativar/desativar ESP
local espEnabled = false
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.9,0,0,30)
espButton.Position = UDim2.new(0.05,0,0,35)
espButton.BackgroundColor3 = Color3.fromRGB(100,0,100)
espButton.TextColor3 = Color3.fromRGB(255,255,255)
espButton.Text = "ESP: OFF"
espButton.Font = Enum.Font.Gotham
espButton.TextScaled = true
espButton.Parent = frame

local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Highlight"
                    highlight.Adornee = player.Character
                    highlight.FillColor = Color3.fromRGB(255,200,100)
                    highlight.FillTransparency = 0.2 -- mais forte que antes
                    highlight.OutlineTransparency = 0.3 -- contorno leve para destacar
                    highlight.Parent = player.Character
                end
            else
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

espButton.MouseButton1Click:Connect(toggleESP)

-- ScrollingFrame para botões de players
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,-70)
scrollFrame.Position = UDim2.new(0,0,0,70)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scrollFrame

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

-- Tornar frame arrastável
do
    local dragging, dragInput, mousePos, framePos
    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Função para criar botão de player
local function createPlayerButton(targetPlayer)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9,0,0,30)
    button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.Text = targetPlayer.Name
    button.Font = Enum.Font.Gotham
    button.TextScaled = true
    button.Parent = scrollFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = button

    local capturedPlayer = targetPlayer

    button.MouseButton1Click:Connect(function()
        for _, cmd in ipairs(commands) do
            task.spawn(function()
                local event
                if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
                    event = ReplicatedStorage.Packages.Net:FindFirstChild("RE/AdminPanelService/ExecuteCommand")
                end
                if event then
                    local ok, err = pcall(function()
                        event:FireServer(capturedPlayer, cmd)
                    end)
                    if not ok then
                        warn("[FireServer] erro com", capturedPlayer.Name, cmd, err)
                    end
                else
                    warn("RemoteEvent ExecuteCommand não encontrado")
                end
            end)
        end
    end)
end

-- Criar botões para todos os players online
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createPlayerButton(player)
    end
end

-- Atualizar quando alguém entrar
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createPlayerButton(player)
    end
end)
