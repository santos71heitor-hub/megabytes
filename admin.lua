-- Mgby V10 - Painel Admin + ESP Players (Username legível) + ESP Pets (Generation)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Lista de comandos
local commands = {"rocket", "ragdoll", "balloon", "inverse", "nightvision", "jail", "jumpscare"}

-- Lista de pets para ESP (mantida)
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
    "Garama and Madundang",
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

-- RemoteEvent (mantido)
local NetPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
local ExecuteCommand = NetPackage:WaitForChild("RE/AdminPanelService/ExecuteCommand")

-- ScreenGui (painel)
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
title.Text = "Mgby V10"
title.TextColor3 = Color3.fromRGB(144,238,144)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Tornar frame arrastável (mesma lógica anterior)
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
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

-- ==========================
-- ESP PLAYERS (V10 - Username legível)
-- ==========================
local espEnabled = true -- ativado por padrão
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.9,0,0,30)
espButton.Position = UDim2.new(0.05,0,0,35)
espButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
espButton.TextColor3 = Color3.fromRGB(0,255,0)
espButton.Text = "ESP ON"
espButton.Font = Enum.Font.GothamBold
espButton.TextScaled = true
espButton.Parent = frame

-- parent seguro para Billboards (compatibilidade)
local guiParent = CoreGui:FindFirstChild("RobloxGui") or CoreGui

-- mapa de ESP por player
local playerESP = {}

-- função utilitária: obtém a "main part" do character ou cria fallback invisível
local function getMainPart(character)
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    local upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if upper then return upper end
    -- fallback: cria uma part invisível e ancorada no model (para casos extremos de scripts que removem partes)
    local fb = character:FindFirstChild("ESP_Fallback")
    if fb and fb:IsA("BasePart") then return fb end
    fb = Instance.new("Part")
    fb.Name = "ESP_Fallback"
    fb.Size = Vector3.new(1,1,1)
    fb.Transparency = 1
    fb.Anchored = true
    fb.CanCollide = false
    fb.Parent = character
    return fb
end

-- cria/atualiza billboard que mostra o username
local function createOrUpdatePlayerBillboard(player)
    if not player or not player.Character then return end
    local char = player.Character
    local mainPart = getMainPart(char)
    if not mainPart then return end

    -- se já existe, só atualiza o adornee e o texto
    if playerESP[player] and playerESP[player].Billboard and playerESP[player].Billboard.Parent then
        local bb = playerESP[player].Billboard
        bb.Adornee = mainPart
        local label = bb:FindFirstChild("UsernameLabel", true) or bb:FindFirstChildWhichIsA("TextLabel")
        if label then
            label.Text = player.Name -- username fixo
        end
        return
    end

    -- cria novo billboard
    local bb = Instance.new("BillboardGui")
    bb.Name = "Mgby_PlayerESP"
    bb.Size = UDim2.new(0,160,0,28)
    bb.Adornee = mainPart
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0,3,0)
    bb.Parent = guiParent

    local label = Instance.new("TextLabel", bb)
    label.Name = "UsernameLabel"
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = player.Name -- mostra o username (login)
    label.Font = Enum.Font.GothamBlack or Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255,255,255) -- branco para máxima legibilidade
    label.TextStrokeTransparency = 0 -- contorno preto ativo
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextWrapped = false

    -- guarda referência
    playerESP[player] = {
        Billboard = bb,
        Label = label,
        MainPart = mainPart
    }

    -- se a mainPart for removida do mundo, tentamos realocar o adornee
    if mainPart and mainPart:IsA("Instance") then
        mainPart.AncestryChanged:Connect(function(_, parent)
            if not parent and player.Character then
                local newMain = getMainPart(player.Character)
                if newMain and playerESP[player] and playerESP[player].Billboard then
                    playerESP[player].Billboard.Adornee = newMain
                    playerESP[player].MainPart = newMain
                end
            end
        end)
    end
