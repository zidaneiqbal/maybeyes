local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Path Remote
local skillPath = RS:WaitForChild("事件"):WaitForChild("公用"):WaitForChild("技能")
local unequipRemote = skillPath:WaitForChild("\229\141\184\228\184\139\230\138\128\232\131\189")
local equipRemote = skillPath:WaitForChild("\232\163\133\229\164\135\230\138\128\232\131\189")
local useRemote = skillPath:WaitForChild("\228\189\191\231\148\168\230\138\128\232\131\189")
local TeleportRemote = RS:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\229\156\186\230\153\175"):WaitForChild("\228\188\160\233\128\129")

local isSkillRunning, isTPHookRunning, tpConnection = true, true, nil
local settings = { 
    ID1 = "9",
    ID2 = "1",
    ID3 = "2",
    Delay = 4,
    MoveDistance = 50,
    SkillType = 1 -- 1: Char, 2: Mob
}

local function startTeleportHook()
    if tpConnection then tpConnection:Disconnect() end
    local connections = getconnections(TeleportRemote.OnClientEvent)
    for _, conn in ipairs(connections) do
        local oldFunction = conn.Function
        conn:Disable()
        tpConnection = TeleportRemote.OnClientEvent:Connect(function(serverPos, isInstant, ...)
            if not isTPHookRunning then oldFunction(serverPos, isInstant, ...) return end
            local originalPos = (typeof(serverPos) == "CFrame") and serverPos.Position or serverPos
            local newPos = originalPos + ((Vector3.new(0, originalPos.Y, 0) - originalPos).Unit * settings.MoveDistance)
            oldFunction((typeof(serverPos) == "CFrame") and (CFrame.new(newPos) * (serverPos - serverPos.Position)) or newPos, isInstant, ...)
        end)
    end
end

local function executeSkill(slot)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- 1. Execute on Self (Character)
    local argsSelf = {
        slot,
        char,
        char.HumanoidRootPart.CFrame
    }
    useRemote:FireServer(unpack(argsSelf))
    
    -- 2. Execute on Mob (Auto-Detect Closest)
    local mobFolder = workspace:WaitForChild("\229\141\149\228\189\141\229\175\185\232\177\161") -- [单位对象]
    local children = mobFolder:GetChildren()
    
    local closestMob = nil
    local minDist = math.huge
    local myPos = char.HumanoidRootPart.Position

    -- Iterate to find the CLOSEST valid Mob
    for _, child in ipairs(children) do
        if child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") then
            local dist = (child.HumanoidRootPart.Position - myPos).Magnitude
            if dist < minDist then
                minDist = dist
                closestMob = child
            end
        end
    end
    
    if closestMob then
        print("DEBUG: Fired Skill on Mob: " .. closestMob.Name .. " (Dist: " .. math.floor(minDist) .. ")")
        local argsMob = {
            slot,
            closestMob,
            char.HumanoidRootPart.CFrame
        }
        useRemote:FireServer(unpack(argsMob))
    else
        -- Only warn if we really expected mobs but found none, though now we always try self so it's less critical.
        -- warn("DEBUG: No valid Mob Target found for 2nd execution.")
    end
end

