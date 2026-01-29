-- ============================================================================
-- AUTOMATIC DAILY CULTIVATOR
-- ============================================================================
-- Description: Automated script for daily cultivation tasks
-- Version: 2.0 (Refactored)
-- ============================================================================

-- ============================================================================
-- GAME INITIALIZATION
-- ============================================================================
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local currentGameId = game.PlaceId
local TARGET_GAME_ID = 18645473062

if currentGameId ~= TARGET_GAME_ID then
    warn('Current game is not the target game, script not running.')
    return
end

print('Target game detected, executing script...')

-- ============================================================================
-- CONFIGURATION
-- ============================================================================
local CONFIG = {
    -- Webhook Settings
    WEBHOOK_URL = 'https://discord.com/api/webhooks/1452786397013344368/BeCA4Q38NHGm0NKyxKW_pxr2HWDVo7vaWFOzDFRO3Ob1wT6XadkBU9XIw-kM3cIY4bP7',
    
    -- Guild Donation Settings
    DONATION_INTERVAL = 0.5,
    DONATION_MAX_ATTEMPTS = 3,
    
    -- Herb Purchase Settings
    HERB_INTERVAL = 0.2,
    HERB_MAX_ATTEMPTS = 5,
    HERB_PRICE = 400,
    HERB_REFRESH_COST_LIMIT = 10000,
    HERB_MIN_DIAMOND = 18000,
    HERB_MIN_GUILD_COIN = 400,
    
    -- UI Settings
    UI_UPDATE_DELAY = 0.5,
    
    -- Loading Settings
    LOADING_MAX_ATTEMPTS = 30,
    LOADING_TIMEOUT = 10,
    
    -- Supabase Settings
    SUPABASE_URL = "https://jenqldfrbwzbnqkurwrm.supabase.co",
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplbnFsZGZyYnd6Ym5xa3Vyd3JtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4Mzg5MjcsImV4cCI6MjA4NDQxNDkyN30.q0-99ishp3kqLwTgdZYwsxGtmmuAxCzQr3RtTQZqF2w", -- Gantilah dengan Anon/Public Key Anda
}

-- ============================================================================
-- TASK STATUS TRACKING
-- ============================================================================
local TASK_STATUS = {
    loadingComplete = false,
    mailClaimed = false,
    gemsInvested = false,
    herbsCollected = false,
    guildDonated = false,
    herbsPurchased = false,
    wheelSpun = false,
    webhookSent = false,
}

local allTasksCompleted = false

-- ============================================================================
-- SERVICES AND REFERENCES
-- ============================================================================
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local player = Players.LocalPlayer

-- Wait for player GUI
while not player:FindFirstChild('PlayerGui') do
    task.wait(1)
end
local playerGui = player.PlayerGui

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Parse number with K/M suffix support
local function parseNumber(text)
    local str = tostring(text):lower():gsub('%s+', ''):gsub(',', '')
    local numStr = str:gsub('[^%d%.]', '')
    
    -- Check for multiple decimal points
    if select(2, numStr:gsub('%.', '')) > 1 then
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

-- Get current herb value
local function getHerbValue()
    local success, herbText = pcall(function()
        return playerGui:WaitForChild('GUI')['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159\229\143\179']['\232\141\137\232\141\175']['\229\128\188' --[[Value]]].Text
    end)
    
    if not success then
        return 0
    end
    
    return parseNumber(herbText)
end

-- Get current ore value
local function getOREValue()
    local success, oreText = pcall(function()
        return playerGui:WaitForChild('GUI')['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159\229\143\179']['\231\159\191\231\159\179']['\229\128\188' --[[Value]]].Text
    end)
    
    if not success then
        return 0
    end
    
    return parseNumber(oreText)
end

-- Get current diamond value
local function getDiamond()
    local success, diamondText = pcall(function()
        return playerGui:WaitForChild('GUI')['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\233\146\187\231\159\179']['\230\140\137\233\146\174']['\229\128\188' --[[Value]]].Text
    end)
    
    if not success then
        return 0
    end
    
    return parseNumber(diamondText)
end

-- Get guild coin value
local function getGuildCoin()
    local success, coinText = pcall(function()
        return playerGui:WaitForChild('GUI')['\228\186\140\231\186\167\231\149\140\233\157\162' --[[Secondary Interface]]]['\229\133\172\228\188\154' --[[Guild]]]['\232\131\140\230\153\175' --[[Background]]]['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151' --[[Shop]]]['\229\133\172\228\188\154\229\184\129']['\230\140\137\233\146\174']['\229\128\188' --[[Value]]].Text
    end)
    
    if not success then
        return 0
    end
    
    return parseNumber(coinText)