end

local function removePlayerBillboard(player)
    if playerESP[player] then
        if playerESP[player].Billboard and playerESP[player].Billboard.Parent then
            playerESP[player].Billboard:Destroy()
        end
        playerESP[player] = nil
    end
end

-- toggle do botão
local function toggleESPButton()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP ON" or "ESP OFF"
    espButton.TextColor3 = espEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

    if espEnabled then
        -- criar para todos que já tem character
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                createOrUpdatePlayerBillboard(plr)
            end
        end
    else
        -- remover todos
        for plr,_ in pairs(playerESP) do
            removePlayerBillboard(plr)
        end
    end
end
espButton.MouseButton1Click:Connect(toggleESPButton)

-- aplica a players existentes
for _,plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        if plr.Character then
            if espEnabled then createOrUpdatePlayerBillboard(plr) end
        end
        plr.CharacterAdded:Connect(function(char)
            if espEnabled then
                -- garante que o humanoid/carregamento ocorra
                char:WaitForChild("Humanoid", 10)
                createOrUpdatePlayerBillboard(plr)
            end
        end)
    end
end

-- quando um novo player entrar
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            if espEnabled then
                char:WaitForChild("Humanoid", 10)
                createOrUpdatePlayerBillboard(plr)
            end
        end)
    end
end)

-- remover quando sair
Players.PlayerRemoving:Connect(function(plr)
    removePlayerBillboard(plr)
end)

-- =========================
-- Botões players (admin cmds)
-- =========================
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

for _,plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then createPlayerButton(plr) end
end
Players.PlayerAdded:Connect(function(plr) if plr~=LocalPlayer then createPlayerButton(plr) end end)

-- =========================
-- ESP PETS (GENERATION) - mantido como antes
-- =========================
local targetNames = {}
for _,n in ipairs(petsToShow) do targetNames[n] = true end
local activeBillboards = {}

local function criarBillboard(basePart,name,val,id)
    if activeBillboards[id] then
        activeBillboards[id]:Destroy()
        activeBillboards[id] = nil
    end

    -- Highlight ciano no mob
    if not basePart:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = basePart
        highlight.FillColor = Color3.fromRGB(0,255,255)
        highlight.FillTransparency = 0.1
        highlight.OutlineTransparency = 0.3
        highlight.Parent = basePart
    end

    local parentGui = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    local bb = Instance.new("BillboardGui", parentGui)
    bb.Size = UDim2.new(0,200,0,50)
    bb.Adornee = basePart
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0,4,0)

    local l1 = Instance.new("TextLabel", bb)
    l1.Size = UDim2.new(1,0,0.5,0)
    l1.BackgroundTransparency = 1
    l1.TextColor3 = Color3.fromRGB(255,255,0)
    l1.TextStrokeTransparency = 0
    l1.TextStrokeColor3 = Color3.new(0,0,0)
    l1.Font = Enum.Font.GothamBold
    l1.TextScaled = true
    l1.Text = name

    local l2 = Instance.new("TextLabel", bb)
    l2.Size = UDim2.new(1,0,0.5,0)
    l2.Position = UDim2.new(0,0,0.5,0)
    l2.BackgroundTransparency = 1
    l2.TextColor3 = Color3.fromRGB(255,255,255)
    l2.TextStrokeTransparency = 0
    l2.TextStrokeColor3 = Color3.new(0,0,0)
    l2.Font = Enum.Font.GothamBold
    l2.TextScaled = true
    l2.Text = val

    activeBillboards[id] = bb
end

RunService.Heartbeat:Connect(function()
    for _,o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("TextLabel") and o.Name=="Generation" and not o.Text:lower():find("fusing") then
            local parent = o.Parent
            local basePart
            while parent and parent ~= Workspace do
                if parent:IsA("Model") and parent:FindFirstChild("Base") then basePart = parent.Base break end
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
