-- Autoexec Mgby V6 Ultra
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Lista de comandos
local commands = {"rocket", "ragdoll", "balloon", "inverse", "nightvision", "jail", "jumpscare"}

-- Espera LocalPlayer e PlayerGui
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then warn("PlayerGui não carregou a tempo") return end

-- Espera RemoteEvent
local NetPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
local ExecuteCommand = NetPackage:WaitForChild("RE/AdminPanelService/ExecuteCommand")

-- Cria ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlwaysVisibleAdminPanel"
screenGui.Parent = PlayerGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,400)
frame.Position = UDim2.new(0,1660,0,550)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,15)
frameCorner.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Mgby V6"
title.TextColor3 = Color3.fromRGB(144,238,144)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- ESP jogadores (ativado automaticamente)
local espEnabled = true
local ESP_COLOR = Color3.fromRGB(200,100,0) -- laranja escuro
local ESP_OPACITY = 0.1 -- 90% opacidade (FillTransparency 0.1)
local espObjects = {}

local function createHighlight(char)
    if not espObjects[char] then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = ESP_COLOR
        highlight.FillTransparency = ESP_OPACITY
        highlight.OutlineTransparency = 0.3
        highlight.Parent = char
        espObjects[char] = highlight
    end
end

local function removeHighlight(char)
    if espObjects[char] then
        espObjects[char]:Destroy()
        espObjects[char] = nil
    end
end

-- Função para aplicar ESP rápido e automático
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createHighlight(player.Character)
            player.CharacterAdded:Connect(function(char)
                createHighlight(char)
            end)
        end
    end
end

updateESP() -- ativa ESP automaticamente ao entrar

-- Detecta novos jogadores rapidamente
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            if espEnabled then createHighlight(char) end
        end)
    end
end)

-- ESP Pets genéricos
local petsToHighlight = {"DragonCameloni", "CyberWolf", "MegaPhoenix"}
local petsESPEnabled = true
local petsESPObjects = {}

local function createPetHighlight(pet)
    if not petsESPObjects[pet] then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Pet_Highlight"
        highlight.Adornee = pet
        highlight.FillColor = ESP_COLOR
        highlight.FillTransparency = ESP_OPACITY
        highlight.OutlineTransparency = 0.3
        highlight.Parent = pet
        petsESPObjects[pet] = highlight
    end
end

local function removePetHighlight(pet)
    if petsESPObjects[pet] then
        petsESPObjects[pet]:Destroy()
        petsESPObjects[pet] = nil
    end
end

-- Aplica ESP aos pets automaticamente
for _, pet in ipairs(Workspace:GetDescendants()) do
    if table.find(petsToHighlight, pet.Name) then
        createPetHighlight(pet)
    end
end

Workspace.DescendantAdded:Connect(function(pet)
    if petsESPEnabled and table.find(petsToHighlight, pet.Name) then
        createPetHighlight(pet)
    end
end)

-- ScrollingFrame para botões de players
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,-150)
scrollFrame.Position = UDim2.new(0,0,0,150)
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
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- Botões de players
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

    button.MouseButton1Click:Connect(function()
        for _, cmd in ipairs(commands) do
            task.spawn(function()
                local ok, err = pcall(function()
                    ExecuteCommand:FireServer(targetPlayer, cmd)
                end)
                if not ok then
                    warn("[FireServer] erro com", targetPlayer.Name, cmd, err)
                end
            end)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createPlayerButton(player) end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then createPlayerButton(player) end
end)

print("Mgby V6 Ultra carregado com ESP automático!")