end

-- Get refresh cost
local function getRefreshCost()
    local success, costText = pcall(function()
        return playerGui:WaitForChild('GUI')['\228\186\140\231\186\167\231\149\140\233\157\162' --[[Secondary Interface]]]['\229\133\172\228\188\154' --[[Guild]]]['\232\131\140\230\153\175' --[[Background]]]['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151' --[[Shop]]]['\229\136\183\230\150\176']['\230\140\137\233\146\174']['\229\128\188' --[[Value]]].Text
    end)
    
    if not success then
        return 0
    end
    
    return parseNumber(costText)
end

-- Toggle guild UI visibility
local function toggleGuildUI(state)
    pcall(function()
        playerGui.GUI['二级界面']['公会'].Visible = state
    end)
end

-- Update status label
local function updateStatusLabel(label, text)
    if label then
        label.Text = text
        print('[Status] ' .. text)
    end
end

-- ============================================================================
-- LOADING SCREEN HANDLER
-- ============================================================================
local function waitForLoadingComplete()
    -- Function to safely find the loading GUI
    local function findLoadingGui()
        for i = 1, CONFIG.LOADING_MAX_ATTEMPTS do
            local success, gui = pcall(function()
                return playerGui.GUI['二级界面']['加载页面']
            end)
            if success and gui then
                return gui
            end
            task.wait(0.25)
        end
        return nil
    end

    local loadingGui = findLoadingGui()

    if loadingGui then
        print('Loading...')

        -- Wait for it to become visible if not already
        if not loadingGui.Visible then
            local visibleChanged = false
            local connection = loadingGui:GetPropertyChangedSignal('Visible'):Connect(function()
                visibleChanged = true
            end)

            local startTime = os.time()
            while not visibleChanged and os.time() - startTime < CONFIG.LOADING_TIMEOUT do
                task.wait(0.1)
            end
            connection:Disconnect()
        end

        -- Wait for it to become invisible
        if loadingGui.Visible then
            print('Waiting for loading to disappear...')
            while loadingGui.Parent and loadingGui.Visible do
                loadingGui:GetPropertyChangedSignal('Visible'):Wait()
                task.wait(0.1)
            end
        end
    else
        warn('⚠️ No Loading Screen, Executing Script...')
    end

    print('✅ Loading Complete, Continue Executing Script...')
    TASK_STATUS.loadingComplete = true
end

-- ============================================================================
-- TASK FUNCTIONS
-- ============================================================================

-- Claim all mail rewards
local function claimMail()
    local success = pcall(function()
        ReplicatedStorage:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\231\166\187\231\186\191\229\165\150\229\138\177"):WaitForChild("\233\162\134\229\165\150"):FireServer()
        ReplicatedStorage:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\233\130\174\228\187\182"):WaitForChild("\233\162\134\229\143\150\229\133\168\233\131\168\233\130\174\228\187\182"):FireServer()
    end)
    
    TASK_STATUS.mailClaimed = success
    return success
end

-- Invest gems (3 times receive, 3 times buy)
local function investGems()
    local success = pcall(function()
        for i = 1, 3 do
            local args = { i }
            ReplicatedStorage['事件']['公用']['商店']['银行']['领取理财']:FireServer(unpack(args))
        end
        wait(2)
        for i = 1, 3 do
            local args = { i }
            ReplicatedStorage['事件']['公用']['商店']['银行']['购买理财']:FireServer(unpack(args))
        end
    end)
    
    TASK_STATUS.gemsInvested = success
    return success
end

-- Collect herbs from farmland
local function collectHerbs()
    local success = pcall(function()
        for i = 1, 6 do
            local args = { [1] = i, [2] = nil }
            ReplicatedStorage['事件']['公用']['农田']['采集']:FireServer(unpack(args))
            wait(0.1)
        end
    end)
    
    TASK_STATUS.herbsCollected = success
    return success
end

