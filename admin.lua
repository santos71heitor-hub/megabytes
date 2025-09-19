-- Mgby V1
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local commands = {"rocket", "ragdoll", "balloon", "inverse", "nightvision", "jail", "jumpscare"}

-- Pets para ESP
local petsToShow = {
    "Ketchuru and Musturu",
    "Strawberry Elephant",
    "Ketupat Kepat",
    "La Supreme Combinasion",
    "Tralaledon",
    "Celularcini Viciosini",
    "Los Noo My Hotspotsitos",
    "Spaghetti Tualetti",
    "Esok Sekolah",
    "Los Hotspotsitos",
    "Dragon Cannelloni",
    "Chicleteira Bicicleteira",
    "La Extinct Grande",
    "Garama and Madundung",
    "Nuclearo Dinossauro",
    "Graipuss Medussi",
    "Celularcini Viciosini",
    "Los Combinasionas"
}

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui",10)
if not PlayerGui then warn("PlayerGui não carregou a tempo") return end

local NetPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
local ExecuteCommand = NetPackage:WaitForChild("RE/AdminPanelService/ExecuteCommand")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlwaysVisibleAdminPanel"
screenGui.Parent = PlayerGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,450)
frame.Position = UDim2.new(0,1660,0,520)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0) -- painel preto
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,15)
frameCorner.Parent = frame

-- Drag do painel
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

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Mgby V1"
title.TextColor3 = Color3.fromRGB(144,238,144)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- BOTÃO ESP JOGADORES
local espEnabled = false
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.9,0,0,30)
espButton.Position = UDim2.new(0.05,0,0,35)
espButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
espButton.Font = Enum.Font.GothamBold
espButton.TextScaled = true
espButton.Parent = frame

local function updateESPButtonText()
    if espEnabled then
        espButton.Text = "ESP ON"
        espButton.TextColor3 = Color3.fromRGB(0,255,0)
    else
        espButton.Text = "ESP OFF"
        espButton.TextColor3 = Color3.fromRGB(255,0,0)
    end
end
updateESPButtonText()

local playerHighlights = {}
local function updateESPForPlayer(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("ESP_Highlight")
        if espEnabled then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Adornee = player.Character
                highlight.FillColor = Color3.fromRGB(255,140,0)
                highlight.FillTransparency = 0.1 -- 90% opacidade
                highlight.OutlineTransparency = 0.3
                highlight.Parent = player.Character
                playerHighlights[player] = highlight
            end
        else
            if highlight then
                highlight:Destroy()
                playerHighlights[player] = nil
            end
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            if espEnabled then updateESPForPlayer(player) end
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            if espEnabled then updateESPForPlayer(player) end
        end)
    end
end)

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    updateESPButtonText()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateESPForPlayer(player)
        end
    end
end)

-- SCROLLINGFRAME PARA JOGADORES
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

-- BOTÕES DOS JOGADORES
local function createPlayerButton(targetPlayer)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9,0,0,30)
    button.BackgroundColor3 = Color3.fromRGB(50,50,50)
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Text = targetPlayer.Name
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

-- PETS ESP AUTOMÁTICO (nome + valor)
local petsBillboards = {}

local function createPetESP(pet)
    if petsBillboards[pet] then return end
    local valuePerSecond = pet:GetAttribute("ValuePerSecond") or 0
    if valuePerSecond < 10000000 then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP_Billboard"
    billboard.Adornee = pet
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.AlwaysOnTop = true
    billboard.Parent = pet

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextColor3 = Color3.fromRGB(255,255,0) -- amarelo forte
    nameLabel.Text = pet.Name
    nameLabel.Parent = billboard

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1,0,0.5,0)
    valueLabel.Position = UDim2.new(0,0,0.5,0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = Color3.fromRGB(255,255,255) -- branco
    valueLabel.Text = "Value: "..tostring(valuePerSecond).."/s"
    valueLabel.Parent = billboard

    petsBillboards[pet] = billboard
end

-- Loop de verificação contínua para ESP pets
spawn(function()
    while true do
        for _, pet in ipairs(Workspace:GetDescendants()) do
            if table.find(petsToShow, pet.Name) then
                local valuePerSecond = pet:GetAttribute("ValuePerSecond")
                if valuePerSecond and valuePerSecond >= 10000000 then
                    createPetESP(pet)
                end
            end
        end
        task.wait(0.5)
    end
end)

print("Mgby V1 carregado!")
