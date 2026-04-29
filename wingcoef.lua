-- 翅膀数据导出脚本
-- 功能：读取翅膀装备数据，提取第三个属性的名称和数值，写入TSV文件

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

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local player = Players.LocalPlayer

-- Wait for player GUI
while not player:FindFirstChild('PlayerGui') do
    task.wait(1)
end
local playerGui = player.PlayerGui

-- ============================================================================
-- LOADING SCREEN HANDLER
-- ============================================================================
local function waitForLoadingComplete()
    local LOADING_MAX_ATTEMPTS = 30
    local LOADING_TIMEOUT = 10
    
    -- Function to safely find the loading GUI
    local function findLoadingGui()
        for i = 1, LOADING_MAX_ATTEMPTS do
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
            while not visibleChanged and os.time() - startTime < LOADING_TIMEOUT do
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
end

waitForLoadingComplete()

-- 翅膀背包数据搜索函数
local function findArmorBackpackData()
    local bestMatch = nil
    local maxWings = 0
    
    for i, obj in ipairs(getgc(true)) do
        if type(obj) == 'table' then
            -- 检查是否是背包数据（包含"背包"键）
            local backpack = rawget(obj, '\232\131\140\229\140\133') or rawget(obj, '背包')
            if type(backpack) == 'table' then
                local wingCount = 0
                for _, item in pairs(backpack) do
                    if type(item) == 'table' and (rawget(item, '翅膀ID') or rawget(item, 'wingId')) then
                        wingCount = wingCount + 1
                    end
                end
                if wingCount > maxWings then
                    maxWings = wingCount
                    bestMatch = backpack
                end
            else
                -- 如果没有"背包"键，检查是否直接包含翅膀数据
                local wingCount = 0
                for k, v in pairs(obj) do
                    if type(v) == 'table' and (rawget(v, '翅膀ID') or rawget(v, 'wingId')) then
                        wingCount = wingCount + 1
                    end
                end
                if wingCount > maxWings then
                    maxWings = wingCount
                    bestMatch = obj
                end
            end
        end
    end
    
    return bestMatch or {}
end

-- 获取当前装备数据
local armorData = {}

-- 尝试连接翅膀数据同步事件
local armorSyncEvent = nil
local armorSyncSuccess, armorSyncResult = pcall(function()
    return ReplicatedStorage["\228\186\139\228\187\182"]["\229\174\162\230\136\183\231\171\175"]["\229\174\162\230\136\183\231\171\175\232\163\133\229\164\135"]["\232\163\133\229\164\135\230\149\176\230\141\174\229\143\152\229\140\150"]
end)
if armorSyncSuccess then
    armorSyncEvent = armorSyncResult
    print('✓ 已连接翅膀数据同步事件')
    
    -- 监听数据更新
    armorSyncEvent.Event:Connect(function(data)
        armorData = data
        print('✓ 翅膀数据已同步更新')
    end)
end

-- 获取切换装备组事件（用于触发服务器下发装备数据）
local switchArmorSetEvent = nil
local switchArmorSetSuccess, switchArmorSetResult = pcall(function()
    return ReplicatedStorage["\228\186\139\228\187\182"]["\229\133\172\231\148\168"]["\232\163\133\229\164\135"]["\229\136\135\230\141\162\232\163\133\229\164\135\231\187\132"]
end)
if switchArmorSetSuccess then
    switchArmorSetEvent = switchArmorSetResult
    print('✓ 已找到切换装备组事件')
    
    -- 触发事件以获取数据
    pcall(function()
        switchArmorSetEvent:FireServer(1)
        print('✓ 已触发切换装备组事件，请求翅膀数据')
    end)
end

-- 如果同步事件不存在，从内存读取
if not armorSyncEvent then
    print('⚠ 未找到同步事件，从内存读取翅膀数据...')
    armorData = findArmorBackpackData()
end

-- 等待一下让数据加载
task.wait(1)

