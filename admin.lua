-- Mgby V11 - Painel Admin + ESP Players (Highlight + Nome)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Lista de comandos
local commands = {"rocket", "ragdoll", "balloon", "inverse", "nightvision", "jail", "jumpscare"}

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
title.Text = "Mgby V11"
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

-- FUNÇÕES DE ESP
local function createHighlight(char)
    if char:FindFirstChild("ESP_Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(0,0,255) -- azul
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0.1
    highlight.Parent = char
end

local function removeHighlight(char)
    local highlight = char:FindFirstChild("ESP_Highlight")
    if highlight then highlight:Destroy() end
end

local function createNameBillboard(char)
    if char:FindFirstChild("ESP_Name") then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Name"
    bb.Adornee = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
    bb.Size = UDim2.new(0,200,0,30)
    bb.StudsOffset = Vector3.new(0,3,0)
    bb.AlwaysOnTop = true
    bb.Parent = CoreGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = char.Name -- username
    label.TextColor3 = Color3.fromRGB(0,0,255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = bb
end

local function removeNameBillboard(char)
    local bb = char:FindFirstChild("ESP_Name") or CoreGui:FindFirstChild("ESP_Name")
    if bb then bb:Destroy() end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    if player.Character then
        createHighlight(player.Character)
        createNameBillboard(player.Character)
        player.CharacterAdded:Connect(function(char)
            if espEnabled then
                createHighlight(char)
                createNameBillboard(char)
            end
        end)
    end
end

-- Ativar ESP para todos
for _,p in ipairs(Players:GetPlayers()) do
    applyESP(p)
end

-- Aplicar para novos players
Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        applyESP(player)
    end
end)

-- Alternar ESP
espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP ON" or "ESP OFF"
    espButton.TextColor3 = espEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

    for _,p in ipairs(Players:GetPlayers()) do
        if espEnabled then
            applyESP(p)
        else
            removeHighlight(p.Character)
            removeNameBillboard(p.Character)
        end
    end
end)