local function pressKey(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function waitCooldownGUI(slotIndex)
    local PlayerGui = player:WaitForChild("PlayerGui")
    local mainGui = PlayerGui:WaitForChild("GUI")
    local cooldownLabel = nil
    
    -- Mencoba mencari label cooldown baik di PC maupun Mobile path
    local pcLabel, mobileLabel = nil, nil
    
    local pathName = "技能" .. (slotIndex + 1)
    if slotIndex == 4 then pathName = "技能2" end
    
    -- Check PC Path
    pcall(function()
        pcLabel = mainGui["主界面"]["技能"]["按键"][pathName]["按钮"]["倒计时"]
    end)
    
    -- Check Mobile Path
    pcall(function()
        mobileLabel = mainGui["主界面"]["技能"]["触摸"][pathName]["按钮"]["倒计时"]
    end)

    -- Decision Logic: Prioritize the one with visible text
    if pcLabel and pcLabel.Text ~= "" then
        cooldownLabel = pcLabel
        print("DEBUG: Selected PC Label (Active)")
    elseif mobileLabel and mobileLabel.Text ~= "" then
        cooldownLabel = mobileLabel
        print("DEBUG: Selected Mobile Label (Active)")
    elseif pcLabel then
        cooldownLabel = pcLabel
        print("DEBUG: Selected PC Label (Fallback - Empty Text)")
    elseif mobileLabel then
        cooldownLabel = mobileLabel
        print("DEBUG: Selected Mobile Label (Fallback - Empty Text)")
    end

    if cooldownLabel then
        -- print("DEBUG: Found Text: '" .. tostring(cooldownLabel.Text) .. "'")
        -- Tunggu sampai teks cooldown kosong (artinya siap digunakan)
        while cooldownLabel.Text ~= "" and isSkillRunning do
            -- task.wait(0.2)
            return true
        end
    else
        warn("DEBUG: Cooldown Label NOT found for slot " .. slotIndex)
        task.wait(settings.Delay)
        return false
    end
    if cooldownLabel then
        -- Tunggu sampai teks cooldown kosong (artinya siap digunakan)
        while cooldownLabel.Text ~= "" and isSkillRunning do
            -- task.wait(0.2)
            return true
        end
    else
        -- Fallback jika GUI tidak ditemukan, gunakan delay manual dari setting
        task.wait(settings.Delay)
        return false
    end
end

--- LOGIKA AUTO SKILL LOOP (MODIFIED) ---
local function startSkillLoop()
    while isSkillRunning do
        -- Kita iterasi Slot 1 sampai 3 (sesuai Remote Slot) dan Check Jika Skill Slot telah ter-fire, jika belum ulangi
        for slot = 1, 3 do
            if not isSkillRunning then break end
            -- 1. Persiapan Skill (Unequip & Equip)
            unequipRemote:FireServer(1)
            unequipRemote:FireServer(2)
            unequipRemote:FireServer(3)
            task.wait(0.2)
            
            if slot == 1 then
                equipRemote:FireServer(settings.ID1)
            elseif slot == 2 then
                equipRemote:FireServer(settings.ID2)
                equipRemote:FireServer(settings.ID1)
            elseif slot == 3 then
                equipRemote:FireServer(settings.ID3)
                equipRemote:FireServer(settings.ID2)
                equipRemote:FireServer(settings.ID1)
            end
            task.wait(0.3)
            
            -- 2. Eksekusi Skill
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if slot == 1 then
                    executeSkill(1)
                elseif slot == 2 then
                    executeSkill(2)
                elseif slot == 3 then
                    executeSkill(3)
                end
            end

            -- Check Jika Skill Slot telah ter-fire, jika belum ulangi
            while waitCooldownGUI(slot) ~= true and isSkillRunning do
                if slot == 1 then
                    executeSkill(1)
                elseif slot == 2 then
                    executeSkill(2)
                elseif slot == 3 then
                    executeSkill(3)
                end
                task.wait(0.5)
            end
            
            -- 3. Cek Cooldown (Integrasi script GUI yang kamu berikan)
            -- Kita panggil fungsi pengecekan label teks GUI
            waitCooldownGUI(slot+1) 
            
            -- 4. Tambahan jeda kecil agar tidak terdeteksi spam berlebih
            task.wait(settings.Delay + 0.5)
        end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DraggableEverything"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- FUNGSI UNTUK MEMBUAT OBJEK BISA DIGESER (DRAGGABLE)
local function makeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- TOMBOL IMAGE (Bisa Digeser)
local toggleImg = Instance.new("ImageButton")
toggleImg.Size = UDim2.new(0, 45, 0, 45)
toggleImg.Position = UDim2.new(0.1, 0, 0.1, 0)
toggleImg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleImg.Image = "rbxassetid://6031094678" -- Ganti ID di sini
toggleImg.Parent = screenGui
Instance.new("UICorner", toggleImg)
makeDraggable(toggleImg)

-- FRAME UTAMA (Bisa Digeser)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 125) -- Mulai dari ukuran 0 (tertutup)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame)
makeDraggable(mainFrame)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- LOGIKA BUKA/TUTUP (Klik Tombol)
local isOpen = false
toggleImg.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	mainFrame.Visible = true
	local targetSize = isOpen and UDim2.new(0, 175, 0, 125) or UDim2.new(0, 175, 0, 0)
	TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    TweenService:Create(toggleImg, TweenInfo.new(0.3), {Rotation = isOpen and 90 or 0}):Play()
end)

-- (Tambahkan isi UI seperti TextBox/Toggle di dalam mainFrame sesuai keinginanmu)
-- --- ISI UI (Input & Toggles) ---
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Auto Skill & TP Hook"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = mainFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.85, 0, 0, 30)
inputBox.Position = UDim2.new(0.075, 0, 0.20, 0)
inputBox.PlaceholderText = "Input SkillID"
inputBox.Text = ""
inputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
inputBox.TextColor3 = Color3.new(1, 1, 1)
inputBox.TextSize = 11
inputBox.Parent = mainFrame
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.85, 0, 0, 25)
saveBtn.Position = UDim2.new(0.075, 0, 0.48, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
saveBtn.Text = "SAVE"
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 11
saveBtn.Parent = mainFrame
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 4)

saveBtn.MouseButton1Click:Connect(function()
	settings.ID1 = inputBox.Text
	saveBtn.Text = "SAVED!"
	task.wait(0.5)
	saveBtn.Text = "SAVE"
end)

local function createToggle(name, yPos)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(0.85, 0, 0, 30)
	toggleFrame.Position = UDim2.new(0.075, 0, yPos, 0)
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.Parent = mainFrame
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Text = name
	label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.TextSize = 11
	label.Parent = toggleFrame
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 18)
	btn.Position = UDim2.new(1, -40, 0.5, -9)
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	btn.Text = ""
	btn.Parent = toggleFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0) -- Bulat sempurna (Capsule)
	
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 14, 0, 14)
	indicator.Position = UDim2.new(0, 2, 0.5, -7)
	indicator.BackgroundColor3 = Color3.new(1, 1, 1)
	indicator.Parent = btn
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
	
	local status = true
	btn.MouseButton1Click:Connect(function()
		status = not status
        isSkillRunning = not isSkillRunning
        isTPHookRunning = not isTPHookRunning
		local goalPos = status and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
		local goalColor = status and Color3.fromRGB(50, 180, 100) or Color3.fromRGB(80, 80, 80)
		
		TweenService:Create(indicator, TweenInfo.new(0.2), {Position = goalPos}):Play()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
        if isSkillRunning then task.spawn(startSkillLoop) end
        if isTPHookRunning then startTeleportHook() end
	end)
end

createToggle("Auto Skill & Teleport", 0.67)
-- createToggle("Auto Farm", 0.68)
-- createToggle("Infinite Jump", 0.84)
