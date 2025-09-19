----------------------------------------------------------------
-- ESP PETS V8 - mostra somente os pets específicos com Generation
----------------------------------------------------------------
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Lista de pets para ESP
local targetNames = {
    ["Ketchuru and Musturu"] = true,
    ["Strawberry Elephant"] = true,
    ["Ketupat Kepat"] = true,
    ["La Supreme Combinasion"] = true,
    ["Tralaledon"] = true,
    ["Celularcini Viciosini"] = true,
    ["Los Noo My Hotspotsitos"] = true,
    ["Spaghetti Tualetti"] = true,
    ["Esok Sekolah"] = true,
    ["Los Hotspotsitos"] = true,
    ["Dragon Cannelloni"] = true,
    ["Chicleteira Bicicleteira"] = true,
    ["La Extinct Grande"] = true,
    ["Garama and Madundung"] = true,
    ["Nuclearo Dinossauro"] = true,
    ["Graipuss Medussi"] = true,
    ["Celularcini Viciosini"] = true,
    ["Los Combinasionas"] = true,
    ["Los Bros"] = true
}

-- Guardar os billboards ativos
local activeBillboards = {}

-- Função para converter texto em número
local function parseNum(t)
    t = t:gsub("[%$,]","")
    local n,s = t:match("([%d%.]+)([KMB]?)")
    n = tonumber(n) or 0
    local mult={K=1e3,M=1e6,B=1e9}
    return n*(mult[s] or 1)
end

-- Criar Billboard
local function criarBillboard(basePart,name,val,id)
    -- Destroi antigo se já existir para esse mob
    if activeBillboards[id] then
        activeBillboards[id]:Destroy()
        activeBillboards[id] = nil
    end

    local bb=Instance.new("BillboardGui",CoreGui)
    bb.Size=UDim2.new(0,200,0,50)
    bb.Adornee=basePart
    bb.AlwaysOnTop=true
    bb.StudsOffset=Vector3.new(0,4,0)

    local l1=Instance.new("TextLabel",bb)
    l1.Size=UDim2.new(1,0,0.5,0)
    l1.BackgroundTransparency=1
    l1.TextColor3=Color3.fromRGB(255,255,0) -- amarelo forte
    l1.TextStrokeTransparency=0
    l1.TextStrokeColor3=Color3.new(0,0,0)
    l1.Font=Enum.Font.GothamBold
    l1.TextScaled=true
    l1.Text=name or "N/A"

    local l2=Instance.new("TextLabel",bb)
    l2.Size=UDim2.new(1,0,0.5,0)
    l2.Position=UDim2.new(0,0,0.5,0)
    l2.BackgroundTransparency=1
    l2.TextColor3=Color3.fromRGB(255,255,255) -- branco
    l2.TextStrokeTransparency=0
    l2.TextStrokeColor3=Color3.new(0,0,0)
    l2.Font=Enum.Font.GothamBold
    l2.TextScaled=true
    l2.Text=val or "0/s"

    activeBillboards[id] = bb
end

-- Loop para procurar os pets
RunService.Heartbeat:Connect(function()
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("TextLabel") and o.Name=="Generation" and not o.Text:lower():find("fusing") then
            local parent=o.Parent
            local basePart
            while parent and parent~=workspace do
                if parent:IsA("Model") and parent:FindFirstChild("Base") then
                    basePart=parent.Base break
                end
                parent=parent.Parent
            end

            if basePart then
                local displayName= o.Parent:FindFirstChild("DisplayName")
                local petName = displayName and displayName.Text or "N/A"

                -- Só cria ESP se for pet da lista
                if targetNames[petName] then
                    criarBillboard(basePart,petName,o.Text, basePart:GetDebugId())
                end
            end
        end
    end
end)