-- 再次尝试从内存读取（如果同步事件数据为空）
if not armorData or (type(armorData) == 'table' and next(armorData) == nil) then
    print('⚠ 同步数据为空，从内存重新读取...')
    armorData = findArmorBackpackData()
end

-- 提取翅膀数据并导出到TSV
local WEBHOOK_URL = 'https://discord.com/api/webhooks/1427270496797589606/Wg1Lt11GaVxKwrl3vlQCVuG4WqcH2VRkOOrEENCn5I-DHYx5IiXmmxptyIkN81fx_WGP'

-- Function to send Discord webhook
local function SendWebhook(content)
    local success = pcall(function()
        local Request = syn and syn.request or http and http.request or request
        if Request then
            Request({
                Url = WEBHOOK_URL,
                Method = 'POST',
                Headers = { ['Content-Type'] = 'application/json' },
                Body = game:GetService('HttpService'):JSONEncode({
                    content = content,
                }),
            })
        else
            warn("Request function not found (executor might not support http requests)")
        end
    end)
    return success
end

local ATTRIBUTE_TRANSLATIONS = {
    ["移动速度百分比"] = "Movement Speed",
    ["怪物伤害抗性"] = "Mob Damage Resistance",
    ["玩家伤害"] = "Damage To Player",
    ["最终攻击力百分比"] = "Attack Boost Multiplier",
    ["玩家伤害抗性"] = "Player Damage Resistance",
    ["最终生命值百分比"] = "Hp Boost Multiplier",
    ["怪物伤害"] = "Damage To Mob"
}

local rarityMap = {
  scarce = 6,
  epic = 7,
  legendary = 8,
  immortal = 9,
  myth = 10,
  eternal = 11,
  celestial = 12,
}

local level = playerGui.GUI['\228\184\187\231\149\140\233\157\162' --[[Secondary Interface]]]['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\231\173\137\231\186\167']['\230\140\137\233\146\174']['\229\155\190\230\160\135']['\231\173\137\231\186\167'].text

local function calculateWingsCoefficient(wingsPercentage, level, rarityValue)
    -- print(wingsPercentage, level, rarityValue)
    local denominator = (0.05 + (level - 1) * 0.0000555555555555556) * (1 + (rarityValue - 5) * 0.1) * 6.25 * ((rarityValue - 5) / 7);
    return math.round((wingsPercentage / denominator / 100) * 1000) / 1000;
end