-- Guild donation loop
local function donateToGuild()
    local donationController = {
        enabled = true,
        currentAttempts = 0,
    }
    
    local DonationUI = playerGui.GUI:WaitForChild('二级界面'):WaitForChild('公会')
    local DonationEvent = ReplicatedStorage:WaitForChild('事件'):WaitForChild('公用'):WaitForChild('公会'):WaitForChild('捐献')
    local DonateButton = DonationUI:WaitForChild('捐献'):WaitForChild('背景'):WaitForChild('按钮'):WaitForChild('确定按钮')
    
    local function executeDonation()
        pcall(function()
            DonationEvent:FireServer()
        end)
    end
    
    local function updateGuildDisplay()
        local counterText = DonateButton:WaitForChild('次数').Text
        local remaining = tonumber(counterText:match('%d+')) or 0
        return remaining
    end
    
    while donationController.enabled do
        local success, remaining = pcall(updateGuildDisplay)
        
        if success and remaining > 0 then
            executeDonation()
            donationController.currentAttempts = 0
        else
            donationController.currentAttempts = donationController.currentAttempts + 1
        end
        
        if donationController.currentAttempts >= CONFIG.DONATION_MAX_ATTEMPTS then
            warn('[System] Too many consecutive failures, stopping donation')
            donationController.enabled = false
        end
        
        if success and remaining == 0 then
            donationController.enabled = false
        end
        
        task.wait(CONFIG.DONATION_INTERVAL)
    end
    
    TASK_STATUS.guildDonated = true
    return true
end

-- Purchase herbs from guild shop
local function purchaseHerbs()
    local herbController = {
        enabled = true,
        currentAttempts = 0,
        highCostMode = false,
    }
    
    local function tryBuy(slotIndex)
        local success = pcall(function()
            local guilditemlist = playerGui.GUI['二级界面']['公会']['背景']['右侧界面']['商店']['列表']
            local item = guilditemlist:GetChildren()[slotIndex]
            
            if item and item:FindFirstChild('按钮') then
                local button = item['按钮']
                if button['库存'].Text == '1 Left' and button['名称'].Text == 'Herb' then
                    local money = getDiamond()
                    if money >= CONFIG.HERB_PRICE then
                        ReplicatedStorage['事件']['公用']['公会']['兑换']:FireServer(slotIndex - 2)
                        return true
                    else
                        warn('[Herb Purchase] Insufficient currency, skipping slot ' .. slotIndex)
                    end
                end
            end
        end)
        
        return success
    end
    
    while herbController.enabled do
        local boughtAny = false
        
        -- Try to buy herbs from all slots
        for i = 1, 18 do
            if not herbController.enabled then
                break
            end
            if tryBuy(i) then
                boughtAny = true
            end
        end
        
        local refreshCost = getRefreshCost()
        local diamond = getDiamond()
        local guildCoin = getGuildCoin()
        
        -- Check if refresh cost is too high
        if refreshCost > CONFIG.HERB_REFRESH_COST_LIMIT then
            if not herbController.highCostMode then
                print('[System] Entering high cost mode, ending herb purchase task')
                herbController.highCostMode = true
                herbController.enabled = false
            end
            toggleGuildUI(false)
            task.wait(0.5)
            break
        else
            herbController.highCostMode = false
        end
        
        -- Check if we can refresh
        if diamond > refreshCost and guildCoin >= CONFIG.HERB_MIN_GUILD_COIN and diamond >= CONFIG.HERB_MIN_DIAMOND then
            pcall(function()
                ReplicatedStorage['事件']['客户端']['客户端UI']['打开公会']:Fire()
                task.wait(0.5)
                ReplicatedStorage['事件']['公用']['公会']['刷新公会商店']:FireServer()
            end)
            task.wait(1.5)
        else
            print('[Herb Purchase] Refresh conditions not met, ending purchase task')
            herbController.enabled = false
            toggleGuildUI(false)
            task.wait(0.5)
        end
    end
    
    TASK_STATUS.herbsPurchased = true
    return true
end

-- Spin the wheel
local function spinWheel()
    local success = pcall(function()
        local event = ReplicatedStorage:FindFirstChild('打开转盘', true)
        if event and event:IsA('BindableEvent') then
            event:Fire('打開轉盤')
        end
        wait(0.5)
        
        local targetUI = playerGui.GUI["二级界面"]["抽奖转盘"]
        targetUI.Visible = false
        wait(1)
        
        for i = 1, 3 do
            ReplicatedStorage:WaitForChild("事件"):WaitForChild("公用"):WaitForChild("转盘"):WaitForChild("抽奖"):FireServer()
            wait(0.3)
            local args = {
                Vector2.new(513.1136474609375, 85.01416015625),
                5
            }
            ReplicatedStorage:WaitForChild("事件"):WaitForChild("公用"):WaitForChild("转盘"):WaitForChild("领奖"):FireServer(unpack(args))
            wait(0.3)
        end
    end)
    
    TASK_STATUS.wheelSpun = success
    return success
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function getStat(pathTable)
    local current = LocalPlayer
    for _, name in ipairs(pathTable) do
        current = current:WaitForChild(name, 30)
        if not current then return nil end
    end
    return current
