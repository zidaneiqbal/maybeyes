if not game:IsLoaded() then
    game.Loaded:Wait()
end

local currentGameId = game.PlaceId
local TARGET_GAME_ID = 18645473062
webhookURL =
    'https://discord.com/api/webhooks/1427270496797589606/Wg1Lt11GaVxKwrl3vlQCVuG4WqcH2VRkOOrEENCn5I-DHYx5IiXmmxptyIkN81fx_WGP'

if currentGameId == TARGET_GAME_ID then
    print('检测到目标游戏，正在执行脚本...')

    -- Wait for player and player GUI to exist
    local player = game:GetService('Players').LocalPlayer
    while not player:FindFirstChild('PlayerGui') do
        task.wait(1)
    end
    local playerGui = player.PlayerGui

    -- Function to safely find the loading GUI
    local function findLoadingGui()
        local maxAttempts = 30
        for i = 1, maxAttempts do
            local success, gui = pcall(function()
                return playerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\138\160\232\189\189\233\161\181\233\157\162']
            end)
            if success and gui then
                return gui
            end
            task.wait(0.5)
        end
        return nil
    end

    -- Main waiting logic
    local loadingGui = findLoadingGui()

    if loadingGui then
        print('Loading...')

        -- Wait for it to become visible if not already
        if not loadingGui.Visible then
            local visibleChanged = false
            local connection = loadingGui
                :GetPropertyChangedSignal('Visible')
                :Connect(function()
                    visibleChanged = true
                end)

            -- Timeout after 25 seconds if never becomes visible
            local startTime = os.time()
            while not visibleChanged and os.time() - startTime < 25 do
                task.wait(0.1)
            end
            connection:Disconnect()
        end

        -- Now wait for it to become invisible
        if loadingGui.Visible then
            print('Waiting Loading to disappear...')
            while loadingGui.Parent and loadingGui.Visible do
                loadingGui:GetPropertyChangedSignal('Visible'):Wait()
                task.wait(0.1)
            end
        end
    else
        warn('⚠️ No Loading Screen，Executing Script...')
    end

    print('✅ Loading Complete, Continue Executing Script...')
    local library = loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/supleruckydior/test/refs/heads/main/menu.json',
            true
        )
    )()
    local RespawPoint = loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/Tseting-nil/-Cultivation-Simulator-script/refs/heads/main/%E6%89%8B%E6%A9%9F%E7%AB%AFUI/%E9%85%8D%E7%BD%AE%E4%B8%BB%E5%A0%B4%E6%99%AF.lua'
        )
    )()
    loadstring(
        game:HttpGet(
            'https://github.com/supleruckydior/test/raw/refs/heads/main/respawn.json'
        )
    )()
    local JsonHandler = loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/Tseting-nil/-Cultivation-Simulator-script/refs/heads/main/JSON%E6%A8%A1%E7%B5%84.lua'
        )
    )()
    local AntiAFK = game:GetService('VirtualUser')
    game.Players.LocalPlayer.Idled:Connect(function()
        AntiAFK:CaptureController()
        AntiAFK:ClickButton2(Vector2.new())
        wait(2)
    end)
    local window = library:AddWindow(
        'Cultivation-Simulator  養成模擬器',
        {
            main_color = Color3.fromRGB(41, 74, 122),
            min_size = Vector2.new(665, 390),
            can_resize = true,
        }
    )
    local features = window:AddTab('Rdme')
    local features1 = window:AddTab('Main')
    local features2 = window:AddTab('World')
    local features3 = window:AddTab('Dungeon')
    local features4 = window:AddTab('Pull')
    local features5 = window:AddTab('Misc')
    local features6 = window:AddTab('UI')
    local features7 = window:AddTab('Configuration')
    local features8 = window:AddTab('Farm Management')
    local features9 = window:AddTab('Join')
    local ws = game:GetService('Workspace')
    local Players = game.Players
    local localPlayer = game.Players.LocalPlayer
    local playerGui = player.PlayerGui
    local RespawPointnum = RespawPoint:match('%d+')
    print('重生點編號：' .. RespawPointnum)
    local reworld = ws:waitForChild('主場景' .. RespawPointnum)
        :waitForChild('重生点')
    local TPX, TPY, TPZ =
        reworld.Position.X, reworld.Position.Y + 5, reworld.Position.Z
    local Restart = false
    local finishworldnum
    local values = player:WaitForChild('值')
    local privileges = values:WaitForChild('特权')
    local gowordlevels = 1
    local isDetectionEnabled = true
    local playerInRange = false
    local timescheck = 0
    local hasPrintedNoPlayer = false
    local showone = false
    local savemodetime = 0
    local savemodetime2 = 0
    local savemodebutton
    local function deepWait(parent, path, eachTimeout)
        local obj = parent
        for _, name in ipairs(path) do
            obj = obj and obj:WaitForChild(name, eachTimeout or 5)
            if not obj then
                return nil
            end
        end
        return obj
    end

    -- 右上角提示（简单版）
    local function showTopRightNotice(text, lifetime)
        local pg = player:WaitForChild('PlayerGui')
        local gui = pg:FindFirstChild('FarmNoticeGui')
            or Instance.new('ScreenGui')
        gui.Name = 'FarmNoticeGui'
        gui.ResetOnSpawn = false
        gui.Parent = pg

        local label = gui:FindFirstChild('Notice') or Instance.new('TextLabel')
        label.Name = 'Notice'
        label.AnchorPoint = Vector2.new(1, 0)
        label.Position = UDim2.new(1, -20, 0, 20)
        label.Size = UDim2.new(0, 260, 0, 34)
        label.BackgroundTransparency = 0.3 -- 不透明背景
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- 黑色背景
        label.TextColor3 = Color3.fromRGB(255, 0, 0) -- 红色文字
        label.TextScaled = true
        label.TextWrapped = true
        label.Font = Enum.Font.SourceSansSemibold
        label.Text = text
        label.Parent = gui

        task.delay(lifetime or 3, function()
            if label then
                label:Destroy()
            end
            if gui and #gui:GetChildren() == 0 then
                gui:Destroy()
            end
        end)
    end
    local donationFinished = false -- 初始为 false
    local herbBuyFinished = false -- 初始为 false
    local herbCollectFinished = false -- 初始为 false
    local farmReady = false -- 初始为 false
    local function checkAllTasksFinished()
        if
            donationFinished
            and herbBuyFinished
            and herbCollectFinished
            and farmReady
        then
            showTopRightNotice('Daily Complete!', 999)
        end
    end
    local function setupFeaturesTab(features)
        local function checkPlayersInRange()
            local character = localPlayer.Character
            if
                not character or not character:FindFirstChild(
                    'HumanoidRootPart'
                )
            then
                return
            end
            local boxPosition = character.HumanoidRootPart.Position
            local boxSize = Vector3.new(500, 500, 500) / 2
            playerInRange = false
            for _, player in pairs(Players:GetPlayers()) do
                if
                    (player ~= localPlayer)
                    and player.Character
                    and player.Character:FindFirstChild('HumanoidRootPart')
                then
                    local playerPosition =
                        player.Character.HumanoidRootPart.Position
                    local inRange = (
                        math.abs(playerPosition.X - boxPosition.X) <= boxSize.X
                    )
                        and (math.abs(playerPosition.Y - boxPosition.Y) <= boxSize.Y)
                        and (
                            math.abs(playerPosition.Z - boxPosition.Z)
                            <= boxSize.Z
                        )
                    if inRange then
                        playerInRange = true
                        break
                    end
                end
            end
            if playerInRange then
                if timescheck == 0 then
                    savemodetime2 = 0
                    savemodetime = 0
                    timescheck = 1
                    hasPrintedNoPlayer = true
                end
            elseif timescheck == 1 then
                timescheck = 0
                savemodetime2 = 0
                hasPrintedNoPlayer = false
            end
            if not playerInRange and not hasPrintedNoPlayer then
                savemodetime = 0
                savemodetime2 = 0
                hasPrintedNoPlayer = true
            end
        end
        local function setupRangeDetection()
            while true do
                if isDetectionEnabled then
                    checkPlayersInRange()
                end
                wait(0.1)
            end
        end
        local function toggleDetection()
            isDetectionEnabled = not isDetectionEnabled
            print(
                '檢測已' .. ((isDetectionEnabled and '啟用') or '關閉')
            )
            if not isDetectionEnabled then
                savemodetime = 0
                savemodetime2 = 0
            end
        end
        local function getGiftCountdown(index)
            local gift = Online_Gift:FindFirstChild('Online_Gift' .. index)
            if not gift then
                return nil
            end
            local countdownText = gift:FindFirstChild('按钮')
                :FindFirstChild('倒计时').Text
            if countdownText == 'CLAIMED!' then
                return 0
            elseif countdownText == 'DONE' then
                local args = { [1] = index }
                game:GetService('ReplicatedStorage')
                    :FindFirstChild('\228\186\139\228\187\182')
                    :FindFirstChild('\229\133\172\231\148\168')
                    :FindFirstChild(
                        '\232\138\130\230\151\165\230\180\187\229\138\168'
                    )
                    :FindFirstChild(
                        '\233\162\134\229\143\150\229\165\150\229\138\177'
                    )
                    :FireServer(unpack(args))
                return 0
            else
                local minutes, seconds = countdownText:match('^(%d+):(%d+)$')
                if minutes and seconds then
                    return (tonumber(minutes) * 60) + tonumber(seconds)
                end
            end
            return nil
        end
        local function checkOnlineGiftcountdown()
            local minCountdown = math.huge
            local Countdown = {}
            for i = 1, 6 do
                local totalSeconds = getGiftCountdown(i)
                if totalSeconds then
                    Countdown[i] = totalSeconds
                    OnlineGift_data[i] = totalSeconds
                    if (totalSeconds < minCountdown) and (totalSeconds > 0) then
                        minCountdown = totalSeconds
                    end
                else
                    Countdown[i] = nil
                end
            end
            if minCountdown ~= math.huge then
                if localCountdownActive then
                    for i = 1, 6 do
                        if Countdown[i] and (Countdown[i] > 0) then
                            Countdown[i] = Countdown[i] - 1
                            local minutes = math.floor(Countdown[i] / 60)
                            local seconds = Countdown[i] % 60
                            local formattedTime =
                                string.format('%02d:%02d', minutes, seconds)
                            Online_Gift:FindFirstChild('Online_Gift' .. i)
                                :FindFirstChild('按钮')
                                :FindFirstChild('倒计时').Text =
                                formattedTime
                        end
                    end
                    minCountdown = minCountdown - 1
                else
                end
            end
        end
        local function chaangeonlinegiftname()
            for i = 1, 6 do
                local giftName = '在线奖励0' .. i
                local gift = Online_Gift:FindFirstChild(giftName)
                if gift then
                    gift.Name = 'Online_Gift' .. tostring(gift.LayoutOrder + 1)
                    print('名稱已更改為：' .. gift.Name)
                else
                    allGiftsExist = false
                    break
                end
            end
            if allGiftsExist then
                print('在線獎勵--名稱--已全部更改')
            else
                print('名稱已重複或部分名稱不存在')
            end
        end
        local function checkTimeAndRun()
            spawn(function()
                while true do
                    local currentTime = os.time()
                    local utcTime = os.date('!*t', currentTime)
                    local utcPlus8Time = os.date('*t', currentTime + (8 * 3600))
                    if (utcPlus8Time.hour == 0) and (utcPlus8Time.min == 0) then
                        print(
                            'UTC+8 時間為 00:00，開始執行更新數據...'
                        )
                        spawn(function()
                            allGiftsExist = true
                            chaangeonlinegiftname()
                            wait(1)
                            checkOnlineGiftcountdown()
                        end)
                        wait(60)
                    end
                    wait(1)
                end
            end)
        end
        checkTimeAndRun()
        features4:Show()
        local AddLabelfeatures = features:AddLabel('Respawn Point: Respawn Point')
        AddLabelfeatures.Text = 'Respawn Point: '
            .. RespawPoint
            .. ' -- If TP Error, return home then use the button below'
        local function Respawn_Point()
            RespawPoint = loadstring(
                game:HttpGet(
                    'https://raw.githubusercontent.com/Tseting-nil/-Cultivation-Simulator-script/refs/heads/main/%E6%89%8B%E6%A9%9F%E7%AB%AFUI/%E9%85%8D%E7%BD%AE%E4%B8%BB%E5%A0%B4%E6%99%AF.lua'
                )
            )()
            AddLabelfeatures.Text = 'Respawn Point: '
                .. RespawPoint
                .. ' -- If TP Error, return home then use the button below'
            print('最近的出生點：' .. RespawPoint)
            RespawPointnum = RespawPoint:match('%d+')
            print('重生點編號：' .. RespawPointnum)
            reworld = workspace
                :waitForChild('主場景' .. RespawPointnum)
                :waitForChild('重生点')
            TPX, TPY, TPZ =
                reworld.Position.X, reworld.Position.Y + 5, reworld.Position.Z
            print('傳送座標：' .. TPX .. ' ' .. TPY .. ' ' .. TPZ)
            player.Character:WaitForChild('HumanoidRootPart').CFrame =
                CFrame.new(TPX, TPY, TPZ)
        end
        features:AddButton('TP Fix', function()
            Respawn_Point()
        end)
        local function updateButtonText()
            if isDetectionEnabled then
                savemodebutton.Text = ' Status：Safe Mode Enabled'
            else
                savemodebutton.Text = ' Status: Safe Mode Disabled'
            end
        end
        savemodebutton = features:AddButton(
            ' Black Screen：On/Off ',
            function()
                inRange = false
                playerInRange = false
                timescheck = 0
                hasPrintedNoPlayer = false
                toggleDetection()
                updateButtonText()
            end
        )
        updateButtonText()
        spawn(setupRangeDetection)
        local screenGui = Instance.new('ScreenGui')
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild('PlayerGui')
        local blackBlock = Instance.new('Frame')
        blackBlock.Size = UDim2.new(200, 0, 200, 0)
        blackBlock.Position = UDim2.new(0, 0, 0, 0)
        blackBlock.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blackBlock.Visible = false
        blackBlock.Parent = screenGui
        features:AddButton('Black Screen: On/Off', function()
            blackBlock.Visible = not blackBlock.Visible
        end)
    end

    local function setupFeatures1Tab(features1)
        local timeLabel =
            features1:AddLabel('Time Until Auto-Fetch: 0 Detik')
        local playerGui = game.Players.LocalPlayer.PlayerGui
        local Online_Gift = playerGui.GUI
            :WaitForChild('二级界面')
            :WaitForChild('节日活动商店')
            :WaitForChild('背景')
            :WaitForChild('右侧界面')
            :WaitForChild('在线奖励')
            :WaitForChild('列表')
        local Gife_check = false
        local countdownList = {}
        local hasExecutedToday = false
        local lastExecutedDay = os.date('%d')

        local function convertToSeconds(timeText)
            local minutes, seconds = string.match(timeText, '(%d+):(%d+)')
            if minutes and seconds then
                return (tonumber(minutes) * 60) + tonumber(seconds)
            end
            return nil
        end
        local function GetOnlineGiftCountdown()
            hasExecutedToday = true
            local minTime = math.huge
            for i = 1, 6 do
                local rewardName = string.format('在线奖励%02d', i)
                local rewardFolder = Online_Gift:FindFirstChild(rewardName)
                if rewardFolder then
                    local button = rewardFolder:FindFirstChild('按钮')
                    local countdown = button
                        and button:FindFirstChild('倒计时')
                    if countdown then
                        local countdownText = countdown.Text
                        countdownList[rewardName] = countdownText
                        if string.match(countdownText, 'CLAIMED!') then
                        elseif string.match(countdownText, 'DONE') then
                            minTime = math.min(minTime, 0)
                        elseif string.match(countdownText, '%d+:%d+') then
                            local totalSeconds = convertToSeconds(countdownText)
                            if totalSeconds then
                                minTime = math.min(minTime, totalSeconds)
                            end
                        end
                    end
                end
            end
            return ((minTime < math.huge) and minTime) or nil
        end
        local minCountdown = GetOnlineGiftCountdown()
        local nowminCountdown = minCountdown
        local function Online_Gift_start()
            local newMinCountdown = GetOnlineGiftCountdown()
            if newMinCountdown and (newMinCountdown == minCountdown) then
                nowminCountdown = nowminCountdown - 1
            else
                minCountdown = newMinCountdown
                nowminCountdown = minCountdown
            end
            if nowminCountdown and (nowminCountdown > 0) then
                timeLabel.Text = string.format(
                    'Auto-fetch in %d seconds',
                    nowminCountdown
                )
            elseif nowminCountdown and (nowminCountdown <= 0) then
                timeLabel.Text = 'Countdown finished, preparing to claim rewards'
                for i = 1, 6 do
                    local args = { [1] = i }
                    game:GetService('ReplicatedStorage')
                        :FindFirstChild('\228\186\139\228\187\182')
                        :FindFirstChild('\229\133\172\231\148\168')
                        :FindFirstChild(
                            '\232\138\130\230\151\165\230\180\187\229\138\168'
                        )
                        :FindFirstChild(
                            '\233\162\134\229\143\150\229\165\150\229\138\177'
                        )
                        :FireServer(unpack(args))
                end
            else
                timeLabel.Text = 'All rewards claimed'
                Gife_check = false
            end
        end
        local function Online_Gift_check()
            while Gife_check do
                Online_Gift_start()
                wait(1)
            end
        end
        local function ClaimOnlineRewards()
            Gife_check = true
            spawn(Online_Gift_check)
        end
        -- 创建按钮时引用函数
        features1:AddButton('Auto Claim Online Rewards and Mail', ClaimOnlineRewards)
        -- 启动时自动执行
        task.defer(function()
            ClaimOnlineRewards()
        end)
        local function CheckAllRewardsCompleted()
            local allCompleted = true
            GetOnlineGiftCountdown()
            for i = 1, 6 do
                local rewardName = string.format('在线奖励%02d', i)
                local status = countdownList[rewardName]
                if not status or not string.match(status, 'DONE') then
                    allCompleted = false
                    break
                end
            end
            if allCompleted then
                print('All online rewards have been completed!')
                Gife_check = false
            end
        end
        spawn(function()
            while Gife_check and not hasExecutedToday do
                CheckAllRewardsCompleted()
                wait(60)
            end
        end)
        spawn(function()
            while true do
                local currentUTCHour = tonumber(os.date('!*t').hour)
                local currentUTCDate = os.date('!*t').day
                local currentLocalHour = currentUTCHour + 8
                if currentLocalHour >= 24 then
                    currentLocalHour = currentLocalHour - 24
                end
                local currentLocalDate = currentUTCDate
                if currentLocalHour == 0 then
                    if lastExecutedDay ~= currentLocalDate then
                        hasExecutedToday = false
                        print('UTC+8 00:00，自動領取在線獎勳')
                        Gife_check = true
                        lastExecutedDay = currentLocalDate
                    end
                end
                wait(60)
            end
        end)
    local Autocollmission = features1:AddSwitch(
        'Auto Claim Task(Gamepass Task and Gift)',
        function(bool)
            Autocollmissionbool = bool
            if Autocollmissionbool then
                -- 主任務循環（每60秒執行一次）
                spawn(function()
                    while Autocollmissionbool do
                        mainmissionchack()
                        everydaymission()
                        gamepassmission()
                        gamepassgiftget()
                        potionfull()
                        wait(20)
                    end
                end)

                -- dailyspin 獨立循環（每500秒執行一次）
                spawn(function()
                    while Autocollmissionbool do
                        dailyspin()
                        offlinereward()
                        everydaygem()
                        wait(500)
                    end
                end)
            end
        end
    )

    Autocollmission:Set(true)
    local invest = features1:AddSwitch('Auto Execute Investment', function(bool)
        investbool = bool
        if investbool then
            spawn(function()
                while investbool do
                    for i = 1, 3 do
                        local args = { i }
                        game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\133\172\231\148\168']['\229\149\134\229\186\151']['\233\147\182\232\161\140']['\233\162\134\229\143\150\231\144\134\232\180\162']
                            :FireServer(unpack(args))
                    end
                    wait(5)
                    for i = 1, 3 do
                        local args = { i }
                        game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\133\172\231\148\168']['\229\149\134\229\186\151']['\233\147\182\232\161\140']['\232\180\173\228\185\176\231\144\134\232\180\162']
                            :FireServer(unpack(args))
                    end
                    wait(600)
                end
            end)
        end
    end)
    invest:Set(true)
    local function openFarm5()
        pcall(function()
            game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\134\156\231\148\176']['\229\134\156\231\148\176UI']['\229\177\158\230\128\167\229\140\186\229\159\159']
                :FireServer(5)
        end)
        task.wait(0.5) -- 给UI一点时间打开
    end

        -- 读取你指定路径上的数字文本
        local function readFarm5Number()
            local root = player:WaitForChild('PlayerGui'):WaitForChild('GUI')

            local label = deepWait(root, {
                '\228\186\140\231\186\167\231\149\140\233\157\162',
                '\229\134\156\231\148\176',
                '\232\131\140\230\153\175',
                '\229\177\158\230\128\167\229\140\186\229\159\159',
                '\230\148\182\233\155\134\230\140\137\233\146\174',
                '\230\149\176\233\135\143\229\140\186',
                '\230\149\176\233\135\143',
            }, 5)

            if not label or not label:IsA('TextLabel') then
                return nil
            end
            -- 这里按你的描述就是“一个数字”，直接 tonumber
            return tonumber(label.Text) or 0
        end

        -- 等待直到该数字 < 100；若 >=100 就每3秒再查一次
        local function waitFarm5Below100(maxMinutes)
            local deadline = os.clock() + (maxMinutes or 10) * 60 -- 最多等10分钟（可改）
            while os.clock() < deadline do
                local n = readFarm5Number()
                if n == nil then
                    warn('[农田5] 读取数字失败，3秒后重试')
                    task.wait(3)
                elseif n < 100 then
                    farmReady = true
                    print('[农田5] 数值 < 100，标记 farmReady = true')
                    checkAllTasksFinished()
                    return true
                else
                    -- 未小于100，3秒后再查
                    task.wait(3)
                end
            end
            warn('[农田5] 等待超时（超过上限仍 >=100）')
            return false
        end
        local AutoCollectherbs = features1:AddSwitch(
            'Auto Collect Herbs',
            function(bool)
                AutoCollectherbsbool = bool
                if AutoCollectherbsbool then
                    spawn(function()
                        while AutoCollectherbsbool do
                            for i = 1, 6 do
                                local args = { [1] = i, [2] = nil }
                                game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\133\172\231\148\168']['\229\134\156\231\148\176']['\233\135\135\233\155\134']
                                    :FireServer(unpack(args))
                                wait(0.1)
                            end

                            -- 🌿 一轮收集完成
                            herbCollectFinished = true
                            print(
                                '[系统] 草药收集一轮完成，检查农田 5 状态…'
                            )
                            openFarm5()
                            waitFarm5Below100()

                            wait(60) -- 等下一轮
                        end
                    end)
                end
            end
        )

        AutoCollectherbs:Set(true)
        features1:AddLabel(' - - Blessing Features - - ')
        local blessingOptions = ''
        local blessingOptionsDropdown = features1:AddDropdown(
            'Select Blessing',
            function(selected)
                if (selected == nil) then
                    return
                elseif (selected == 'Blessing Crafting Altar') then
                    blessingOptions = 'Blessing Crafting Altar'
                    print('Blessing Crafting Altar')
                elseif (selected == 'Blessing Elixir Furnace') then
                    blessingOptions = 'Blessing Elixir Furnace'
                    print('Blessing Elixir Furnace')
                elseif (selected == 'Blessing Summon') then
                    blessingOptions = 'Blessing Summon'
                    print('Blessing Summon')
                elseif (selected == 'Blessing Sword Statue') then
                    blessingOptions = 'Blessing Sword Statue'
                    print('Blessing Sword Statue')
                end
            end
        )
        blessingOptionsDropdown:Add('Blessing Crafting Altar')
        blessingOptionsDropdown:Add('Blessing Elixir Furnace')
        blessingOptionsDropdown:Add('Blessing Summon')
        blessingOptionsDropdown:Add('Blessing Sword Statue')
        local Blessing = features1:AddSwitch('Auto Blessing', function(bool)
            Blessingbool = bool
            if Blessingbool then
                local chaosVitality = game:GetService('Players').LocalPlayer.PlayerGui
                :WaitForChild('GUI')['\228\186\140\231\186\167\231\149\140\233\157\162']['\228\184\187\232\167\146']['\232\131\140\230\153\175']['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\176\143\231\187\191\231\147\182']['\229\189\162\232\177\161']['\232\180\167\229\184\129']['\232\180\167\229\184\129\230\149\176'].text
                local blessingNumber = 0
                if blessingOptions == 'Blessing Crafting Altar' then
                    blessingNumber = 1
                elseif blessingOptions == 'Blessing Elixir Furnace' then
                    blessingNumber = 2
                elseif blessingOptions == 'Blessing Summon' then
                    blessingNumber = 3
                elseif blessingOptions == 'Blessing Sword Statue' then
                    blessingNumber = 4
                end
                task.spawn(function()
                    while Blessingbool do
                        if tonumber(chaosVitality:match('^(%d+)')) >= 20 then

                            if blessingNumber == 0 then
                                print('No Blessing Selected')
                                task.wait(10)
                            else 
                                local args = {
                                    [1] = blessingNumber,
                                }
                                game:GetService('ReplicatedStorage')
                                :WaitForChild('\228\186\139\228\187\182')
                                :WaitForChild('\229\133\172\231\148\168')
                                :WaitForChild('\231\165\157\231\166\143')
                                :WaitForChild('\231\165\157\231\166\143')
                                :FireServer(unpack(args))
                            end
                        else
                            print('Chaos Vitality Not Enough')
                        end
                        task.wait(5)
                    end
                end)
            end
        end)
        Blessing:Set(false)
        features1:AddLabel(' - - Gamepass Unlock Features - - ')
        local Refining = features1:AddSwitch(
            'Unlock Auto Crafting (Gamepass)',
            function(bool)
                local Refiningbool = bool
                privileges:WaitForChild('超级炼制').Value = false
                privileges:WaitForChild('自动炼制').Value = Refiningbool
            end
        )
        Refining:Set(true)
        local showAll = features1:AddSwitch('Show All Currency', function(bool)
            ShowAllbool = bool
            if ShowAllbool then
                while ShowAllbool do
                    game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\230\180\187\229\138\168\231\137\169\229\147\129'].Visible =
                        true
                    game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\231\159\191\231\159\179'].Visible =
                        false
                    game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\231\172\166\231\159\179\231\178\137\230\156\171'].Visible =
                        true
                    game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\231\173\137\231\186\167'].Visible =
                        true
                    game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\231\180\171\233\146\187'].Visible =
                        true
                    game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\232\141\137\232\141\175'].Visible =
                        false
                    game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\233\135\145\229\184\129'].Visible =
                        true
                    game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\233\146\187\231\159\179'].Visible =
                        true
                    wait(0.3)
                end
            end
        end)
        showAll:Set(false)
        -- 方案一：函数复用模式（推荐）
        local function RemoveRewardUI()
            local rewardUI = playerGui.GUI:WaitForChild('二级界面')

            -- 定义需要删除的子对象名称
            local rewardUINames = {
                '展示奖励界面',
                '离线奖励',
                '版本说明',
                '7日奖励',
            }
            local success = false

            -- 遍历所有需要删除的子对象
            for _, name in ipairs(rewardUINames) do
                local child = rewardUI:FindFirstChild(name)
                if child then
                    child:Destroy()
                    print('成功删除: ' .. name)
                    success = true
                else
                    print('未找到: ' .. name)
                end
            end

            -- 返回是否成功删除了至少一个子对象
            return success
        end

        -- 创建按钮并立即执行
        features1:AddButton('Remove Display of The Rewards', function()
            RemoveRewardUI()
        end)

        -- 启动时延迟执行
        task.defer(function()
            RemoveRewardUI()
        end)
        features1:AddButton('Redeem Game Code', function()
            local gamecode = {
                'ilovethisgame',
                'welcome',
                '30klikes',
                '40klikes',
                'halloween',
                'artistkapouki',
                '45klikes',
                '60klikes',
            }
            for i = 1, #gamecode do
                print(gamecode[i])
                local args = { [1] = gamecode[i] }
                game:GetService('ReplicatedStorage')
                    :FindFirstChild('\228\186\139\228\187\182')
                    :FindFirstChild('\229\133\172\231\148\168')
                    :FindFirstChild('\230\191\128\230\180\187\231\160\129')
                    :FindFirstChild(
                        '\231\142\169\229\174\182\229\133\145\230\141\162\230\191\128\230\180\187\231\160\129'
                    )
                    :FireServer(unpack(args))
            end
        end)
    end
    local function setupFeatures2Tab(features2)
        local worldnum = player
            :WaitForChild('值')
            :WaitForChild('主线进度')
            :WaitForChild('world').Value
        local newworldnum = worldnum
        local function statisticsupdata()
            worldnum = player
                :WaitForChild('值')
                :WaitForChild('主线进度')
                :WaitForChild('world').Value
        end
        spawn(function()
            while true do
                statisticsupdata()
                wait(1)
            end
        end)
        local Difficulty_choose =
            features2:AddLabel('  Current Selection ： 01') -- 初始化顯示為70
        local function gowordlevelscheak(gowordlevels)
            if gowordlevels > worldnum then
                if gowordlevels < 10 then
                    Difficulty_choose.Text = '  Stage Locked： 0'
                        .. gowordlevels
                else
                    Difficulty_choose.Text = '  Stage Locked： '
                        .. gowordlevels
                end
            elseif gowordlevels < 10 then
                Difficulty_choose.Text = '  Current Selection： 0'
                    .. gowordlevels
            else
                Difficulty_choose.Text = '  Current Selection： '
                    .. gowordlevels
            end
        end
        local Difficulty_selection = features2:AddDropdown(
            '                Stage Difficulty Selection                ',
            function(text)
                if text == '      World Stage Easy: 01       ' then
                    print('Current Selection: Easy')
                    gowordlevels = 1
                    Difficulty_choose.Text = '  Current Selection: 01'
                elseif text == '      World Stage Normal: 21       ' then
                    print('Current Selection: Normal')
                    gowordlevels = 21
                    gowordlevelscheak(gowordlevels)
                elseif text == '      World Stage Hard: 41       ' then
                    print('Current Selection: Hard')
                    gowordlevels = 41
                    gowordlevelscheak(gowordlevels)
                elseif text == '      World Stage Expert: 61       ' then
                    print('Current Selection: Expert')
                    gowordlevels = 61
                    gowordlevelscheak(gowordlevels)
                elseif text == '      World Stage Master: 81       ' then
                    print('Current Selection: Master')
                    gowordlevels = 81
                    gowordlevelscheak(gowordlevels)
                elseif text == '      World Stage Hell: 101       ' then
                    print('Current Selection: Hell')
                    gowordlevels = 101
                    gowordlevelscheak(gowordlevels)
                elseif text == '      Current Selection: Auto Max Stage        ' then
                    local showone = false
                    print('Current Selection: Auto Max Stage')
                    if worldnum < 10 then
                        Difficulty_choose.Text = '  Current Selection Max Stage: 0'
                            .. worldnum
                    else
                        Difficulty_choose.Text = '  Current Selection Max Stage: '
                            .. worldnum
                    end
                    gowordlevels = worldnum
                    while true do
                        local Difficulty_choose_Text = string.match(
                            Difficulty_choose.Text,
                            'Current Selection Max Stage'
                        )
                        if
                            Difficulty_choose_Text ~= 'Current Selection Max Stage'
                        then
                            showone = false
                            print('Auto max stage stopped')
                            break
                        elseif not showone then
                            print('Auto max stage started')
                            showone = true
                        end
                        if newworldnum ~= worldnum then
                            gowordlevels = worldnum
                            newworldnum = worldnum
                            finishworldnum = tonumber(gowordlevels)
                            if worldnum < 10 then
                                Difficulty_choose.Text = '  Current Selection Max Stage: 0'
                                    .. gowordlevels
                            else
                                Difficulty_choose.Text = '  Current Selection Max Stage: '
                                    .. gowordlevels
                            end
                            wait(savemodetime2)
                            wait(savemodetime + 1)
                            local args = { [1] = finishworldnum }
                            game:GetService('ReplicatedStorage')
                                :FindFirstChild('\228\186\139\228\187\182')
                                :FindFirstChild('\229\133\172\231\148\168')
                                :FindFirstChild('\229\133\179\229\141\161')
                                :FindFirstChild(
                                    '\232\191\155\229\133\165\228\184\150\231\149\140\229\133\179\229\141\161'
                                )
                                :FireServer(unpack(args))
                        end
                        wait(1)
                    end
                end
            end
        )
        local Levels1 =
            Difficulty_selection:Add('      World Stage Easy: 01       ')
        local Levels2 =
            Difficulty_selection:Add('      World Stage Normal: 21       ')
        local Levels3 =
            Difficulty_selection:Add('      World Stage Hard: 41       ')
        local Levels4 =
            Difficulty_selection:Add('      World Stage Expert: 61       ')
        local Levels5 =
            Difficulty_selection:Add('      World Stage Master: 81       ')
        local Levels6 =
            Difficulty_selection:Add('      World Stage Hell: 101       ')
        local Levels99 =
            Difficulty_selection:Add('      Current Selection: Auto Max Stage        ')
        local Levels999 = Difficulty_selection:Add('空白')
        features2:AddButton('World Level +1', function()
            gowordlevels = gowordlevels + 1
            gowordlevelscheak(gowordlevels)
        end)
        features2:AddButton('World Level -1', function()
            gowordlevels = gowordlevels - 1
            gowordlevelscheak(gowordlevels)
        end)
        local combatUI = playerGui.GUI
            :WaitForChild('主界面')
            :WaitForChild('战斗')
            :waitForChild('关卡信息')
            :waitForChild('文本')
        local function teleporttworld1()
            local args = { [1] = gowordlevels }
            game:GetService('ReplicatedStorage')
                :FindFirstChild('\228\186\139\228\187\182')
                :FindFirstChild('\229\133\172\231\148\168')
                :FindFirstChild('\229\133\179\229\141\161')
                :FindFirstChild(
                    '\232\191\155\229\133\165\228\184\150\231\149\140\229\133\179\229\141\161'
                )
                :FireServer(unpack(args))
            print('傳送世界關卡：' .. gowordlevels)
        end
        local function teleporttworld2()
            finishworldnum = tonumber(gowordlevels)
            local args = { [1] = finishworldnum }

            -- 保留原始转义路径
            local remStorage = game:GetService('ReplicatedStorage')
            local targetEvent = remStorage
                :FindFirstChild('\228\186\139\228\187\182')
                :FindFirstChild('\229\133\172\231\148\168')
                :FindFirstChild('\229\133\179\229\141\161')
                :FindFirstChild(
                    '\232\191\155\229\133\165\228\184\150\231\149\140\229\133\179\229\141\161'
                )

            if targetEvent then
                pcall(function()
                    targetEvent:FireServer(unpack(args))
                end)
            end
        end

        local function CheckRestart()
            local success, result = pcall(function()
                return playerGui.GUI
                    :WaitForChild('主界面')
                    :WaitForChild('战斗')
                    :WaitForChild('胜利结果').Text
            end)

            return success and result == 'Victory'
        end
        function teleporthome()
            player.Character:WaitForChild('HumanoidRootPart').CFrame =
                CFrame.new(TPX, TPY, TPZ)
        end
        features2:AddButton('TP', function()
            teleporttworld1()
        end)
        local EndlessBattle = features2:AddSwitch('Endless Wave for Stage 75', function(bool)

            local AutoReenter = false
            local AutoReenterThread

            if bool then
                AutoReenter = true
                AutoReenterThread = coroutine.create(function()

                    while AutoReenter do
                        local text = combatUI.Text
                        local progress = text:match("-(%d+)%/")
                        if progress then
                            local num = tonumber(progress)
                            if num and num >= 75 then
                                teleporttworld1()
                                task.wait(1)
                            end
                        end
                        task.wait(1)
                    end
                end)
                coroutine.resume(AutoReenterThread)
            else
                AutoReenter = false
                if AutoReenterThread then
                    coroutine.close(AutoReenterThread)
                end
            end
        end, true)

        local Autostart = features2:AddSwitch(
            'Auto Start After Battle (World Battle)',
            function(bool)
                if bool then
                    -- 关闭现有线程
                    if Autostartwarld and AutostartThread then
                        coroutine.close(AutostartThread)
                    end

                    Autostartwarld = true
                    AutostartThread = coroutine.create(function()
                        while Autostartwarld do
                            -- 双重状态检查
                            if not Autostartwarld then
                                break
                            end

                            local isVictory = CheckRestart()

                            if isVictory then
                                local char = player.Character
                                if
                                    char
                                    and char:FindFirstChild('HumanoidRootPart')
                                then
                                    local hrp = char.HumanoidRootPart
                                    hrp.CFrame = CFrame.new(TPX, TPY, TPZ)
                                    teleporttworld2()

                                    -- 分段等待便于中断
                                    for i = 1, 10 do
                                        if not Autostartwarld then
                                            break
                                        end
                                        wait(0.5)
                                    end
                                end
                            else
                                local char = player.Character
                                if
                                    char
                                    and char:FindFirstChild('HumanoidRootPart')
                                then
                                    local hrp = char.HumanoidRootPart
                                    if
                                        (hrp.Position - Vector3.new(
                                            TPX,
                                            TPY,
                                            TPZ
                                        )).Magnitude
                                        < 2.5
                                    then
                                        teleporttworld2()
                                    end
                                end
                            end

                            -- 每次循环前检查
                            if not Autostartwarld then
                                break
                            end
                            wait(0.3)
                        end
                        Autostartwarld = false -- 确保状态同步
                    end)

                    coroutine.resume(AutostartThread)
                else
                    -- 安全关闭线程
                    Autostartwarld = false
                    if AutostartThread then
                        coroutine.close(AutostartThread)
                        AutostartThread = nil
                    end
                end
            end
        )

        Autostart:Set(true)
        local AFKmode = game:GetService('Players').LocalPlayer
                :WaitForChild('值')
                :WaitForChild('设置')
                :WaitForChild('自动战斗')
        AFKmode.Value = true
        features2:AddButton('AFK Mode', function()
            local AFKmod = game:GetService('Players').LocalPlayer
                :WaitForChild('值')
                :WaitForChild('设置')
                :WaitForChild('自动战斗')
            if AFKmod.Value == true then
                AFKmod.Value = false
            else
                AFKmod.Value = true
            end
        end)
    end
    setupFeaturesTab(features)
    setupFeatures1Tab(features1)
    setupFeatures2Tab(features2)
    local httpService = game:GetService('HttpService')
    local player = game.Players.LocalPlayer
    local filePath = 'DungeonsMaxLevel.json'
    local updDungeonui = false
    local AutoDungeonplus1 = false
    local Notexecuted = true
    local AutoDungeonplusonly = false
    local Autofinishdungeon = false
    local dungeonFunctions = {}
    local function extractLocalPlayerData()
        if not isfile(filePath) then
            error('JSON 文件不存在：' .. filePath)
        end
        local fileContent = readfile(filePath)
        local success, data =
            pcall(httpService.JSONDecode, httpService, fileContent)
        if not success then
            error('無法解析 JSON 文件：' .. filePath)
        end
        local localPlayerName = player.Name
        local localPlayerData = data[localPlayerName]
        if not localPlayerData then
            error(
                'LocalPlayer 的資料不存在於 JSON 文件中：'
                    .. localPlayerName
            )
        end
        return localPlayerData
    end
    local function saveDungeonFunctions(playerData)
        for dungeonName, maxLevel in pairs(playerData) do
            local functionName = dungeonName:gsub('MaxLevel', '')
            dungeonFunctions[functionName] = function()
                return maxLevel
            end
        end
    end
    local function updateDungeonFunctions()
        local playerData = JsonHandler.getPlayerData(filePath, player.Name)
        dungeonFunctions = {}
        saveDungeonFunctions(playerData)
    end
    local function main()
        local success, playerData = pcall(extractLocalPlayerData)
        if success then
            saveDungeonFunctions(playerData)
            print('Dungeon 函數已成功創建')
        else
            warn('提取資料失敗：' .. tostring(playerData))
        end
    end
    main()
    spawn(function()
        while true do
            if updDungeonui then
                local dungeonChoice = playerGui
                    :WaitForChild('GUI')
                    :WaitForChild('二级界面')
                    :WaitForChild('关卡选择')
                    :WaitForChild('副本选择弹出框')
                    :WaitForChild('背景')
                    :WaitForChild('标题')
                    :WaitForChild('名称').Text
                local dungeonMaxLevel = tonumber(
                    playerGui
                        :WaitForChild('GUI')
                        :WaitForChild('二级界面')
                        :WaitForChild('关卡选择')
                        :WaitForChild('副本选择弹出框')
                        :WaitForChild('背景')
                        :WaitForChild('难度')
                        :WaitForChild('难度等级')
                        :WaitForChild('值').Text
                )
                JsonHandler.updateDungeonMaxLevel(
                    filePath,
                    player.Name,
                    dungeonChoice,
                    dungeonMaxLevel
                )
                updateDungeonFunctions()
            end
            wait(1)
        end
    end)
    local playerData = JsonHandler.getPlayerData(filePath, player.Name)
    print('玩家初始資料:')
    for key, value in pairs(playerData) do
        print(key, value)
    end
    local Dungeonslist = playerGui
        :WaitForChild('GUI')
        :WaitForChild('二级界面')
        :WaitForChild('关卡选择')
        :WaitForChild('背景')
        :WaitForChild('右侧界面')
        :WaitForChild('副本')
        :WaitForChild('列表')
    local dropdownchoose = 0
    local dropdownchoose2 = '1'
    local dropdownchoose3 = 0
    local function getDungeonKey(dungeonName)
        local dungeon = Dungeonslist:FindFirstChild(dungeonName)
        if dungeon then
            local keyText =
                dungeon:WaitForChild('钥匙'):WaitForChild('值').Text
            local key = tonumber(string.match(keyText, '^%d+'))
            if key then
                return ((key < 10) and string.format('0%d', key))
                    or tostring(key)
            end
        end
        return nil
    end
    local function checkDungeonkey()
        Ore_Dungeonkey = getDungeonKey('OreDungeon')
        Gem_Dungeonkey = getDungeonKey('GemDungeon')
        Gold_Dungeonkey = getDungeonKey('GoldDungeon')
        Relic_Dungeonkey = getDungeonKey('RelicDungeon')
        Rune_Dungeonkey = getDungeonKey('RuneDungeon')
        Hover_Dungeonkey = getDungeonKey('HoverDungeon')
    end
    checkDungeonkey()
    local chooselevels = features3:AddLabel('Select a Dungeon...')
    local dropdown1 = features3:AddDropdown('Select a Dungeon', function(text)
        if text == '            Ore Dungeon            ' then
            dropdownchoose = 1
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['OreDungeon']
                    and dungeonFunctions['OreDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Ore Dungeon,  Keys Left：'
                .. Ore_Dungeonkey
                .. '  ,Difficult：'
                .. dropdownchoose2
        elseif text == '            Gems Dungeon            ' then
            dropdownchoose = 2
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['GemDungeon']
                    and dungeonFunctions['GemDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Gems Dungeon,  Keys Left：'
                .. Gem_Dungeonkey
                .. '  ,Difficult：'
                .. dropdownchoose2
        elseif text == '            Rune Dungeon            ' then
            dropdownchoose = 3
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['RuneDungeon']
                    and dungeonFunctions['RuneDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Rune Dungeon,  Keys Left：'
                .. Rune_Dungeonkey
                .. '  ,Difficult：'
                .. dropdownchoose2
        elseif text == '            Relic Dungeon            ' then
            dropdownchoose = 4
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['RelicDungeon']
                    and dungeonFunctions['RelicDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Relic Dungeon,  Keys Left：'
                .. Relic_Dungeonkey
                .. '  ,Difficult：'
                .. dropdownchoose2
        elseif text == '            Hover Dungeon            ' then
            dropdownchoose = 7
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['HoverDungeon']
                    and dungeonFunctions['HoverDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Hover Dungeon,  Keys Left：'
                .. Hover_Dungeonkey
                .. '  ,Difficult：'
                .. dropdownchoose2
        elseif text == '            Gold Dungeon            ' then
            dropdownchoose = 6
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['GoldDungeon']
                    and dungeonFunctions['GoldDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Gold Dungeon,  Keys Left：'
                .. Gold_Dungeonkey
                .. '  ,Difficult：'
                .. dropdownchoose2
        elseif text == '            Event Dungeon (Coming Soon)            ' then
            dropdownchoose = 5
            dropdownchoose2 = 'Not Available'
            chooselevels.Text = 'Currently Selected：Event Dungeon (Coming Soon)            '
        else
            dropdownchoose = 8
            chooselevels.Text = 'None'
        end
    end)
    local Dungeon1 = dropdown1:Add('            Ore Dungeon            ')
    local Dungeon2 = dropdown1:Add('            Gems Dungeon            ')
    local Dungeon3 = dropdown1:Add('            Rune Dungeon            ')
    local Dungeon4 = dropdown1:Add('            Relic Dungeon            ')
    local Dungeon5 = dropdown1:Add('            Hover Dungeon            ')
    local Dungeon6 = dropdown1:Add('            Gold Dungeon            ')
    local Dungeon7 =
        dropdown1:Add('            活動地下城   未開啟            ')
    local Dungeon8 = dropdown1:Add(
        '            None            '
    )
    local function UDPDungeontext()
        if dropdownchoose == 0 then
            chooselevels.Text = 'Select a Dungeon'
        elseif dropdownchoose == 1 then
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['OreDungeon']
                    and dungeonFunctions['OreDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Ore Dungeon,  Keys Left：'
                .. Ore_Dungeonkey
                .. '  ,Difficulty：'
                .. dropdownchoose2
        elseif dropdownchoose == 2 then
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['GemDungeon']
                    and dungeonFunctions['GemDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Gems Dungeon,  Keys Left：'
                .. Gem_Dungeonkey
                .. '  ,Difficulty：'
                .. dropdownchoose2
        elseif dropdownchoose == 3 then
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['RuneDungeon']
                    and dungeonFunctions['RuneDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Rune Dungeon,  Keys Left：'
                .. Rune_Dungeonkey
                .. '  ,Difficulty：'
                .. dropdownchoose2
        elseif dropdownchoose == 4 then
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['RelicDungeon']
                    and dungeonFunctions['RelicDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Relic Dungeon,  Keys Left：'
                .. Relic_Dungeonkey
                .. '  ,Difficulty：'
                .. dropdownchoose2
        elseif dropdownchoose == 7 then
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['HoverDungeon']
                    and dungeonFunctions['HoverDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Hover Dungeon,  Keys Left：'
                .. Hover_Dungeonkey
                .. '  ,Difficulty：'
                .. dropdownchoose2
        elseif dropdownchoose == 6 then
            dropdownchoose2 = tostring(
                (
                    dungeonFunctions['GoldDungeon']
                    and dungeonFunctions['GoldDungeon']()
                ) or '0'
            )
            chooselevels.Text = 'Currently Selected：Gold Dungeon,  Keys Left：'
                .. Gold_Dungeonkey
                .. '  ,Difficulty：'
                .. dropdownchoose2
        elseif dropdownchoose == 5 then
            chooselevels.Text = 'Currently Selected：Event Dungeon (Coming Soon)'
        elseif dropdownchoose == 8 then
            chooselevels.Text = 'This is a placeholder with no effect'
        end
    end
    local function UDPDungeonchoose()
        checkDungeonkey()
        Dungeon1.Text = '            Ore Dungeon   Keys Left：'
            .. Ore_Dungeonkey
            .. '            '
        Dungeon2.Text = '            Gems Dungeon   Keys Left：'
            .. Gem_Dungeonkey
            .. '            '
        Dungeon3.Text = '            Rune Dungeon   Keys Left：'
            .. Rune_Dungeonkey
            .. '            '
        Dungeon4.Text = '            Relic Dungeon   Keys Left：'
            .. Relic_Dungeonkey
            .. '            '
        Dungeon5.Text = '            Hover Dungeon   Keys Left：'
            .. Hover_Dungeonkey
            .. '            '
        Dungeon6.Text = '            Gold Dungeon   Keys Left：'
            .. Gold_Dungeonkey
            .. '            '
        Dungeon7.Text = '            Event Dungeon   Coming Soon            '
    end
    spawn(function()
        while true do
            UDPDungeonchoose()
            UDPDungeontext()
            wait(0.5)
        end
    end)
    local updDungeonuiSwitch = features3:AddSwitch(
        'Sync Dungeon',
        function(bool)
            updDungeonui = bool
        end
    )
    updDungeonuiSwitch:Set(false)
    local function updateDungeonLevel(dungeonName, dataField, newLevel)
        JsonHandler.updatePlayerData(
            filePath,
            player.Name,
            { [dataField] = newLevel }
        )
        updateDungeonFunctions()
        print(
            '更新後的 ' .. dungeonName .. ' 等級:',
            dungeonFunctions[dungeonName]()
        )
    end
    local function adjustDungeonLevel(adjustment)
        local newLevel = dropdownchoose2 + adjustment
        local dungeonMapping = {
            [1] = { name = 'OreDungeon', field = 'OreDungeonMaxLevel' },
            [2] = { name = 'GemDungeon', field = 'GemDungeonMaxLevel' },
            [3] = { name = 'RuneDungeon', field = 'RuneDungeonMaxLevel' },
            [4] = { name = 'RelicDungeon', field = 'RelicDungeonMaxLevel' },
            [7] = { name = 'HoverDungeon', field = 'HoverDungeonMaxLevel' },
            [6] = { name = 'GoldDungeon', field = 'GoldDungeonMaxLevel' },
        }
        local dungeon = dungeonMapping[dropdownchoose]
        if dungeon then
            updateDungeonLevel(dungeon.name, dungeon.field, newLevel)
        else
            print('未選擇地下城')
        end
    end
    local function DungeonTP()
        local dropdownTP = tonumber(dropdownchoose2)
        local args = { [1] = dropdownchoose, [2] = dropdownTP }
        game:GetService('ReplicatedStorage')
            :FindFirstChild('\228\186\139\228\187\182')
            :FindFirstChild('\229\133\172\231\148\168')
            :FindFirstChild('\229\137\175\230\156\172')
            :FindFirstChild('\232\191\155\229\133\165\229\137\175\230\156\172')
            :FireServer(unpack(args))
    end
    local dungeonList = {
        'Ore Dungeon',
        'Gem Dungeon',
        'Rune Dungeon',
        'Relic Dungeon',
        'Hover Dungeon',
        'Gold Dungeon',
    }
    local dungeonKeys = {
        ['Ore Dungeon'] = 'OreDungeon',
        ['Gem Dungeon'] = 'GemDungeon',
        ['Rune Dungeon'] = 'RuneDungeon',
        ['Relic Dungeon'] = 'RelicDungeon',
        ['Hover Dungeon'] = 'HoverDungeon',
        ['Gold Dungeon'] = 'GoldDungeon',
    }
    local function getDungeonWithMostKeys()
        local maxKeys = 0
        local bestDungeon = nil
        local bestDropdownIndex = 1
        local dropdownMapping = { 1, 2, 3, 4, 7, 6 }
        for i, name in ipairs(dungeonList) do
            local keyCount = tonumber(getDungeonKey(dungeonKeys[name])) or 0
            if keyCount > maxKeys then
                maxKeys = keyCount
                bestDungeon = name
                bestDropdownIndex = dropdownMapping[i] or 0
            end
        end
        return bestDungeon, bestDropdownIndex
    end
    local function selectDungeonWithMostKeys()
        local bestDungeon, bestDropdownIndex = getDungeonWithMostKeys()
        dropdownchoose = bestDropdownIndex
        local dungeonName = bestDungeon
        local dungeonLevel =
            tostring(dungeonFunctions[dungeonKeys[dungeonName]]() or '0')
        print('已選擇最多鑰匙的地下城：' .. dungeonName)
        wait(0.4)
        DungeonTP()
    end
    local function CheckDungeonVictory()
        local success, result = pcall(function()
            local victoryUI = playerGui.GUI
                :WaitForChild('主界面')
                :WaitForChild('战斗')
                :WaitForChild('胜利结果')
            return victoryUI.Visible and victoryUI.Text == 'Victory'
        end)
        return success and result
    end

    local function ClearVictoryUI()
        pcall(function()
            playerGui.GUI
                :WaitForChild('主界面')
                :WaitForChild('战斗')
                :WaitForChild('胜利结果').Text =
                ''
        end)
    end

    -- 检测是否在复活点
    local function IsAtRespawnPoint()
        local char = player.Character
        if char and char:FindFirstChild('HumanoidRootPart') then
            local hrp = char.HumanoidRootPart
            local distance = (hrp.Position - Vector3.new(TPX, TPY, TPZ)).Magnitude
            return distance < 5 -- 5 格以内算到达复活点
        end
        return false
    end

    local function AutostartDungeonf()
        -- Phase 1: 检查胜利
        local victoryFound = false
        local waitStart = os.time()
        while not victoryFound and (os.time() - waitStart < 30) do
            victoryFound = CheckDungeonVictory()
            if not victoryFound then
                -- 新增：检查是否在复活点
                if IsAtRespawnPoint() then
                    print('检测到回到复活点，自动开始地下城')
                    DungeonTP()
                    return true
                end
                wait(0.5)
            end
        end

        -- Phase 2: 胜利逻辑（原有）
        if victoryFound then
            local currentKeys = 0
            local dungeonName = 'Unknown'
            pcall(function()
                local levelText = playerGui.GUI
                    :WaitForChild('主界面')
                    :WaitForChild('战斗')
                    :WaitForChild('关卡信息')
                    :WaitForChild('文本').Text
                dungeonName = string.match(levelText, '^(.-)%s%d') or 'Unknown'
                local keyType = ({
                    ['Ore Dungeon'] = 'OreDungeon',
                    ['Gem Dungeon'] = 'GemDungeon',
                    ['Rune Dungeon'] = 'RuneDungeon',
                    ['Relic Dungeon'] = 'RelicDungeon',
                    ['Hover Dungeon'] = 'HoverDungeon',
                    ['Gold Dungeon'] = 'GoldDungeon',
                })[dungeonName]
                if keyType then
                    currentKeys = tonumber(getDungeonKey(keyType)) or 0
                end
            end)

            if AutoDungeonplus1 then
                adjustDungeonLevel(1)
                wait(1)
            end

            ClearVictoryUI()
            wait(savemodetime2)
            teleporthome()
            wait(0.5)

            if Autofinishdungeon and currentKeys == 0 then
                print('自动切换到钥匙最多的地下城')
                selectDungeonWithMostKeys()
            else
                DungeonTP()
            end
        end
    end

    local AutostartDungeonSwitch = features3:AddSwitch(
        'Auto Start After Battle (Dungeon)',
        function(bool)
            AutostartDungeon = bool
            if AutostartDungeon then
                spawn(function()
                    while AutostartDungeon do
                        local actionTaken = AutostartDungeonf()
                        -- Only wait longer if no action was taken
                        wait(actionTaken and 0.1 or 0.5)
                    end
                end)
            end
        end
    )
    AutostartDungeonSwitch:Set(false)

    local AutoDungeonplus1Switch = features3:AddSwitch(
        'Auto Dungeon Level +1 After Victory',
        function(bool)
            AutoDungeonplus1 = bool
        end
    )
    AutoDungeonplus1Switch:Set(false)
    local AutofinishdungeonSwitch = features3:AddSwitch(
        'Automatically Switch Dungeon When Out of Keys --Test',
        function(bool)
            Autofinishdungeon = bool
        end
    )
    AutofinishdungeonSwitch:Set(false)
    features3:AddTextBox('You Can Enter Dungeon Level:', function(text)
        local dropdownchoose0 = string.gsub(text, '[^%d]', '')
        local dropdownchoose3 = tonumber(dropdownchoose0)
        if not dropdownchoose3 then
            dropdownchoose3 = 1
        end
        if dropdownchoose == 1 then
            local field = 'OreDungeonMaxLevel'
            JsonHandler.updateField(
                filePath,
                player.Name,
                field,
                dropdownchoose3
            )
            updateDungeonFunctions()
        elseif dropdownchoose == 2 then
            local field = 'GemDungeonMaxLevel'
            JsonHandler.updateField(
                filePath,
                player.Name,
                field,
                dropdownchoose3
            )
            updateDungeonFunctions()
        elseif dropdownchoose == 3 then
            local field = 'RuneDungeonMaxLevel'
            JsonHandler.updateField(
                filePath,
                player.Name,
                field,
                dropdownchoose3
            )
            updateDungeonFunctions()
        elseif dropdownchoose == 4 then
            local field = 'RelicDungeonMaxLevel'
            JsonHandler.updateField(
                filePath,
                player.Name,
                field,
                dropdownchoose3
            )
            updateDungeonFunctions()
        elseif dropdownchoose == 5 then
            local field = 'HoverDungeonMaxLevel'
            JsonHandler.updateField(
                filePath,
                player.Name,
                field,
                dropdownchoose3
            )
            updateDungeonFunctions()
        elseif dropdownchoose == 6 then
            local field = 'GoldDungeonMaxLevel'
            JsonHandler.updateField(
                filePath,
                player.Name,
                field,
                dropdownchoose3
            )
            updateDungeonFunctions()
        else
            print('未選擇地下城')
        end
    end)
    features3:AddButton('Difficult +1', function()
        adjustDungeonLevel(1)
    end)
    features3:AddButton('Difficult -1', function()
        adjustDungeonLevel(-1)
    end)
    features3:AddButton('TP', function()
        DungeonTP()
    end)
    features4:AddButton('Auto Trade', function()
        loadstring(
            game:HttpGet(
                'https://github.com/supleruckydior/test/raw/refs/heads/main/%E8%87%AA%E5%8A%A8%E4%BA%A4%E6%98%931.json'
            )
        )()
    end)
    features4:AddButton('Auto Trade v2', function()
        loadstring(
            game:HttpGet(
                'https://github.com/supleruckydior/test/raw/refs/heads/main/%E8%87%AA%E5%8A%A8%E4%BA%A4%E6%98%932.json'
            )
        )()
    end)
    AutoelixirSwitch = features4:AddSwitch('Auto Elixir', function(bool)
        Autoelixir = bool
        if Autoelixir then
            while Autoelixir do
                game:GetService('ReplicatedStorage')
                    :FindFirstChild('\228\186\139\228\187\182')
                    :FindFirstChild('\229\133\172\231\148\168')
                    :FindFirstChild('\231\130\188\228\184\185')
                    :FindFirstChild('\229\136\182\228\189\156')
                    :FireServer()
                wait(0.5)
            end
        end
    end)
    features4:AddButton('TP to Altar', function()
        local RespawPointnum = RespawPoint:match('%d+') -- 获取重生点编号
        local player = game.Players.LocalPlayer
        local character = player.Character

        if not character then
            player.CharacterAdded:Wait()
            character = player.Character
        end

        local humanoidRootPart = character:WaitForChild('HumanoidRootPart')
        local forgePath =
            workspace['\228\184\187\229\160\180\230\153\175' .. RespawPointnum]['\229\187\186\233\128\160\231\137\169']['035\231\130\188\229\153\168\229\143\176']

        if forgePath then
            humanoidRootPart.CFrame = forgePath:GetPivot()
        end
    end)

    local playerGui = game.Players.LocalPlayer.PlayerGui
    local lotteryskill = playerGui.GUI
        :WaitForChild('二级界面')
        :WaitForChild('商店')
        :WaitForChild('背景')
        :WaitForChild('右侧界面')
        :WaitForChild('召唤')
        :WaitForChild('技能')
    local skilllevel =
        lotteryskill:WaitForChild('等级区域'):WaitForChild('值').text
    skilllevel = string.gsub(skilllevel, '%D', '')
    local skilllevel2 = lotteryskill
        :WaitForChild('等级区域')
        :WaitForChild('进度条')
        :WaitForChild('值')
        :WaitForChild('值').text
    skilllevel2 = string.match(skilllevel2, '(%d+)/')
    local lotteryweapon = playerGui.GUI
        :WaitForChild('二级界面')
        :WaitForChild('商店')
        :WaitForChild('背景')
        :WaitForChild('右侧界面')
        :WaitForChild('召唤')
        :WaitForChild('法宝')
    local weaponlevel =
        lotteryweapon:WaitForChild('等级区域'):WaitForChild('值').text
    weaponlevel = string.gsub(weaponlevel, '%D', '')
    local weaponlevel2 = lotteryweapon
        :WaitForChild('等级区域')
        :WaitForChild('进度条')
        :WaitForChild('值')
        :WaitForChild('值').text
    weaponlevel2 = string.match(weaponlevel2, '(%d+)/')
    local currency = player:WaitForChild('值'):WaitForChild('货币')
    local diamonds = currency:WaitForChild('钻石').value
    local sword_tickets = currency:WaitForChild('法宝抽奖券').value
    local skill_tickets = currency:WaitForChild('技能抽奖券').value
    local useDiamonds = false
    local Autolotteryspeed = 0.3
    local canstartticket = true
    local canstartticket2 = true
    local function fetchData()
        skilllevel =
            lotteryskill:WaitForChild('等级区域'):WaitForChild('值').text
        skilllevel2 = lotteryskill
            :WaitForChild('等级区域')
            :WaitForChild('进度条')
            :WaitForChild('值')
            :WaitForChild('值').text
        weaponlevel =
            lotteryweapon:WaitForChild('等级区域'):WaitForChild('值').text
        weaponlevel2 = lotteryweapon
            :WaitForChild('等级区域')
            :WaitForChild('进度条')
            :WaitForChild('值')
            :WaitForChild('值').text
        sword_tickets = currency:WaitForChild('法宝抽奖券').value
        skill_tickets = currency:WaitForChild('技能抽奖券').value
        diamonds = currency:WaitForChild('钻石').value
    end
    local function updData()
        fetchData()
        skilllevel = tonumber(string.match(skilllevel, '%d+'))
        skilllevel2 = tonumber(string.match(skilllevel2, '(%d+)/'))
        weaponlevel = tonumber(string.match(weaponlevel, '%d+'))
        weaponlevel2 = tonumber(string.match(weaponlevel2, '(%d+)/'))
    end
    local function useskill_ticket()
        if canstartticket then
            local args = { [1] = '\230\138\128\232\131\189', [2] = true }
            game:GetService('ReplicatedStorage')
                :FindFirstChild('\228\186\139\228\187\182')
                :FindFirstChild('\229\133\172\231\148\168')
                :FindFirstChild('\229\149\134\229\186\151')
                :FindFirstChild('\229\143\172\229\148\164')
                :FindFirstChild('\230\138\189\229\165\150')
                :FireServer(unpack(args))
        end
    end
    local function usesword_ticket()
        if canstartticket2 then
            local args = { [1] = '\230\179\149\229\174\157', [2] = true }
            game:GetService('ReplicatedStorage')
                :FindFirstChild('\228\186\139\228\187\182')
                :FindFirstChild('\229\133\172\231\148\168')
                :FindFirstChild('\229\149\134\229\186\151')
                :FindFirstChild('\229\143\172\229\148\164')
                :FindFirstChild('\230\138\189\229\165\150')
                :FireServer(unpack(args))
        end
    end
    local function Compareskilltickets()
        if skill_tickets < 8 then
            if useDiamonds and (diamonds >= ((8 - skill_tickets) * 50)) then
                local compare = 8 - skill_tickets
                useskill_ticket()
            else
            end
        else
            useskill_ticket()
        end
    end
    local function Compareweapentickets()
        if sword_tickets < 8 then
            if useDiamonds and (diamonds >= ((8 - sword_tickets) * 50)) then
                local compare = 8 - sword_tickets
                usesword_ticket()
            else
            end
        else
            usesword_ticket()
        end
    end
    local function Compareprogress()
        if skilllevel2 > weaponlevel2 then
            Compareweapentickets()
        elseif skilllevel2 < weaponlevel2 then
            Compareskilltickets()
        else
            Compareskilltickets()
            Compareweapentickets()
        end
    end
    local function Comparelevel()
        updData()
        if skilllevel > weaponlevel then
            Compareweapentickets()
        elseif skilllevel < weaponlevel then
            Compareskilltickets()
        else
            Compareprogress()
        end
    end
    features4:AddLabel(
        '⚠️ Auto draw: will stop if tickets are insufficient. Please enable diamond draws'
    )
    local lotterynum = features4:AddLabel(
        'Sword Ticket： '
            .. sword_tickets
            .. '    Skill Ticket： '
            .. skill_tickets
    )
    local function updateExtractedValues()
        local sword_ticketslable =
            currency:WaitForChild('法宝抽奖券').value
        local skill_ticketslable =
            currency:WaitForChild('技能抽奖券').value
        lotterynum.Text = 'Sword Ticket： '
            .. sword_ticketslable
            .. '    Skill Ticket： '
            .. skill_ticketslable
    end
    spawn(function()
        while true do
            updateExtractedValues()
            wait(1)
        end
    end)
    local AutolotterySwitch = features4:AddSwitch(
        'Auto Draw Weapon/Skill',
        function(bool)
            Autolottery = bool
            if Autolottery then
                canstartticket = true
                canstartticket2 = true
                while Autolottery do
                    Comparelevel()
                    wait(Autolotteryspeed)
                    wait(0.4)
                end
            else
                canstartticket = false
                canstartticket2 = false
            end
        end
    )
    AutolotterySwitch:Set(false)
    local USEDiamondSwitch = features4:AddSwitch(
        'Enable Diamond Draw',
        function(bool)
            useDiamonds = bool
        end
    )
    USEDiamondSwitch:Set(false)
    -- 定义执行函数
    local function ExecuteSettingsClose()
        local targetGui =
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\232\174\190\231\189\174']['\232\131\140\230\153\175']['\232\174\190\231\189\174\229\140\186\229\159\159']['\233\159\179\228\185\144\232\174\190\231\189\174\233\161\185']['\229\188\128\229\133\179']['\229\137\141\230\153\175']

        if targetGui.Visible then
            local argsList = {
                '\233\159\179\228\185\144',
                '\231\178\146\229\173\144\231\137\185\230\149\136',
                '\228\188\164\229\174\179\230\152\190\231\164\186',
                '\230\142\137\232\144\189\229\138\168\231\148\187',
                '\233\159\179\230\149\136',
                '\230\138\189\229\165\150\229\138\168\231\148\187',
                '\230\179\149\229\174\157\229\138\168\231\148\187',
                '\229\135\186\229\148\174\228\186\140\230\172\161\231\161\174\232\174\164',
            }

            local remotePath = game:GetService('ReplicatedStorage')
                :FindFirstChild('\228\186\139\228\187\182')
                :FindFirstChild('\229\133\172\231\148\168')
                :FindFirstChild('\232\174\190\231\189\174')
                :FindFirstChild(
                    '\231\142\169\229\174\182\228\191\174\230\148\185\232\174\190\231\189\174'
                )

            for _, args in ipairs(argsList) do
                remotePath:FireServer(args)
            end
        end
    end

    -- 启动时自动执行一次
    ExecuteSettingsClose()

    -- 添加按钮功能
    features4:AddButton('关闭设置', ExecuteSettingsClose)
    local AutoupdFlyingSwordSwitch = features5:AddSwitch(
        'Auto Upgrade Hover',
        function(bool)
            AutoupdFlyingSword = bool
            if AutoupdFlyingSword then
                while AutoupdFlyingSword do
                    game:GetService('ReplicatedStorage')
                        :FindFirstChild('\228\186\139\228\187\182')
                        :FindFirstChild('\229\133\172\231\148\168')
                        :FindFirstChild('\233\163\158\229\137\145')
                        :FindFirstChild('\229\141\135\231\186\167')
                        :FireServer()
                    wait(0.2)
                end
            end
        end
    )
    AutoupdFlyingSwordSwitch:Set(false)
    local AutoupdskillSwordSwitch = features5:AddSwitch(
        'Auto Upgrade Weapon/Skill',
        function(bool)
            AutoupdskillSword = bool
            if AutoupdskillSword then
                while AutoupdskillSword do
                    game:GetService('ReplicatedStorage')
                        :FindFirstChild('\228\186\139\228\187\182')
                        :FindFirstChild('\229\133\172\231\148\168')
                        :FindFirstChild('\230\179\149\229\174\157')
                        :FindFirstChild(
                            '\229\141\135\231\186\167\229\133\168\233\131\168\230\179\149\229\174\157'
                        )
                        :FireServer()
                    game:GetService('ReplicatedStorage')
                        :FindFirstChild('\228\186\139\228\187\182')
                        :FindFirstChild('\229\133\172\231\148\168')
                        :FindFirstChild('\230\138\128\232\131\189')
                        :FindFirstChild(
                            '\229\141\135\231\186\167\229\133\168\233\131\168\230\138\128\232\131\189'
                        )
                        :FireServer()
                    wait(1.5)
                end
            end
        end
    )
    AutoupdskillSwordSwitch:Set(false)
    local AutoupdRuneSwordSwitch = features5:AddSwitch(
        'Auto Upgrade Rune (Magic Circle)',
        function(bool)
            AutoupdRuneSwordSwitch = bool
            if AutoupdRuneSwordSwitch then
                while AutoupdRuneSwordSwitch do
                    game:GetService('ReplicatedStorage')
                        :FindFirstChild('\228\186\139\228\187\182')
                        :FindFirstChild('\229\133\172\231\148\168')
                        :FindFirstChild('\233\152\181\230\179\149')
                        :FindFirstChild('\229\141\135\231\186\167')
                        :FireServer()
                    wait(0.2)
                end
            end
        end
    )
    AutoupdRuneSwordSwitch:Set(false)
    local Guidename = playerGui.GUI
        :WaitForChild('二级界面')
        :WaitForChild('公会')
        :WaitForChild('背景')
        :WaitForChild('右侧界面')
        :WaitForChild('主页')
        :WaitForChild('介绍')
        :waitForChild('名称')
        :waitForChild('文本')
        :waitForChild('文本').Text
    local Donatetimes = playerGui.GUI
        :WaitForChild('二级界面')
        :WaitForChild('公会')
        :WaitForChild('捐献')
        :WaitForChild('背景')
        :WaitForChild('按钮')
        :WaitForChild('确定按钮')
        :WaitForChild('次数').Text
    local Donatetimesnumber = tonumber(string.match(Donatetimes, '%d+'))
    local Guildname = features5:AddLabel(
        'Guild Name：未獲取點擊更新公會'
            .. ' Contribution Times Left： '
            .. Donatetimesnumber
    )
    features5:AddButton('Update Guild Data', function()
        Donatetimes = playerGui.GUI
            :WaitForChild('二级界面')
            :WaitForChild('公会')
            :WaitForChild('捐献')
            :WaitForChild('背景')
            :WaitForChild('按钮')
            :WaitForChild('确定按钮')
            :WaitForChild('次数').Text
        Donatetimesnumber = tonumber(string.match(Donatetimes, '%d+'))
        local replicatedStorage = game:GetService('ReplicatedStorage')
        local event = replicatedStorage:FindFirstChild('打开公会', true)
        event:Fire('打开公会')
        Guildname.Text = 'Guild Name：'
            .. Guidename
            .. ' Contribution Times Left： '
            .. Donatetimesnumber
    end)
    local DonationUI =
        playerGui.GUI:WaitForChild('二级界面'):WaitForChild('公会')
    local DonateButton = DonationUI:WaitForChild('捐献')
        :WaitForChild('背景')
        :WaitForChild('按钮')
        :WaitForChild('确定按钮')
    local DonationEvent = game:GetService('ReplicatedStorage')
        :WaitForChild('\228\186\139\228\187\182')
        :WaitForChild('\229\133\172\231\148\168')
        :WaitForChild('\229\133\172\228\188\154')
        :WaitForChild('\230\141\144\231\140\174')

    -- 创建独立控制模块
    local donationController = {
        enabled = false,
        interval = 0.5,
        maxAttempts = 3,
        currentAttempts = 0,
    }

    local function updateGuildDisplay()
        local counterText = DonateButton:WaitForChild('次数').Text
        local remaining = tonumber(counterText:match('%d+')) or 0
        Guildname.Text = ('公會名稱：%s 剩餘貢獻次數：%d'):format(
            Guidename,
            remaining
        )
        return remaining
    end

    local function executeDonation()
        pcall(function()
            DonationEvent:FireServer()
        end)
    end

    -- 创建带保护机制的捐献循环

    -- 创建带保护机制的捐献循环
    local function donationLoop()
        while donationController.enabled do
            local success, remaining = pcall(updateGuildDisplay)

            if success and remaining > 0 then
                executeDonation()
                donationController.currentAttempts = 0
            else
                donationController.currentAttempts += 1
            end

            if
                donationController.currentAttempts
                >= donationController.maxAttempts
            then
                warn('连续失败次数过多，自动停止')
                donationController.enabled = false
            end

            -- 如果捐献次数为 0，标记完成
            if success and remaining == 0 then
                donationController.enabled = false
                donationFinished = true
                checkAllTasksFinished()
                print('[系统] 公会捐献已完成，准备购买草药')
            end

            task.wait(donationController.interval)
        end
    end

    -- 初始化开关并设置自动启动
    local AutoDonateSwitch = features5:AddSwitch(
        'Auto Contribute',
        function(isActive)
            donationController.enabled = isActive
            if isActive then
                task.spawn(donationLoop)
            end
        end
    )

    -- 安全自启动机制
    task.defer(function()
        task.wait(3) -- 等待界面初始化
        if not donationController.enabled then
            AutoDonateSwitch:Set(true)
        end
    end)

    local herbController = {
        enabled = false,
        interval = 0.2,
        maxAttempts = 5,
        currentAttempts = 0,
        highCostMode = false,
    }

    -- 字符串处理辅助函数
    local function countSubstring(str, pattern)
        return select(2, str:gsub(pattern, ''))
    end

    -- 安全数值转换器
    local function parseNumber(text)
        local str = tostring(text):lower():gsub('%s+', ''):gsub(',', '')
        local numStr = str:gsub('[^%d%.]', '')

        if countSubstring(numStr, '%.') > 1 then
            warn('[数值异常] 非法格式:', text)
            return 0
        end

        local multiplier = 1
        if str:find('k') then
            multiplier = 1000
        elseif str:find('m') then
            multiplier = 1000000
        end

        return (tonumber(numStr) or 0) * multiplier
    end

    -- 数值获取函数
    local function getDiamond()
        return parseNumber(
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\233\146\187\231\159\179']['\230\140\137\233\146\174']['\229\128\188'].Text
        )
    end

    local function getGuildCoin()
        return parseNumber(
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\133\172\228\188\154']['\232\131\140\230\153\175']['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151']['\229\133\172\228\188\154\229\184\129']['\230\140\137\233\146\174']['\229\128\188'].Text
        )
    end

    local function getRefreshCost()
        return parseNumber(
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\133\172\228\188\154']['\232\131\140\230\153\175']['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151']['\229\136\183\230\150\176']['\230\140\137\233\146\174']['\229\128\188'].Text
        )
    end

    -- 界面控制函数
    local function toggleGuildUI(state)
        pcall(function()
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\133\172\228\188\154'].Visible =
                state
        end)
    end
    local price = 400 -- 固定价格

    -- 购买逻辑主循环

    local function herbLoop()
        while herbController.enabled do
            -- 等待捐献完成
            if not donationFinished then
                task.wait(1)
                continue -- 跳过本轮，直到捐献完成
            end

            -- 第一次开始买草药时提示
            if not herbController.started then
                print('[系统] 开始自动购买草药')
                herbController.started = true
            end

            local boughtAny = false
            local money = getDiamond()
            local guilditemlist =
                game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\133\172\228\188\154']['\232\131\140\230\153\175']['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151']['\229\136\151\232\161\168']

            local function tryBuy(slotIndex)
                local item = guilditemlist:GetChildren()[slotIndex]
                if item and item:FindFirstChild('\230\140\137\233\146\174') then
                    local button = item['\230\140\137\233\146\174']
                    if
                        button['\229\186\147\229\173\152'].Text == '1 Left'
                        and button['\229\144\141\231\167\176'].Text
                            == 'Herb'
                    then
                        if money >= price then
                            game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\133\172\231\148\168']['\229\133\172\228\188\154']['\229\133\145\230\141\162']
                                :FireServer(slotIndex - 2)
                            money = money - price
                            boughtAny = true
                            return true
                        else
                            warn(
                                '[草药购买] 货币不足，跳过槽位 '
                                    .. slotIndex
                            )
                        end
                    end
                end
                return false
            end

            -- 遍历所有槽位
            for i = 1, 18 do
                if not herbController.enabled then
                    break
                end
                tryBuy(i)
            end

            local refreshCost = getRefreshCost()
            local diamond = getDiamond()
            local guildCoin = getGuildCoin()

            -- 高成本模式
            if refreshCost > 7000 then
                if not herbController.highCostMode then
                    print(
                        '[系统] 进入高成本模式，结束草药购买任务'
                    )
                    herbController.highCostMode = true
                    if not herbBuyFinished then
                        herbBuyFinished = true
                        checkAllTasksFinished()
                    end
                    herbController.enabled = false
                end
                toggleGuildUI(false)
                task.wait(300)
                break
            else
                herbController.highCostMode = false
            end

            -- 正常刷新
            if
                diamond > refreshCost
                and guildCoin >= 400
                and diamond >= 18000
            then
                pcall(function()
                    game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\174\162\230\136\183\231\171\175']['\229\174\162\230\136\183\231\171\175UI']['\230\137\147\229\188\128\229\133\172\228\188\154']
                        :Fire()
                    task.wait(0.5)
                    game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\133\172\231\148\168']['\229\133\172\228\188\154']['\229\136\183\230\150\176\229\133\172\228\188\154\229\149\134\229\186\151']
                        :FireServer()
                end)
                task.wait(1.5)
            else
                print(
                    '[草药购买] 刷新条件不满足，结束购买任务'
                )
                if not herbBuyFinished then
                    herbBuyFinished = true
                    checkAllTasksFinished()
                end
                herbController.enabled = false -- 停止循环
                task.wait(30)
            end
        end -- 关闭 while
    end -- 关闭 function

    -- 界面控件
    local Autoguildshop = features5:AddSwitch(
        'Auto Buy Herbs (Guild Shop)',
        function(state)
            herbController.enabled = state
            herbController.highCostMode = false -- 重置状态
            if state then
                task.spawn(herbLoop)
                print('[系统] 自动购买已启动')
            else
                print('[系统] 自动购买已停止')
            end
        end
    )

    -- 安全自启动机制（添加在自动捐献代码下方）
    task.defer(function()
        task.wait(3) -- 等待界面初始化
        if not herbController.enabled then
            Autoguildshop:Set(true)
        end
    end)

    features5:AddButton('Unlock Building', function()
        for i = 1, 30 do
            game:GetService('ReplicatedStorage')
                :WaitForChild('\228\186\139\228\187\182')
                :WaitForChild('\229\133\172\231\148\168')
                :WaitForChild('\229\187\186\231\173\145')
                :WaitForChild(
                    '\232\167\163\233\148\129\229\187\186\231\173\145'
                )
                :FireServer(i)
        end
        wait(1)
        for i = 1, 30 do
            local args = {
                [1] = 1,
            }
            game:GetService('ReplicatedStorage')
                :FindFirstChild('\228\186\139\228\187\182')
                :FindFirstChild('\229\133\172\231\148\168')
                :FindFirstChild(
                    '\232\138\130\230\151\165\230\180\187\229\138\168'
                )
                :FindFirstChild('\232\180\173\228\185\176')
                :FireServer(unpack(args))
        end
        wait(1)
        for i = 1, 40 do
            local args = {
                [1] = 12,
            }
            game:GetService('ReplicatedStorage')
                :FindFirstChild('\228\186\139\228\187\182')
                :FindFirstChild('\229\133\172\231\148\168')
                :FindFirstChild(
                    '\232\138\130\230\151\165\230\180\187\229\138\168'
                )
                :FindFirstChild('\232\180\173\228\185\176')
                :FireServer(unpack(args))
        end
    end)

    features5:AddButton('Unequip Decor', function()
        for i = 1, 5 do
            game:GetService('ReplicatedStorage')
                :WaitForChild('\228\186\139\228\187\182')
                :WaitForChild('\229\133\172\231\148\168')
                :WaitForChild('\233\152\181\230\179\149')
                :WaitForChild('\229\141\184\228\184\139')
                :FireServer(i)
            game:GetService('ReplicatedStorage')
                :WaitForChild('\228\186\139\228\187\182')
                :WaitForChild('\229\133\172\231\148\168')
                :WaitForChild('\228\184\150\231\149\140\230\160\145')
                :WaitForChild('\229\141\184\228\184\139')
                :FireServer(i)
        end
        game:GetService("ReplicatedStorage")
            :WaitForChild("\228\186\139\228\187\182")
            :WaitForChild("\229\133\172\231\148\168")
            :WaitForChild("\229\174\160\231\137\169")
            :WaitForChild("\229\141\184\228\184\139")
            :FireServer()
    end)

    local replicatedStorage = game:GetService('ReplicatedStorage')
    features6:AddButton('開啟每日任務', function()
        local event =
            replicatedStorage:FindFirstChild('打开每日任务', true)
        if event and event:IsA('BindableEvent') then
            event:Fire('打開每日任務')
        end
    end)
    features6:AddButton('開啟郵件', function()
        local event = replicatedStorage:FindFirstChild('打开邮件', true)
        if event and event:IsA('BindableEvent') then
            event:Fire('打开郵件')
        end
    end)
    features6:AddButton('開啟轉盤', function()
        local event = replicatedStorage:FindFirstChild('打开转盘', true)
        if event and event:IsA('BindableEvent') then
            event:Fire('打開轉盤')
        end
    end)
    features6:AddButton('開啟陣法', function()
        local event = replicatedStorage:FindFirstChild('打开阵法', true)
        if event and event:IsA('BindableEvent') then
            event:Fire('打开陣法')
        end
    end)
    features6:AddButton('開啟世界樹', function()
        local event = replicatedStorage:FindFirstChild('打开世界树', true)
        if event and event:IsA('BindableEvent') then
            event:Fire('打開世界樹')
        end
    end)
    features6:AddButton('開啟練器台', function()
        local event = replicatedStorage:FindFirstChild('打开炼器台', true)
        if event and event:IsA('BindableEvent') then
            event:Fire('打開練器台')
        end
    end)
    features6:AddButton('開啟煉丹爐', function()
        local event = replicatedStorage:FindFirstChild('打开炼丹炉', true)
        if event and event:IsA('BindableEvent') then
            event:Fire('打開煉丹爐')
        end
    end)
features6:AddButton('每月鑰匙購買', function()
    local Rep = game:GetService("ReplicatedStorage")
    local remote = Rep:FindFirstChild("\228\186\139\228\187\182")
        :FindFirstChild("\229\133\172\231\148\168")
        :FindFirstChild("\232\138\130\230\151\165\230\180\187\229\138\168")
        :FindFirstChild("\232\180\173\228\185\176")

    for i = 1, 60 do
        for arg = 4, 9 do
            remote:FireServer(arg)
        end
    end

    for i = 1, 30 do
        for arg = 17, 22 do
            remote:FireServer(arg)
        end
    end
end)

    features7:AddLabel(' -- 語言配置/language config')
    features7:AddButton('刪除語言配置/language config delete', function()
        local HttpService = game:GetService('HttpService')
        function deleteConfigFile()
            if isfile('Cultivation_languageSet.json') then
                delfile('Cultivation_languageSet.json')
                print('配置文件 Cultivation_languageSet.json 已刪除。')
            else
                print(
                    '配置文件 Cultivation_languageSet.json 不存在，無法刪除。'
                )
            end
        end
        deleteConfigFile()
    end)
    features7:AddLabel(' - - 統計')
    features7:AddButton('每秒擊殺/金幣數', function()
        loadstring(
            game:HttpGet(
                'https://github.com/supleruckydior/test/raw/refs/heads/main/%E9%87%91%E5%B8%81.json'
            )
        )()
    end)
    features7:AddLabel(' 有任何問題或想法請在Github上留言')
    features7:AddButton('Github連結', function()
        local urlToCopy = 'https://github.com/Tseting-nil'
        if setclipboard then
            setclipboard(urlToCopy)
            showNotification('連結以複製！')
        else
            showNotification('錯誤！連結為：github.com/Tseting-nil')
        end
    end)

    local UI_LOAD_DELAY = 0.03
    local RETRY_COUNT = 3

    -- 初始化界面
    local Farm_choose = features8:AddLabel('  正在初始化...')
    local currentFarm = 1
    local targetLevel = 80
    local lastFarmLevel = 0

    -- 炼丹炉初始化
    local Elixir_choose = features8:AddLabel('  正在初始化炼丹炉...')
    local currentElixir = 1
    local targetElixirLevel = 80
    local lastElixirLevel = 0

    -- 共用事件路径
    local REPLICATED_STORAGE = game:GetService('ReplicatedStorage')

    -- 农田事件
    local FARM_UPGRADE_EVENT = REPLICATED_STORAGE
        :WaitForChild('\228\186\139\228\187\182')
        :WaitForChild('\229\133\172\231\148\168')
        :WaitForChild('\229\134\156\231\148\176')
        :WaitForChild('\229\141\135\231\186\167')

    -- 炼丹炉事件
    local ELIXIR_UPGRADE_EVENT = REPLICATED_STORAGE
        :WaitForChild('\228\186\139\228\187\182')
        :WaitForChild('\229\133\172\231\148\168')
        :WaitForChild('\231\130\188\228\184\185')
        :WaitForChild('\229\141\135\231\186\167')

    -- 等级获取函数
    local function GetLevel(path)
        local finalLevel = 0
        for _ = 1, RETRY_COUNT do
            local success, result = pcall(function()
                return game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162'][path]['\232\131\140\230\153\175']['\229\177\158\230\128\167\229\140\186\229\159\159']['\229\177\158\230\128\167\229\136\151\232\161\168']['\229\136\151\232\161\168']['\231\173\137\231\186\167']['\229\128\188']
            end)
            if success and result then
                finalLevel = tonumber(result.Text:match('%d+')) or 0
                break
            end
            wait(UI_LOAD_DELAY)
        end
        return finalLevel
    end

    -- 药田显示更新
    local function UpdateFarmDisplay()
        Farm_choose.Text = string.format(
            '  當前選擇 農田：%d  等級：%d  目標：%d',
            currentFarm,
            lastFarmLevel,
            targetLevel
        )
    end

    -- 炼丹炉显示更新
    local function UpdateElixirDisplay()
        Elixir_choose.Text = string.format(
            '  當前選擇 丹爐：%d  等級：%d  目標：%d',
            currentElixir,
            lastElixirLevel,
            targetElixirLevel
        )
    end

    -- 药田等级刷新
    local function UpdateFarmLevel()
        spawn(function()
            Farm_choose.Text =
                string.format('  農田%d ▷ 讀取中...', currentFarm)
            local newLevel = GetLevel('\229\134\156\231\148\176')
            lastFarmLevel = newLevel

            for i = 1, 5 do
                Farm_choose.Text = string.format(
                    '  農田%d ▶ 當前等級：%d',
                    currentFarm,
                    math.floor(
                        lastFarmLevel + (newLevel - lastFarmLevel) * (i / 5)
                    )
                )
                wait(UI_LOAD_DELAY)
            end
            UpdateFarmDisplay()
        end)
    end

    -- 炼丹炉等级刷新
    local function UpdateElixirLevel()
        spawn(function()
            Elixir_choose.Text =
                string.format('  丹爐%d ▷ 讀取中...', currentElixir)
            local newLevel = GetLevel('\231\130\188\228\184\185\231\130\137')
            lastElixirLevel = newLevel

            for i = 1, 5 do
                Elixir_choose.Text = string.format(
                    '  丹爐%d ▶ 當前等級：%d',
                    currentElixir,
                    math.floor(
                        lastElixirLevel + (newLevel - lastElixirLevel) * (i / 5)
                    )
                )
                wait(UI_LOAD_DELAY)
            end
            UpdateElixirDisplay()
        end)
    end

    -- 药田选择系统
    local Farm_selection = features8:AddDropdown('選擇農田', function(text)
        currentFarm = tonumber(text:match('%d')) or 1
        pcall(function()
            local openEvent =
                REPLICATED_STORAGE:FindFirstChild('打开农田', true)
            if openEvent and openEvent:IsA('BindableEvent') then
                openEvent:Fire(currentFarm)
                wait(UI_LOAD_DELAY * 2)
            end
        end)
        UpdateFarmLevel()
    end)

    for i = 1, 5 do
        Farm_selection:Add('農田' .. i)
    end

    -- 药田等级控制
    features8:AddButton('▲ 提升農田目標', function()
        targetLevel = math.min(200, targetLevel + 1)
        UpdateFarmDisplay()
    end)

    features8:AddButton('▼ 降低農田目標', function()
        targetLevel = math.max(0, targetLevel - 1)
        UpdateFarmDisplay()
    end)
    local isWorkingFarm = false
    features8:AddButton('▶ 農田超頻 (精準版)', function()
        isWorkingFarm = not isWorkingFarm
        spawn(function()
            if isWorkingFarm then
                local originalTarget = targetLevel
                Farm_choose.Text = '  ⚡ 計算強化次數中...'

                pcall(function()
                    for farmIndex = 1, 5 do
                        if not isWorkingFarm then
                            break
                        end

                        -- 切換農田
                        currentFarm = farmIndex
                        local openEvent = REPLICATED_STORAGE:FindFirstChild(
                            '打开农田',
                            true
                        )
                        if openEvent and openEvent:IsA('BindableEvent') then
                            openEvent:Fire(farmIndex)
                            wait(0.1) -- 确保UI切换
                        end

                        -- 獲取當前等級
                        local currentLevel =
                            GetLevel('\229\134\156\231\148\176')
                        if currentLevel >= targetLevel then
                            Farm_choose.Text = string.format(
                                '  ✅ 農田%d已達標 (%d級)',
                                farmIndex,
                                currentLevel
                            )
                            wait(0.05)
                        end

                        -- 計算需要強化的次數
                        local neededUpgrades = targetLevel - currentLevel
                        Farm_choose.Text = string.format(
                            '  ⚡ 農田%d將強化 %d次 (%d→%d)',
                            farmIndex,
                            neededUpgrades,
                            currentLevel,
                            targetLevel
                        )

                        -- 分批發送請求 (每10次一組，組間隔0.05秒)
                        local BATCH_SIZE = 10
                        for i = 1, neededUpgrades do
                            if not isWorkingFarm then
                                break
                            end

                            pcall(
                                FARM_UPGRADE_EVENT.FireServer,
                                FARM_UPGRADE_EVENT,
                                farmIndex
                            )

                            -- 分批處理
                            if i % BATCH_SIZE == 0 then
                                wait(0.05)
                                Farm_choose.Text = string.format(
                                    '  ⚡ 農田%d: %d/%d次 (%.1f%%)',
                                    farmIndex,
                                    i,
                                    neededUpgrades,
                                    (i / neededUpgrades) * 100
                                )
                            end
                        end

                        -- 最終確認
                        local finalLevel = GetLevel('\229\134\156\231\148\176')
                        Farm_choose.Text = string.format(
                            '  ✅ 農田%d完成 %d級 (實際+%d級)',
                            farmIndex,
                            finalLevel,
                            finalLevel - currentLevel
                        )
                        wait(0.1)
                    end

                    Farm_choose.Text = '  ✅ 所有農田強化完畢'
                    currentFarm = 1
                    local openEvent =
                        REPLICATED_STORAGE:FindFirstChild('打开农田', true)
                    if openEvent then
                        openEvent:Fire(currentFarm)
                    end
                end)

                isWorkingFarm = false
                UpdateFarmDisplay()
            end
        end)
    end)

    -- 炼丹炉选择系统
    local Elixir_selection = features8:AddDropdown(
        '選擇丹爐',
        function(text)
            currentElixir = tonumber(text:match('%d')) or 1
            pcall(function()
                game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\174\162\230\136\183\231\171\175']['\229\174\162\230\136\183\231\171\175UI']['\230\137\147\229\188\128\231\130\188\228\184\185\231\130\137']
                    :Fire()
                wait(UI_LOAD_DELAY * 2)
            end)
            UpdateElixirLevel()
        end
    )
    Elixir_selection:Add('丹爐1')

    -- 炼丹炉等级控制
    features8:AddButton('▲ 提升丹爐目標', function()
        targetElixirLevel = math.min(1000, targetElixirLevel + 1)
        UpdateElixirDisplay()
    end)

    features8:AddButton('▼ 降低丹爐目標', function()
        targetElixirLevel = math.max(0, targetElixirLevel - 1)
        UpdateElixirDisplay()
    end)

    -- 炼丹炉超频模式
    features8:AddButton('▶ 丹爐超頻 (精準版)', function()
        local isWorkingElixir = not isWorkingElixir
        spawn(function()
            if isWorkingElixir then
                Elixir_choose.Text = '  ⚡ 計算丹爐強化次數中...'

                pcall(function()
                    -- 開啟丹爐界面
                    game:GetService('ReplicatedStorage')['\228\186\139\228\187\182']['\229\174\162\230\136\183\231\171\175']['\229\174\162\230\136\183\231\171\175UI']['\230\137\147\229\188\128\231\130\188\228\184\185\231\130\137']
                        :Fire()
                    wait(0.1) -- 基礎UI等待

                    -- 獲取當前等級
                    local currentLevel =
                        GetLevel('\231\130\188\228\184\185\231\130\137')
                    if currentLevel >= targetElixirLevel then
                        Elixir_choose.Text = string.format(
                            '  ✅ 丹爐已達標 (%d級)',
                            currentLevel
                        )
                        isWorkingElixir = false
                        return
                    end

                    -- 計算需要強化的次數
                    local neededUpgrades = targetElixirLevel - currentLevel
                    Elixir_choose.Text = string.format(
                        '  ⚡ 需要強化 %d次 (%d→%d)',
                        neededUpgrades,
                        currentLevel,
                        targetElixirLevel
                    )

                    -- 分批發送請求 (每15次一組，組間隔0.03秒)
                    local BATCH_SIZE = 15
                    for i = 1, neededUpgrades do
                        if not isWorkingElixir then
                            break
                        end

                        pcall(
                            ELIXIR_UPGRADE_EVENT.FireServer,
                            ELIXIR_UPGRADE_EVENT
                        )

                        -- 分批處理與進度更新
                        if i % BATCH_SIZE == 0 then
                            wait(0.03)
                            local nowLevel =
                                GetLevel('\231\130\188\228\184\185\231\130\137')
                            Elixir_choose.Text = string.format(
                                '  ⚡ 進度: %d/%d次 (實際:%d級)',
                                i,
                                neededUpgrades,
                                nowLevel
                            )
                        end
                    end

                    -- 最終確認
                    local finalLevel =
                        GetLevel('\231\130\188\228\184\185\231\130\137')
                    Elixir_choose.Text = string.format(
                        '  ✅ 完成強化 (實際:%d級 提升:%d級)',
                        finalLevel,
                        finalLevel - currentLevel
                    )
                end)

                isWorkingElixir = false
            end
        end)
    end)

    task.defer(function()
        -- 获取当前玩家列表
        local players = game.Players:GetPlayers()
        local playerNames = {}
        for _, player in pairs(players) do
            table.insert(playerNames, player.Name)
        end

        -- 添加下拉控件
        local selectedPlayer = ''
        local dropdown = features9:AddDropdown(
            '选择玩家',
            function(selected)
                selectedPlayer = selected
            end
        )

        -- 手动管理选项列表
        local dropdownOptions = {}

        -- 将玩家名称添加到下拉控件中
        local function UpdateDropdown()
            -- 清空下拉菜单（通过移除每个选项）
            for _, option in pairs(dropdownOptions) do
                option:Remove()
            end
            dropdownOptions = {} -- 重置选项列表

            -- 重新添加玩家名称
            for _, name in pairs(playerNames) do
                local option = dropdown:Add(name)
                table.insert(dropdownOptions, option)
            end

            -- 在菜单最底部添加一个空白选项
            local blankOption = dropdown:Add('') -- 空白选项
            table.insert(dropdownOptions, blankOption)
        end

        -- 初始化下拉菜单
        UpdateDropdown()

        -- 监听玩家加入游戏的事件
        game.Players.PlayerAdded:Connect(function(player)
            table.insert(playerNames, player.Name)
            UpdateDropdown()
        end)

        -- 监听玩家离开游戏的事件
        game.Players.PlayerRemoving:Connect(function(player)
            for i, name in ipairs(playerNames) do
                if name == player.Name then
                    table.remove(playerNames, i)
                    break
                end
            end
            UpdateDropdown()
        end)

        -- 添加第一个按钮
        features9:AddButton('Teleport to Player', function()
            if selectedPlayer ~= '' then
                local args = {
                    [1] = game:GetService('Players')
                        :WaitForChild(selectedPlayer),
                }
                game:GetService('ReplicatedStorage')
                    :WaitForChild('\228\186\139\228\187\182')
                    :WaitForChild('\229\133\172\231\148\168')
                    :WaitForChild('\229\133\179\229\141\161')
                    :WaitForChild(
                        '\232\191\155\229\133\165\229\188\128\229\144\175\228\184\173\229\133\179\229\141\161'
                    )
                    :FireServer(unpack(args))
            else
                print('请先选择一个玩家')
            end
        end)

        -- 添加第二个按钮
        features9:AddButton('Turn On Support Mode', function()
            game:GetService('ReplicatedStorage')
                :WaitForChild('\228\186\139\228\187\182')
                :WaitForChild('\229\133\172\231\148\168')
                :WaitForChild('\230\136\152\230\150\151')
                :WaitForChild(
                    '\230\155\180\230\150\176\229\141\143\229\138\169\231\155\174\230\160\135'
                )
                :FireServer()
        end)
    end)
    local ReplicatedStorage = game:GetService('ReplicatedStorage')
    local Players = game:GetService('Players')
    local player = Players.LocalPlayer
    local GUI = player.PlayerGui:WaitForChild('GUI')

    -- 全局控制变量
    local Autoelixir = false
    local hasExecutedTrade = false -- 确保自动交易只执行一次

    -- 获取草药数值
    local function getHerbValue()
        local herbText = '0'
        pcall(function()
            herbText =
                GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159\229\143\179']['\232\141\137\232\141\175']['\229\128\188'].Text
        end)

        local cleanedHerbText =
            tostring(herbText):lower():gsub('%s+', ''):gsub(',', '')
        if cleanedHerbText:find('k') then
            local numStr = cleanedHerbText:gsub('[^%d%.]', '')
            return (tonumber(numStr) or 0) * 1000
        elseif cleanedHerbText:find('m') then
            local numStr = cleanedHerbText:gsub('[^%d%.]', '')
            return (tonumber(numStr) or 0) * 1000000
        else
            return tonumber(cleanedHerbText) or 0
        end
    end

    local function getOREValue()
        local OREText = '0'
        pcall(function()
            OREText =
                game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159\229\143\179']['\231\159\191\231\159\179']['\229\128\188'].Text
        end)

        local cleanedOREText =
            tostring(OREText):lower():gsub('%s+', ''):gsub(',', '')
        if cleanedOREText:find('k') then
            local numStr = cleanedOREText:gsub('[^%d%.]', '')
            return (tonumber(numStr) or 0) * 1000
        elseif cleanedOREText:find('m') then
            local numStr = cleanedOREText:gsub('[^%d%.]', '')
            return (tonumber(numStr) or 0) * 1000000
        else
            return tonumber(cleanedOREText) or 0
        end
    end

    -- 炼丹循环
    local function startElixirLoop()
        Autoelixir = true
        while Autoelixir do
            pcall(function()
                local elixirEvent = ReplicatedStorage
                    :FindFirstChild('\228\186\139\228\187\182')
                    :FindFirstChild('\229\133\172\231\148\168')
                    :FindFirstChild('\231\130\188\228\184\185')
                    :FindFirstChild('\229\136\182\228\189\156')
                if elixirEvent then
                    elixirEvent:FireServer()
                end
            end)
            wait(0.2)
        end
    end

    -- 智能监控
    local herbprint = false
    local lowcontrol = false

    local function smartMonitor()
        while true do
            local currentHerbs = getHerbValue()
            local playerName = game.Players.LocalPlayer.Name

            -- When herbs > 250k, execute trade script (once)
            if currentHerbs > 250000 and not hasExecutedTrade then
                herbprint = true
                lowcontrol = true -- Set lowcontrol flag when reaching high herbs

                pcall(function()
                    -- loadstring(
                    --     game:HttpGet(
                    --         'https://raw.githubusercontent.com/supleruckydior/test/refs/heads/main/%E8%87%AA%E5%8A%A8%E4%BA%A4%E6%98%932.json'
                    --     )
                    -- )()
                    hasExecutedTrade = true
                    print(
                        playerName
                            .. ' --- 自动交易脚本激活! ('
                            .. currentHerbs
                            .. '草药)'
                    )
                end)
                -- Start elixir loop if not already running
                if not Autoelixir then
                    coroutine.wrap(startElixirLoop)()
                end

            -- When herbs < 1000 AND we previously had high herbs (lowcontrol)
            elseif currentHerbs < 5000 and lowcontrol then
                Autoelixir = false
                hasExecutedTrade = false
                herbprint = false
                lowcontrol = false -- Reset the control flag
                print(
                    playerName
                        .. ' --- 系统重置! (剩余'
                        .. currentHerbs
                        .. '草药)'
                )
            end
            if herbprint and hasExecutedTrade then
                print(playerName .. ' --- ' .. currentHerbs .. '草药')
            end
            -- Regular status print when in high herb mode

            wait(5)
        end
    end

    -- 初始化检查
    local farm5Level = 0
    local elixirLevel = 0

    -- 获取农田5等级
    pcall(function()
        farm5Level = tonumber(
            GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\134\156\231\148\176']['\232\131\140\230\153\175']['\229\177\158\230\128\167\229\140\186\229\159\159']['\229\177\158\230\128\167\229\136\151\232\161\168']['\229\136\151\232\161\168']['\231\173\137\231\186\167']['\229\128\188'].Text:match(
                '%d+'
            )
        ) or 0
    end)
    GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\134\156\231\148\176'].Visible =
        false

    -- 获取炼丹炉等级
    pcall(function()
        local elixirUI = ReplicatedStorage
            :FindFirstChild('\228\186\139\228\187\182', true)
            :FindFirstChild('\229\174\162\230\136\183\231\171\175', true)
        if elixirUI then
            elixirUI['\229\174\162\230\136\183\231\171\175UI']['\230\137\147\229\188\128\231\130\188\228\184\185\231\130\137']:Fire()
            wait(0.5)
            elixirLevel = tonumber(
                GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\231\130\188\228\184\185\231\130\137']['\232\131\140\230\153\175']['\229\177\158\230\128\167\229\140\186\229\159\159']['\229\177\158\230\128\167\229\136\151\232\161\168']['\229\136\151\232\161\168']['\231\173\137\231\186\167']['\229\128\188'].Text:match(
                    '%d+'
                )
            ) or 0
        end
        GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\231\130\188\228\184\185\231\130\137'].Visible =
            false
    end)

    -- 主逻辑
    if farm5Level >= 80 and elixirLevel >= 80 then
        print('===== 系统启动 =====')
        print('农田5等级:', farm5Level)
        print('炼丹炉等级:', elixirLevel)
        print('初始草药量:', getHerbValue())
        print('==================')

        -- coroutine.wrap(smartMonitor)()
    else
        print('条件不满足：需要农田5和炼丹炉等级≥80')
    end
    local valueText =
        game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\228\184\187\232\167\146']['\232\131\140\230\153\175']['\229\143\179\228\190\167\231\149\140\233\157\162']['\232\163\133\229\164\135']['\232\167\146\232\137\178']['\231\190\189\230\160\184']['\230\140\137\233\146\174']['\229\128\188'].text
    local Players = game:GetService('Players')
    local LocalPlayer = Players.LocalPlayer
        or Players:GetPropertyChangedSignal('LocalPlayer'):Wait()
    local RobloxUsername = LocalPlayer.Name

    -- Synapse HTTP Bypass (works even if HttpService is blocked)
    local Request = syn and syn.request or http and http.request or request

    local success, response = pcall(function()
        wait(5)
        return Request({
            Url = webhookURL,
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json',
            },
            Body = game:GetService('HttpService'):JSONEncode({
                content = RobloxUsername
                    .. ' | '
                    .. valueText
                    .. ' Wing Core | '
                    .. getHerbValue()
                    .. ' Herbs | '
                    .. getOREValue()
                    .. ' Ore',
            }),
        })
    end)
    local Players = game:GetService('Players')
    local ReplicatedStorage = game:GetService('ReplicatedStorage')
    local LocalPlayer = Players.LocalPlayer

    -- Function to safely check and fire
    local function CheckAndFire()
        -- Your original GUI path (fully preserved)
        local gui =
            LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\232\135\170\229\138\168\229\135\186\229\148\174\229\188\185\229\135\186\230\161\134']['\232\131\140\230\153\175']['\230\140\137\233\146\174']['\230\147\141\228\189\156\229\140\186\229\159\159']['\229\130\168\229\173\152']['\229\155\190\230\160\135']['\229\155\190\230\160\135']

        -- Check if exists and is invisible
        if gui and gui.Visible == false then
            -- Your original RemoteEvent path (fully preserved)
            local remote = ReplicatedStorage
                :WaitForChild('\228\186\139\228\187\182')
                :WaitForChild('\229\133\172\231\148\168')
                :WaitForChild('\231\130\188\228\184\185')
                :WaitForChild(
                    '\228\191\174\230\148\185\232\135\170\229\138\168\229\130\168\229\173\152'
                )
            if remote then
                remote:FireServer()
                print('RemoteEvent fired successfully!')
            else
                warn('RemoteEvent not found!')
            end
        end
    end
    -- Run once immediately
    CheckAndFire()
    -- Print results
    if success and response.Success then
        print('✅ Successfully sent username to webhook: ' .. RobloxUsername)
    else
        warn(
            '❌ Failed to send webhook | Error: '
                .. tostring(response.StatusCode or response)
        )
    end
else
    warn('当前游戏不是目标游戏，脚本未运行。')
end
