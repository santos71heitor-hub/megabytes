-- Mgby V10 - Painel Admin + ESP Players + ESP Pets (Generation)
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
    "La Extinta Grande",
    "Garama and Madundung",
    "Nuclearo Dinossauro",
    "Graipuss Medussi",
    "Celularcini Viciosini",
    "Los Combinasionas",
    "La Grande Combinasion"
}

-- LocalPlayer e PlayerGui
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

-- Frame principal
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
title.Text = "nofap hater"
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

-- ============================
-- ESP PLAYERS COM USERNAME
-- ============================
local espEnabled = true -- ativado automaticamente
local playerBillboards = {}

local function createPlayerESP(player)
    if not player.Character then return end
    local char = player.Character
    if playerBillboards[player] then return end

    -- Highlight azul
    if not char:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(192,192,192)
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(0,0,0)
        highlight.OutlineTransparency = 0.2
        highlight.Parent = CoreGui
    end

    -- Nome acima da cabeça
    local head = char:FindFirstChild("Head")
    if head then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,120,0,30)
        bb.Adornee = head
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0,2,0)
        bb.Name = "ESP_Name"
        bb.Parent = CoreGui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0,0,0)
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.Text = player.Name -- username
        label.Parent = bb

        playerBillboards[player] = bb
    end
end

local function removePlayerESP(player)
    if playerBillboards[player] then
        playerBillboards[player]:Destroy()
        playerBillboards[player] = nil
    end
    local char = player.Character
    if char then
        local highlight = char:FindFirstChild("ESP_Highlight")
        if highlight then highlight:Destroy() end
    end
end

local function updateAllPlayersESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createPlayerESP(player)
        end
    end
end

-- Inicializa ESP
updateAllPlayersESP()

-- ============================
-- Painel Admin Dinâmico
-- ============================
local playerButtons = {}

local function addPlayerButton(targetPlayer)
    if playerButtons[targetPlayer] then return end

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

    button.MouseButton1Click:Connect(function()
        task.spawn(function()
            for _, cmd in ipairs(commands) do
                if ExecuteCommand then
                    ExecuteCommand:FireServer(targetPlayer, cmd)
                end
                task.wait(0.2)
            end
        end)
    end)

    playerButtons[targetPlayer] = button
end

local function removePlayerButton(targetPlayer)
    if playerButtons[targetPlayer] then
        playerButtons[targetPlayer]:Destroy()
        playerButtons[targetPlayer] = nil
    end
end

-- Inicializa botão de todos players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        addPlayerButton(player)
    end
end

-- Atualiza automaticamente quando entra ou sai
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        addPlayerButton(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerButton(player)
    removePlayerESP(player)
end)

-- Atualização contínua do ESP
RunService.Heartbeat:Connect(function()
    updateAllPlayersESP()
end)

-- ============================
-- ESP PETS (GENERATION)
-- ============================
local targetNames = {}
for _,petName in ipairs(petsToShow) do
    targetNames[petName] = true
end

local activeBillboards = {}

local function parseNum(t)
    t = t:gsub("[%$,]","")
    local n,s = t:match("([%d%.]+)([KMB]?)")
    n = tonumber(n) or 0
    local mult={K=1e3,M=1e6,B=1e9}
    return n*(mult[s] or 1)
end

local function criarBillboard(basePart,name,val,id)
    if activeBillboards[id] then
        activeBillboards[id]:Destroy()
        activeBillboards[id] = nil
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

    activeBillboards[id] = bb
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

                if targetNames[mobName] then
                    criarBillboard(basePart, mobName, o.Text, basePart:GetDebugId())
                end
            end
        end
    end
end)

-- ============================
-- Sair do servidor ao apertar T
-- ============================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.T then
            LocalPlayer:Kick("$megabytes autokick")
        end
    end
end)