-- 提取翅膀数据并发送到 Discord Webhook
local function notifyWingsToWebhook()
    local wingsToProcess = armorData
    
    -- 处理数据结构：如果包含"背包"键，使用背包数据
    if armorData and type(armorData) == 'table' then
        if armorData['\232\131\140\229\140\133'] or armorData['背包'] then
            wingsToProcess = armorData['\232\131\140\229\140\133'] or armorData['背包']
        end
    end
    
    if not wingsToProcess or (type(wingsToProcess) == 'table' and next(wingsToProcess) == nil) then
        print('❌ Error: Wings data not found')
        return
    end
    
    print('=' .. string.rep('=', 60))
    print('Starting Wing Export to Webhook...')
    
    local wingCount = 0
    local processedCount = 0
    local webhookLines = {}
    local decentWings = 0
    local processedIds = {}
    
    -- Add Header
    table.insert(webhookLines, "### 🦅 " .. Players.LocalPlayer.Name .. " | Wing Export Summary")
    table.insert(webhookLines, "--------------------------------------------------")
    
    -- 遍历所有物品
    for _, item in pairs(wingsToProcess) do
        processedCount = processedCount + 1
        
        if type(item) == 'table' then
            -- 检查是否是翅膀
            local isWing = item['翅膀ID'] 
                or (type(item.wingId) == 'number' and item.wingId > 0)
                or item.wingId
            
            if isWing then
                -- 获取物品ID（实例ID，不是类别ID）
                local equipId = item['索引'] 
                    or item.Index
                    or item['id']
                    or item.id
                    or item['ref']
                    or item.refWingsCoefCheck.lua
                    or 'Unknown'
                
                -- Prevent duplicates
                if not processedIds[equipId] then
                    processedIds[equipId] = true

                    -- 获取第三个属性
                    local thirdAttrName = 'None'
                    local thirdAttrValue = 'None'
                    local rarityValue = 'None'
                    
                    if item['属性'] and type(item['属性']) == 'table' then
                        if #item['属性'] >= 3 then
                            local thirdAttr = item['属性'][3]
                            if thirdAttr and type(thirdAttr) == 'table' then
                                -- 获取属性名称
                                local rawName = thirdAttr['名称'] 
                                    or thirdAttr.name 
                                    or 'Unknown Attribute'
                                
                                -- Translate attribute name if mapping exists
                                thirdAttrName = ATTRIBUTE_TRANSLATIONS[rawName] or rawName
                                
                                -- 获取属性数值（系数）
                                local value = thirdAttr['系数'] 
                                    or thirdAttr.coefficient
                                    or thirdAttr['数值']
                                    or thirdAttr.value
                                    or thirdAttr['值']
                                
                                if value ~= nil then
                                    if type(value) == 'number' then
                                        thirdAttrValue = tostring(value)
                                    else
                                        thirdAttrValue = tostring(value)
                                    end
                                else
                                    thirdAttrValue = 'None'
                                end
                                
                                if thirdAttrValue ~= 'None' then
                                    if tonumber(thirdAttrValue) >= 1.48 then
                                        decentWings = decentWings + 1
                                        local args = {
                                            tostring(equipId)
                                        }
                                        game:GetService("ReplicatedStorage"):WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\232\163\133\229\164\135"):WaitForChild("\230\148\182\232\151\143\232\163\133\229\164\135"):FireServer(unpack(args))
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                    
                    wingCount = wingCount + 1
                    
                    -- Calculate Coefficient
                    local currentLevel = tonumber(level:match("%d+")) or 1
                    local currentRarity = rarityMap[item['稀有度'] or item.rarity or 'None'] or 0

                    -- Format for Webhook
                    local wingTypeId = item['翅膀ID'] or item.wingId or 'None'
                    local line = string.format("Wing %d: ID `%s` | Attr: `%s` | Val: `%s`", 
                        wingCount, tostring(equipId), tostring(thirdAttrName), tostring(thirdAttrValue))
                    table.insert(webhookLines, line)
                    
                    -- 打印到控制台
                    -- print(string.format('Wing %d: Item ID=%s (Type ID=%s), Attribute=%s, Value=%s', 
                    --     wingCount, 
                    --     tostring(equipId),
                    --     tostring(wingTypeId),
                    --     tostring(thirdAttrName),
                    --     tostring(thirdAttrValue)
                    -- ))
                end
            end
        end
    end
    
    table.insert(webhookLines, "--------------------------------------------------")
    table.insert(webhookLines, string.format("**Total Wings Found: %d**", wingCount))
    table.insert(webhookLines, string.format("**Decent Wings Found: %d**", decentWings))
    
    -- print('=' .. string.rep('=', 60))
    -- print(string.format('Processing complete! found %d wings, processed %d items', wingCount, processedCount))
    
    if wingCount == 0 then
        print('⚠ Warning: No wings found')
        return
    end
    
    -- Send Webhook content
    local content = table.concat(webhookLines, "\n")
    writefile("WingsCoefCheck.txt", content)
    -- if sendWebhook return success -> game:Shutdown() else -> game:Shutdown()
    local success = SendWebhook(content)
    if success then
        print('✓ Discord Notification Sent')
        -- game:Shutdown()
    else
        print('✗ Discord Notification Failed')
        -- game:Shutdown()
    end
end

-- 延迟执行导出（等待数据加载）
task.spawn(function()
    task.wait(2) -- 等待2秒确保数据加载完成
    notifyWingsToWebhook()
end)

print('=' .. string.rep('=', 60))
print('Wing Data Export Script Started')
print('Waiting for data to load...')
print('=' .. string.rep('=', 60))
