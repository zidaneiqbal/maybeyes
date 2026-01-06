local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Konfigurasi
local passBenar = "21november2004" 
local passBox = ""
local MOVE_DISTANCE = 50

-- Path Remote
local skillPath = RS:WaitForChild("事件"):WaitForChild("公用"):WaitForChild("技能")
local unequipRemote = skillPath:WaitForChild("\229\141\184\228\184\139\230\138\128\232\131\189")
local equipRemote = skillPath:WaitForChild("\232\163\133\229\164\135\230\138\128\232\131\189")
local useRemote = skillPath:WaitForChild("\228\189\191\231\148\168\230\138\128\232\131\189")
local TeleportRemote = RS:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\229\156\186\230\153\175"):WaitForChild("\228\188\160\233\128\129")

local isSkillRunning, isTPHookRunning, tpConnection = false, false, nil
local settings = { 
    ID1 = "9",
    ID2 = "1",
    ID3 = "2",
    Delay = 4 
}

--- FUNGSI DRAGGABLE (MOBILE OPTIMIZED) ---
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--- LOGIKA CORE ---
local function startTeleportHook()
    if tpConnection then tpConnection:Disconnect() end
    local connections = getconnections(TeleportRemote.OnClientEvent)
    for _, conn in ipairs(connections) do
        local oldFunction = conn.Function
        conn:Disable()
        tpConnection = TeleportRemote.OnClientEvent:Connect(function(serverPos, isInstant, ...)
            if not isTPHookRunning then oldFunction(serverPos, isInstant, ...) return end
            local originalPos = (typeof(serverPos) == "CFrame") and serverPos.Position or serverPos
            local newPos = originalPos + ((Vector3.new(0, originalPos.Y, 0) - originalPos).Unit * MOVE_DISTANCE)
            oldFunction((typeof(serverPos) == "CFrame") and (CFrame.new(newPos) * (serverPos - serverPos.Position)) or newPos, isInstant, ...)
        end)
    end
end

local function executeSkill(slot)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        useRemote:FireServer(slot, char, char.HumanoidRootPart.CFrame)
    end
end

local function pressKey(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end


local function startSkillLoop()
    while isSkillRunning do
        local time = os.time()
        -- Skill 1 Sequence
        unequipRemote:FireServer(1); unequipRemote:FireServer(2); unequipRemote:FireServer(3)
        equipRemote:FireServer(settings.ID1); equipRemote:FireServer(settings.ID2); equipRemote:FireServer(settings.ID3)
        task.wait(0.3)
        
        pressKey(Enum.KeyCode.Two)
        task.wait(settings.Delay)
        if not isSkillRunning then break end

        -- Skill 2 Sequence
        unequipRemote:FireServer(1); unequipRemote:FireServer(2); task.wait(0.5)
        equipRemote:FireServer(settings.ID2); task.wait(0.3); equipRemote:FireServer(settings.ID1)
        task.wait(0.5); pressKey(Enum.KeyCode.Three)
        task.wait(settings.Delay)
        if not isSkillRunning then break end

        -- Skill 3 Sequence
        unequipRemote:FireServer(1); unequipRemote:FireServer(2); unequipRemote:FireServer(3); task.wait(0.5)
        equipRemote:FireServer(settings.ID2); task.wait(0.3); equipRemote:FireServer(settings.ID3); task.wait(0.3); equipRemote:FireServer(settings.ID1)
        task.wait(0.5); pressKey(Enum.KeyCode.Four)
        -- wait time minimum is 16 sec from the first skill, if it's more than 16 sec do the next loop
        task.wait(math.max(16 - (os.time() - time), 0))
    end
end

--- UI SETUP (SMALL & MOBILE FRIENDLY) ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "MobileSkillHub"; screenGui.ResetOnSpawn = false

-- LOGIN FRAME (Simple)
local loginFrame = Instance.new("Frame", screenGui)
loginFrame.Size = UDim2.new(0, 180, 0, 110); loginFrame.Position = UDim2.new(0.5, -90, 0.4, 0)
loginFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); loginFrame.BorderSizePixel = 0
makeDraggable(loginFrame)

local passBox = Instance.new("TextBox", loginFrame)
passBox.Size = UDim2.new(0.8, 0, 0, 25); passBox.Position = UDim2.new(0.1, 0, 0.25, 0)
passBox.PlaceholderText = "Password"; passBox.Text = ""; passBox.TextSize = 12

local loginBtn = Instance.new("TextButton", loginFrame)
loginBtn.Size = UDim2.new(0.6, 0, 0, 25); loginBtn.Position = UDim2.new(0.2, 0, 0.6, 0)
loginBtn.Text = "OK"; loginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)