end
local statsMap = {
    Herb          = getStat({"\229\128\188", "\232\180\167\229\184\129", "\232\141\137\232\141\175"}),
    Gold          = getStat({"\229\128\188", "\232\180\167\229\184\129", "\233\135\145\229\184\129"}),
    Diamond       = getStat({"\229\128\188", "\232\180\167\229\184\129", "\233\146\187\231\159\179"}),
    WingCore      = getStat({"\229\128\188", "\232\180\167\229\184\129", "\231\190\189\230\160\184"}),
    PurpleDiamond = getStat({"\229\128\188", "\232\180\167\229\184\129", "\231\180\171\233\146\187"}),
    Ore           = getStat({"\229\128\188", "\232\180\167\229\184\129", "\231\159\191\231\159\179"}),
    WaterOfLife   = getStat({"\229\128\188", "\232\180\167\229\184\129", "\231\148\159\229\145\189\228\185\139\230\176\180"}),
    GuildName     = getStat({"\229\128\188", "\228\191\161\230\129\175", "\229\133\172\228\188\154\229\144\141\231\167\176"}),
    Soul          = getStat({"\229\128\188", "\232\180\167\229\184\129", "\233\173\130\231\129\181"})
}

-- Send webhook notification
local function sendWebhook()
    local success = pcall(function()
        local wingCore = playerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162' --[[Secondary Interface]]]['\228\184\187\232\167\146']['\232\131\140\230\153\175' --[[Background]]]['\229\143\179\228\190\167\231\149\140\233\157\162']['\232\163\133\229\164\135']['\232\167\146\232\137\178']['\231\190\189\230\160\184']['\230\140\137\233\146\174']['\229\128\188' --[[Value]]].text
        local RobloxUsername = LocalPlayer.Name
        local RobloxDisplayName = LocalPlayer.DisplayName
        local level = playerGui.GUI['\228\184\187\231\149\140\233\157\162' --[[Secondary Interface]]]['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\231\173\137\231\186\167']['\230\140\137\233\146\174']['\229\155\190\230\160\135']['\231\173\137\231\186\167'].text
        local Request = syn and syn.request or http and http.request or request
        local soul = player["\229\128\188"]["\232\180\167\229\184\129"]["\233\173\130\231\129\181"]
        
        wait(5)
        
        -- Send to Discord webhook
        Request({
            Url = CONFIG.WEBHOOK_URL,
            Method = 'POST',
            Headers = { ['Content-Type'] = 'application/json' },
            Body = game:GetService('HttpService'):JSONEncode({
                content = RobloxUsername .. ' | ' .. wingCore .. ' Wing Core | ' .. getHerbValue() .. ' Herbs | ' .. getOREValue() .. ' Ore | ' .. soul.Value .. ' Soul',
            }),
        })
        
        -- Send to Supabase REST API (Direct Database)
        if CONFIG.SUPABASE_KEY ~= "YOUR_SUPABASE_ANON_KEY" then
            local supabasePayload = {
                username = RobloxUsername,
                name = RobloxDisplayName,
                user_id = LocalPlayer.UserId,
                guild = statsMap.GuildName and statsMap.GuildName.Value or "None",
                level = parseNumber(level),
                gold = statsMap.Gold and statsMap.Gold.Value or 0,
                wing_core = parseNumber(wingCore),
                ore = statsMap.Ore and statsMap.Ore.Value or 0,
                herbs = statsMap.Herb and statsMap.Herb.Value or 0,
                soul = statsMap.Soul and statsMap.Soul.Value or 0,
                arena_point = statsMap.PurpleDiamond and statsMap.PurpleDiamond.Value or 0,
                guild_coin = getGuildCoin(),
                last_updated = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                owner_name = "lotta"
            }

            local response = Request({
                Url = CONFIG.SUPABASE_URL .. "/rest/v1/account_stat?on_conflict=user_id",
                Method = 'POST',
                Headers = {
                    ['Content-Type'] = 'application/json',
                    ['apikey'] = CONFIG.SUPABASE_KEY,
                    ['Authorization'] = 'Bearer ' .. CONFIG.SUPABASE_KEY,
                    ['Prefer'] = 'resolution=merge-duplicates'
                },
                Body = game:GetService('HttpService'):JSONEncode(supabasePayload),
            })

            -- Debugging: Print status and error if any
            if response then
                print('--- Supabase Response ---')
                print('Status Code: ' .. tostring(response.StatusCode))
                print('Response Body: ' .. tostring(response.Body))
                
                if response.StatusCode == 201 or response.StatusCode == 200 or response.StatusCode == 204 then
                    print('✅ Data sent directly to Supabase PostgREST')
                else
                    warn('❌ Failed to update Supabase. Error Code: ' .. response.StatusCode)
                end
            else
                warn('❌ No response from Supabase Request')
            end
        else
            warn('⚠️ Supabase API Key not set, skipping direct database update')
        end
    end)
    
    TASK_STATUS.webhookSent = success
    return success
