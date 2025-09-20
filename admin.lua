-- Mgby V13 - Painel Admin + ESP Players + ESP Pets (Generation)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

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
    "La Grande Combinasion",
    "Los Bros",
    "Las Sis"
}

-- Espera LocalPlayer e PlayerGui
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui",10)
if not PlayerGui then warn("PlayerGui não carregou a tempo") return end

-- RemoteEvent
local NetPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
local ExecuteCommand = NetPackage:WaitForChild("RE/AdminPanelService/ExecuteCommand")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlwaysVisibleAdminPanel"
screenGui.Parent = PlayerGui

-- Frame principal centralizado
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,450)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.new(0.5,0,0.5,0)
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
title.Text = "Mgby V13"
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

-- ScrollingFrame para players
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

-- BOTÃO ESP JOGADORES
local espEnabled = true -- ativado automaticamente
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.9,0,0,30)
espButton.Position = UDim2.new(0.05,0,0,35)
espButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
espButton.TextColor3 = Color3.fromRGB(0,255,0)
espButton.Text = "ESP ON"
espButton.Font = Enum.Font.GothamBold
espButton.TextScaled = true
espButton.Parent = frame

local function createHighlight(char, color)
    if char:FindFirstChild("ESP_Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = color
    highlight.FillTransparency = 0.1
    highlight.OutlineTransparency = 0.3
    highlight.Parent = char
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
            if espEnabled then createHighlight(player.Character, Color3.fromRGB(0,0,255)) else removeHighlight(player.Character) end
            player.CharacterAdded:Connect(function(char)
                if espEnabled then createHighlight(char, Color3.fromRGB(0,0,255)) end
            end)
        end
    end
end
espButton.MouseButton1Click:Connect(toggleESP)

-- Criação de botões para players
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

-- =================================================
-- ESP PETS (GENERATION) INTEGRADO COM A LISTA V4
-- =================================================
local petTargetNames = {}
for _,petName in ipairs(petsToShow) do
    petTargetNames[petName] = true
end

local petBillboards = {}

local function createPetBillboard(basePart,name,val,id)
    if petBillboards[id] then
        petBillboards[id]:Destroy()
        petBillboards[id] = nil
    end

    -- Highlight ciano
    if not basePart:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = basePart
        highlight.FillColor = Color3.fromRGB(0,255,255)
        highlight.FillTransparency = 0.1
        highlight.OutlineTransparency = 0.3
        highlight.Parent = basePart
    end

    local bb=Instance.new("BillboardGui",CoreGui)
    bb.Size=UDim2.new(0,200,0,50)
    bb.Adornee=basePart
    bb.AlwaysOnTop=true
    bb.StudsOffset=Vector3.new
    bb.StudsOffset=Vector3.new(0,4,0)

    local l1=Instance.new("TextLabel",bb)
    l1.Size=UDim2.new(1,0,0.5,0)
    l1.BackgroundTransparency=1
    l1.TextColor3=Color3.fromRGB(255,255,0)
    l1.TextStrokeTransparency=0
    l1.TextStrokeColor3=Color3.new(0,0,0)
    l1.Font=Enum.Font.GothamBold
    l1.TextScaled = true
    l1.Text = name or "N/A"

    local l2=Instance.new("TextLabel",bb)
    l2.Size = UDim2.new(1,0,0.5,0)
    l2.Position = UDim2.new(0,0,0.5,0)
    l2.BackgroundTransparency = 1
    l2.TextColor3 = Color3.fromRGB(255,255,255)
    l2.TextStrokeTransparency = 0
    l2.TextStrokeColor3 = Color3.new(0,0,0)
    l2.Font = Enum.Font.GothamBold
    l2.TextScaled = true
    l2.Text = val or "0/s"

    petBillboards[id] = bb
end

local function parseNum(t)
    t = t:gsub("[%$,]","")
    local n,s = t:match("([%d%.]+)([KMB]?)")
    n = tonumber(n) or 0
    local mult={K=1e3,M=1e6,B=1e9}
    return n*(mult[s] or 1)
end

RunService.Heartbeat:Connect(function()
    for _,o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("TextLabel") and o.Name == "Generation" and not o.Text:lower():find("fusing") then
            local parent = o.Parent
            local basePart
            while parent and parent ~= Workspace do
                if parent:IsA("Model") and parent:FindFirstChild("Base") then
                    basePart = parent.Base break
                end
                parent = parent.Parent
            end

            if basePart then
                local displayName = o.Parent:FindFirstChild("DisplayName")
                local mobName = displayName and displayName.Text or "N/A"

                if petTargetNames[mobName] then
                    createPetBillboard(basePart, mobName, o.Text, basePart:GetDebugId())
                end
            end
        end
    end
end)
