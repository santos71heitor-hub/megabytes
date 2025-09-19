-- Mgby V5
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Lista de comandos (admin)
local commands = {"rocket","ragdoll","balloon","inverse","nightvision","jail","jumpscare"}

-- LocalPlayer e PlayerGui
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui",10)
if not PlayerGui then warn("PlayerGui não carregou a tempo") return end

-- Cria ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MgbyV5Panel"
screenGui.Parent = PlayerGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,500)
frame.Position = UDim2.new(0.5,-150,0.5,-250) -- centralizado
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,15)
frameCorner.Parent = frame

-- Tornar arrastável
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
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Mgby V5"
title.TextColor3 = Color3.fromRGB(144,238,144)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Botão ESP Jogadores
local espEnabled = false
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.9,0,0,35)
espButton.Position = UDim2.new(0.05,0,0,50)
espButton.BackgroundColor3 = Color3.fromRGB(50,50,50) -- cinza escuro
espButton.TextColor3 = Color3.fromRGB(255,255,255)
espButton.Text = "ESP Jogadores: OFF"
espButton.Font = Enum.Font.GothamBold
espButton.TextScaled = true
espButton.Parent = frame

local playerHighlights = {}

local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP Jogadores: ON" or "ESP Jogadores: OFF"
    espButton.TextColor3 = espEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                if espEnabled then
                    if not playerHighlights[player] then
                        local h = Instance.new("Highlight")
                        h.Name = "Player_Highlight"
                        h.Adornee = player.Character
                        h.FillColor = Color3.fromRGB(255,165,0)
                        h.FillTransparency = 0.1
                        h.OutlineTransparency = 0.3
                        h.Parent = player.Character
                        playerHighlights[player] = h
                    end
                else
                    if playerHighlights[player] then
                        playerHighlights[player]:Destroy()
                        playerHighlights[player] = nil
                    end
                end
            end
            player.CharacterAdded:Connect(function(char)
                if espEnabled then
                    local h = Instance.new("Highlight")
                    h.Name = "Player_Highlight"
                    h.Adornee = char
                    h.FillColor = Color3.fromRGB(255,165,0)
                    h.FillTransparency = 0.1
                    h.OutlineTransparency = 0.3
                    h.Parent = char
                    playerHighlights[player] = h
                end
            end)
        end
    end
end

espButton.MouseButton1Click:Connect(toggleESP)

-- ScrollingFrame para botões dos jogadores
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

-- ESP PETS
local petsToShow = {
    "Los Combinasionas","Los Bros","Ketchuru and Musturu","Strawberry Elephant",
    "Ketupat Kepat","La Supreme Combinasion","Tralaledon","Celularcini Viciosini",
    "Los Noo My Hotspotsitos","Spaghetti Tualetti","Esok Sekolah","Los Hotspotsitos",
    "Dragon Cannelloni","Chicleteira Bicicleteira","La Extinct Grande","Garama and Madundung",
    "Nuclearo Dinossauro","Graipuss Medussi","Celularcini Viciosini"
}

local petsBillboards = {}
local petsESPEnabled = true -- ativo automaticamente

local function createPetESP(pet)
    if petsBillboards[pet] then return end

    -- Highlight
    if not pet:FindFirstChild("Pet_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Pet_Highlight"
        highlight.Adornee = pet
        highlight.FillColor = Color3.fromRGB(255,165,0)
        highlight.FillTransparency = 0.1
        highlight.OutlineTransparency = 0.3
        highlight.Parent = pet
    end

    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP_Billboard"
    billboard.Adornee = pet
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = pet

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.Position = UDim2.new(0,0,0,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextColor3 = Color3.fromRGB(255,255,0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    nameLabel.Text = pet.Name
    nameLabel.Parent = billboard

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1,0,0.5,0)
    valueLabel.Position = UDim2.new(0,0,0.5,0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = Color3.fromRGB(255,255,255)
    
    local genValue = 0
    local genObj = pet:FindFirstChild("Generation")
    if genObj and genObj:IsA("NumberValue") then
        genValue = genObj.Value
    end
    valueLabel.Text = "Generation: "..tostring(genValue)
    valueLabel.Parent = billboard

    petsBillboards[pet] = billboard
end

task.spawn(function()
    while true do
        if petsESPEnabled then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and table.find(petsToShow,obj.Name) then
                    createPetESP(obj)
                end
            end
        end
        task.wait(1)
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    if petsESPEnabled and obj:IsA("Model") and table.find(petsToShow,obj.Name) then
        task.defer(function()
            createPetESP(obj)
        end)
    end
end)