end
-- postgresql://postgres:[Muhammadzidane@02]@db.jenqldfrbwzbnqkurwrm.supabase.co:5432/postgres

-- ============================================================================
-- STATUS UI CREATION
-- ============================================================================
local function createStatusUI()
    local infoGui = Instance.new('ScreenGui', playerGui)
    infoGui.Name = 'CultivatorStatus'

    local frame = Instance.new('Frame', infoGui)
    frame.Size = UDim2.new(0, 175, 0, 40)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.2

    local label = Instance.new('TextLabel', frame)
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 0, 0)
    label.TextSize = 22
    label.Font = Enum.Font.SourceSansSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    
    return frame, label
end

-- ============================================================================
-- TASK COMPLETION VERIFICATION
-- ============================================================================
local function verifyAllTasksCompleted()
    local allComplete = true
    local failedTasks = {}
    
    for taskName, completed in pairs(TASK_STATUS) do
        if not completed then
            allComplete = false
            table.insert(failedTasks, taskName)
        end
    end
    
    if allComplete then
        print('✅ All tasks completed successfully!')
        allTasksCompleted = true
    else
        warn('⚠️ Some tasks did not complete:')
        for _, taskName in ipairs(failedTasks) do
            warn('  - ' .. taskName)
        end
        allTasksCompleted = false
    end
    
    return allComplete
end

-- ============================================================================
-- MAIN EXECUTION
-- ============================================================================
local function main()
    -- Wait for loading to complete
    waitForLoadingComplete()
    
    -- Create status UI
    local frame, label = createStatusUI()
    
    -- Execute all daily tasks
    updateStatusLabel(label, "Claiming Mail")
    claimMail()
    updateStatusLabel(label, "Claimed Mail")
    wait(CONFIG.UI_UPDATE_DELAY)
    
    updateStatusLabel(label, "Investing Gems")
    investGems()
    updateStatusLabel(label, "Gems Invested")
    wait(CONFIG.UI_UPDATE_DELAY)
    
    updateStatusLabel(label, "Collecting Herbs...")
    collectHerbs()
    updateStatusLabel(label, "Herbs Collected")
    wait(CONFIG.UI_UPDATE_DELAY)
    
    toggleGuildUI(true)
    wait(CONFIG.UI_UPDATE_DELAY)
    
    updateStatusLabel(label, "Guild Contributing...")
    donateToGuild()
    updateStatusLabel(label, "Contributed")
    wait(CONFIG.UI_UPDATE_DELAY)
    
    updateStatusLabel(label, "Herbs Purchasing...")
    purchaseHerbs()
    updateStatusLabel(label, "Herbs Purchased")
    wait(CONFIG.UI_UPDATE_DELAY)
    
    -- Send webhook in background
    task.spawn(function()
        sendWebhook()
    end)

    updateStatusLabel(label, "Spin Wheel...")
    spinWheel()
    updateStatusLabel(label, "Spin Wheel Completed")
    wait(1)
    
    -- Verify all tasks completed
    verifyAllTasksCompleted()
    
    -- Update final status
    if allTasksCompleted then
        frame.Size = UDim2.new(0, 225, 0, 40)
        updateStatusLabel(label, "Daily Cultivator Completed ✅")
    else
        frame.Size = UDim2.new(0, 225, 0, 40)
        updateStatusLabel(label, "Daily Cultivator Finished ⚠️")
    end
    
    wait(10)
    -- Delete the Label UI
    label.Parent = nil
    frame.Parent = nil
    -- game:Shutdown()
end

-- Run main function
main()
