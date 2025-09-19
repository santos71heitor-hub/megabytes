-- ESP PETS AUTOMÁTICO (nome + geração + highlight ciano) - V8 Ajustado
local activeBillboards = {}

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

    -- Determinar posição acima da cabeça
    local head = pet:FindFirstChild("Head") or pet:FindFirstChild("HumanoidRootPart") or pet.PrimaryPart
    if not head then return end

    -- Billboard
    local bb = Instance.new("BillboardGui", CoreGui)
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3, 0) -- acima da cabeça
    bb.ExtentsOffset = Vector3.new(0,0,0)

    -- Nome do pet (amarelo)
    local nameLabel = Instance.new("TextLabel", bb)
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255,255,0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Text = pet.Name

    -- Valor por segundo (branco)
    local genLabel = pet:FindFirstChild("Generation")
    local val = genLabel and genLabel.Text or "0/s"

    local valueLabel = Instance.new("TextLabel", bb)
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
