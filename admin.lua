-- Autoexec Mgby V6
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Lista de comandos
local commands = {"rocket", "ragdoll", "balloon", "inverse", "nightvision", "jail", "jumpscare"}

-- Espera LocalPlayer e PlayerGui
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then
    warn("PlayerGui não carregou a tempo")
    return
end

-- Espera RemoteEvent
local NetPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
local ExecuteCommand = NetPackage:WaitForChild("RE/AdminPanelService/ExecuteCommand")

-- Cria ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlwaysVisibleAdminPanel"
screenGui.Parent = PlayerGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,420)
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

-- BOTÕES DE ESP
-- ESP jogadores
local espEnabled = false
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.9,0,0,30)
espButton.Position = UDim2.new(0.05,0,0,35)
espButton.BackgroundColor3 = Color3.fromRGB(100,0,100)
espButton.TextColor3 = Color3.fromRGB(255,255,255)
espButton.Text = "ESP Jogadores: OFF"
espButton.Font = Enum.Font.Gotham
espButton.TextScaled = true
espButton.Parent = frame

local function createHighlight(char)
    local highlight = char:FindFirstChild("ESP_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255,200,100)
        highlight.FillTransparency = 0.2
        highlight.OutlineTransparency = 0.3
        highlight.Parent = char
    end
end

local function removeHighlight(char)
    local highlight = char:FindFirstChild("ESP_Highlight")
    if highlight then highlight:Destroy() end
end

local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP Jogadores: ON" or "ESP Jogadores: OFF"

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                if espEnabled then
                    createHighlight(player.Character)
                else
                    removeHighlight(player.Character)
                end
            end
            player.CharacterAdded:Connect(function(char)
                if espEnabled then createHighlight(char) end
            end)
        end
    end
end

espButton.MouseButton1Click:Connect(toggleESP)

-- ESP Pets genéricos
local petsToHighlight = {"DragonCameloni", "CyberWolf", "MegaPhoenix"}
local petsESPEnabled = false
local petsButton = Instance.new("TextButton")
petsButton.Size = UDim2.new(0.9,0,0,30)
petsButton.Position = UDim2.new(0.05,0,0,75)
petsButton.BackgroundColor3 = Color3.fromRGB(100,0,100)
petsButton.TextColor3 = Color3.fromRGB(255,255,255)
petsButton.Text = "Pets ESP: OFF"
petsButton.Font = Enum.Font.Gotham
petsButton.TextScaled = true
petsButton.Parent = frame

local function createPetHighlight(pet)
    local highlight = pet:FindFirstChild("Pet_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "Pet_Highlight"
        highlight.Adornee = pet
        highlight.FillColor = Color3.fromRGB(0,255,255)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0.5
        highlight.Parent = pet
    end
end

local function removePetHighlight(pet)
    local highlight = pet:FindFirstChild("Pet_Highlight")
    if highlight then highlight:Destroy() end
end

local function togglePetsESP()
    petsESPEnabled = not petsESPEnabled
    petsButton.Text = petsESPEnabled and "Pets ESP: ON" or "Pets ESP: OFF"

    for _, pet in ipairs(Workspace:GetDescendants()) do
        if table.find(petsToHighlight, pet.Name) then
            if petsESPEnabled then createPetHighlight(pet) else removePetHighlight(pet) end
        end
    end

    Workspace.DescendantAdded:Connect(function(pet)
        if petsESPEnabled and table.find(petsToHighlight, pet.Name) then
            createPetHighlight(pet)
        end
    end)
end

petsButton.MouseButton1Click:Connect(togglePetsESP)

-- ESP para Los Combinasionas com cores de raridade
local losCombESPEnabled = false
local losCombButton = Instance.new("TextButton")
losCombButton.Size = UDim2.new(0.9,0,0,30)
losCombButton.Position = UDim2.new(0.05,0,0,115)
losCombButton.BackgroundColor3 = Color3.fromRGB(100,0,100)
losCombButton.TextColor3 = Color3.fromRGB(255,255,255)
losCombButton.Text = "Los Comb ESP: OFF"
losCombButton.Font = Enum.Font.Gotham
losCombButton.TextScaled = true
losCombButton.Parent = frame

local function createLosCombESP(pet)
    local highlight = pet:FindFirstChild("LosComb_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "LosComb_Highlight"
        highlight.Adornee = pet
        highlight.FillColor = Color3.fromRGB(255,165,0)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0.5
        highlight.Parent = pet
    end

    local existingBillboard = pet:FindFirstChild("LosComb_Billboard")
    if existingBillboard then existingBillboard:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LosComb_Billboard"
    billboard.Adornee = pet
    billboard.Size = UDim2.new(0,150,0,50)
    billboard.AlwaysOnTop = true
    billboard.Parent = pet

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = "Los Combinasionas"
    label.TextColor3 = Color3.fromRGB(255,255,0)
    label.Parent = billboard

    local rarity = pet:GetAttribute("Rarity")
    if rarity then
        if rarity == "Gold" then
            label.TextColor3 = Color3.fromRGB(255,255,0)
        elseif rarity == "Diamond" then
            label.TextColor3 = Color3.fromRGB(0,191,255)
        elseif rarity == "Rainbow" then
            label.TextColor3 = Color3.fromRGB(255,105,180)
        end
    end
end

local function removeLosCombESP(pet)
    local h = pet:FindFirstChild("LosComb_Highlight")
    if h then h:Destroy() end
    local b = pet:FindFirstChild("LosComb_Billboard")
    if b then b:Destroy() end
end

losCombButton.MouseButton1Click:Connect(function()
    losCombESPEnabled = not losCombESPEnabled
    losCombButton.Text = losCombESPEnabled and "Los Comb ESP: ON" or "Los Comb ESP: OFF"

    for _, pet in ipairs(Workspace:GetDescendants()) do
        if pet.Name == "Los Combinasionas" then
            if losCombESPEnabled then createLosCombESP(pet) else removeLosCombESP(pet) end
        end
    end

    Workspace.DescendantAdded:Connect(function(pet)
        if losCombESPEnabled and pet.Name == "Los Combinasionas" then
            createLosCombESP(pet)
        end
    end)
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

print("Mgby V6 carregado com sucesso!")
