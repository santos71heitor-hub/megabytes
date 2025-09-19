-- Mgby V8 - Painel Admin com ESP Jogadores e ESP Pets com Highlight Ciano
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Lista de comandos
local commands = {"rocket", "ragdoll", "balloon", "inverse", "nightvision", "jail", "jumpscare"}

-- Lista de pets para ESP
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
    "Los Combinasionas",
    "Los Bros",
    "La Grande Combinasion"
}

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

-- Frame principal centralizado
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 450)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Mgby V8"
title.TextColor3 = Color3.fromRGB(144,238,144)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

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

-- ScrollingFrame para botões de players
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -150)
scrollFrame.Position = UDim2.new(0, 0, 0, 150)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
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

-- BOTÃO ESP JOGADORES
local espEnabled = false
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.9,0,0,30)
espButton.Position = UDim2.new(0.05,0,0,35)
espButton.BackgroundColor3 = Color3.fromRGB(50,50,50) -- cinza escuro
espButton.TextColor3 = Color3.fromRGB(255,0,0) -- vermelho OFF
espButton.Text = "ESP OFF"
espButton.Font = Enum.Font.GothamBold
espButton.TextScaled = true
espButton.Parent = frame

local function createHighlight(char)
    local highlight = char:FindFirstChild("ESP_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255,165,0)
        highlight.FillTransparency = 0.1
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
    espButton.Text = espEnabled and "ESP ON" or "ESP OFF"
    espButton.TextColor3 = espEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if espEnabled then createHighlight(player.Character) else removeHighlight(player.Character) end
            player.CharacterAdded:Connect(function(char)
                if espEnabled then createHighlight(char) end
            end)
        end
    end
end
espButton.MouseButton1Click:Connect(toggleESP)

-- CRIAR BOTÕES PARA TODOS OS PLAYERS
local function createPlayerButton(targetPlayer)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9,0,0,30)
    button.BackgroundColor3 = Color3.fromRGB(50,50,50)
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.Text = targetPlayer.Name
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Parent = scrollFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = button

    local capturedPlayer = targetPlayer

    button.MouseButton1Click:Connect(function()
        task.spawn(function()
            for _, cmd in ipairs(commands) do
                if ExecuteCommand then
                    ExecuteCommand:FireServer(capturedPlayer, cmd)
                end
                task.wait(0.2)
            end
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createPlayerButton(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createPlayerButton(player)
    end
end)

-- ESP PETS AUTOMÁTICO (nome + geração + highlight ciano)
local activeBillboards = {}

local function parseNum(t)
    t = t:gsub("[%$,]","")
    local n,s = t:match("([%d%.]+)([KMB]?)")
    n = tonumber(n) or 0
    local mult={K=1e3,M=1e6,B=1e9}
    return n*(mult[s] or 1)
end

local function createPetESP(pet)
    local id = pet:GetDebugId()
    if activeBillboards[id] then
        activeBillboards[id]:Destroy()
        activeBillboards[id] = nil
    end

    -- Highlight ciano
    if not pet:FindFirstChild("Pet_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Pet_Highlight"
        highlight.Adornee = pet
        highlight.FillColor = Color3.fromRGB(0,255,255)
        highlight.FillTransparency = 0.1
        highlight.OutlineTransparency = 0.3
        highlight.Parent = pet
    end

    -- Billboard
    local bb = Instance.new("BillboardGui",CoreGui)
    bb.Size = UDim2.new(0,200,0,50)
    bb.Adornee = pet
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0,4,0)

    local nameLabel = Instance.new("TextLabel",bb)
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255,255,0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Text = pet.Name

    local genLabel = pet:FindFirstChild("Generation")
    local val = genLabel and genLabel.Text or "0/s"

    local valueLabel = Instance.new("TextLabel",bb)
    valueLabel.Size = UDim2.new(1,0,0.5,0)
    valueLabel.Position = UDim2.new(0,0,0.5,0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(255,255,255)
    valueLabel.TextStrokeTransparency = 0
    valueLabel.TextStrokeColor3 = Color3.new(0,0,0)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextScaled = true
    valueLabel.Text = val

    activeBillboards[id] = bb
end

-- Varredura periódica
RunService.Heartbeat:Connect(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and table.find(petsToShow,obj.Name) then
            createPetESP(obj)
        end
    end
end)