-- MAIN MENU (Slim & Narrow)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 130, 0, 225); mainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mainFrame.Visible = false; mainFrame.BorderSizePixel = 0
makeDraggable(mainFrame)

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 25, 0, 25); closeBtn.Position = UDim2.new(1, -25, 0, 0)
closeBtn.Text = "X"; closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); closeBtn.TextColor3 = Color3.new(1,1,1)

local idInp = Instance.new("TextBox", mainFrame)
idInp.Size = UDim2.new(0.85, 0, 0, 22); idInp.Position = UDim2.new(0.075, 0, 0.15, 0)
idInp.PlaceholderText = "ID (9)"; idInp.Text = ""; idInp.TextSize = 11

local delayInp = Instance.new("TextBox", mainFrame)
delayInp.Size = UDim2.new(0.85, 0, 0, 22); delayInp.Position = UDim2.new(0.075, 0, 0.3, 0)
delayInp.PlaceholderText = "Delay (4)"; delayInp.Text = ""; delayInp.TextSize = 11

local updBtn = Instance.new("TextButton", mainFrame)
updBtn.Size = UDim2.new(0.85, 0, 0, 20); updBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
updBtn.Text = "SAVE"; updBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); updBtn.TextSize = 11

local skBtn = Instance.new("TextButton", mainFrame)
skBtn.Size = UDim2.new(0.85, 0, 0, 35); skBtn.Position = UDim2.new(0.075, 0, 0.6, 0)
skBtn.Text = "SKILL: OFF"; skBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30); skBtn.TextColor3 = Color3.new(1,1,1); skBtn.TextSize = 11

local tpBtn = Instance.new("TextButton", mainFrame)
tpBtn.Size = UDim2.new(0.85, 0, 0, 35); tpBtn.Position = UDim2.new(0.075, 0, 0.82, 0)
tpBtn.Text = "TP: OFF"; tpBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30); tpBtn.TextColor3 = Color3.new(1,1,1); tpBtn.TextSize = 11

--- EVENTS ---
-- 1. Jalankan UI Setup (Pastikan loginFrame dan mainFrame sudah di-define di atas)
-- loginFrame.Visible = false
-- mainFrame.Visible = false

-- 2. Cek Password dari Loader (_G.pass)
local function checkAccess()
    -- Mengambil password dari loader: _G.pass = "21november2004"
    local loaderPass = _G.pass or "" 
    print(loaderPass)
    
    if loaderPass == passBenar then
        -- Jika Benar: Lewati login, langsung ke menu utama
        loginFrame.Visible = false
        mainFrame.Visible = true
        print("Access Granted: Auto-logged in via Loader.")
    else
        -- Jika Salah/Kosong: Tampilkan layar login manual
        loginFrame.Visible = true
        mainFrame.Visible = false
        print("Access Denied: Manual login required.")
    end
end

-- 3. Event untuk Tombol Login Manual (Jika auto-login gagal)
loginBtn.MouseButton1Click:Connect(function()
    if passBox.Text:gsub("%s+", "") == passBenar then
        loginFrame.Visible = false
        mainFrame.Visible = true
    else
        passBox.Text = ""
        passBox.PlaceholderText = "PASSWORD SALAH!"
    end
end)

-- 4. Event untuk Update Settings (ID & Delay)
updBtn.MouseButton1Click:Connect(function()
    settings.ID1 = idInp.Text ~= "" and idInp.Text or settings.ID1
    settings.Delay = tonumber(delayInp.Text) or settings.Delay
    updBtn.Text = "SAVED!"; task.wait(0.5); updBtn.Text = "SAVE"
end)

-- 5. Toggle Buttons
skBtn.MouseButton1Click:Connect(function()
    isSkillRunning = not isSkillRunning
    skBtn.Text = isSkillRunning and "SKILL: ON" or "SKILL: OFF"
    skBtn.BackgroundColor3 = isSkillRunning and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(100, 30, 30)
    if isSkillRunning then task.spawn(startSkillLoop) end
end)

tpBtn.MouseButton1Click:Connect(function()
    isTPHookRunning = not isTPHookRunning
    tpBtn.Text = isTPHookRunning and "TP: ON" or "TP: OFF"
    tpBtn.BackgroundColor3 = isTPHookRunning and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(100, 30, 30)
    if isTPHookRunning then startTeleportHook() end
end)

-- 6. Close UI
closeBtn.MouseButton1Click:Connect(function()
    isSkillRunning, isTPHookRunning = false, false
    if tpConnection then tpConnection:Disconnect() end
    screenGui:Destroy()
end)

-- Jalankan pengecekan akses saat script pertama kali di-load
checkAccess()
