local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Ensure player is loaded
local player = Players.LocalPlayer
repeat task.wait() until player:IsDescendantOf(game)

-- Elixir type mapping
local elixirTypes = {
    [1] = "Attack",
    [2] = "CritDmg", 
    [3] = "TalismanDmg",
    [4] = "HealthPoint",
    [5] = "SkillDmg"
}

-- Quality points mapping
local qualityPoints = {
    [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5,
    [6] = 6, [7] = 8, [8] = 10, [9] = 14, [10] = 20,
    [11] = 28
}

-- Create UI interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ElixirTradeMaster"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame - Adjusted per your requirements
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.5, 0, 0, 380) -- Width 50%, Height 380 pixels
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centered
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title bar (draggable)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
titleBar.Parent = mainFrame

-- Fold button
local foldButton = Instance.new("TextButton")
foldButton.Text = "▼"
foldButton.Size = UDim2.new(0, 40, 1, 0)
foldButton.Font = Enum.Font.SourceSansBold
foldButton.TextSize = 16
foldButton.TextColor3 = Color3.new(1, 1, 1)
foldButton.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
foldButton.Parent = titleBar
foldButton.Name = "FoldButton"

local title = Instance.new("TextLabel")
title.Text = "Elixir Trade Master v1.0"
title.Size = UDim2.new(1, -80, 1, 0)  -- Adjust position
title.Position = UDim2.new(0, 40, 0, 0)  -- Make room for fold button
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Parent = titleBar

-- 关闭按钮
local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 40, 1, 0)
closeButton.Position = UDim2.new(1, -40, 0, 0)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Parent = titleBar

-- Total points display
local totalPointsLabel = Instance.new("TextLabel")
totalPointsLabel.Text = "Total Elixir Points: Calculating..."
totalPointsLabel.Size = UDim2.new(0.9, 0, 0, 25)
totalPointsLabel.Position = UDim2.new(0.05, 0, 0, 40)
totalPointsLabel.Font = Enum.Font.SourceSansSemibold
totalPointsLabel.TextSize = 16
totalPointsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
totalPointsLabel.BackgroundTransparency = 1
totalPointsLabel.TextXAlignment = Enum.TextXAlignment.Left
totalPointsLabel.Parent = mainFrame

-- Create 5 input boxes and points display
local inputFrames = {}
local pointsLabels = {}
for i = 1, 5 do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.Position = UDim2.new(0.05, 0, 0, 65 + (i-1)*55)
    frame.BackgroundTransparency = 1
    frame.Parent = mainFrame
    
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Text = elixirTypes[i].." Elixir:"
    typeLabel.Size = UDim2.new(0.3, 0, 0, 20)
    typeLabel.Position = UDim2.new(0, 0, 0, 0)
    typeLabel.Font = Enum.Font.SourceSansSemibold
    typeLabel.TextSize = 14
    typeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.BackgroundTransparency = 1
    typeLabel.Parent = frame
    
    local pointsLabel = Instance.new("TextLabel")
    pointsLabel.Name = "Points_"..i
    pointsLabel.Text = "Total Points: 0"
    pointsLabel.Size = UDim2.new(0.7, 0, 0, 20)
    pointsLabel.Position = UDim2.new(0.3, 0, 0, 0)
    pointsLabel.Font = Enum.Font.SourceSans
    pointsLabel.TextSize = 12
    pointsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    pointsLabel.TextXAlignment = Enum.TextXAlignment.Left
    pointsLabel.BackgroundTransparency = 1  -- Fixed here, was corrupted before
    pointsLabel.Parent = frame
    pointsLabels[i] = pointsLabel
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "Input_"..i
    textBox.Size = UDim2.new(1, 0, 0, 25)
    textBox.Position = UDim2.new(0, 0, 0, 20)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    textBox.TextColor3 = Color3.new(1, 1, 1) 
    textBox.PlaceholderText = "Enter "..elixirTypes[i].." points"
    textBox.Text = ""
    textBox.TextSize = 14
    textBox.Parent = frame
    
    inputFrames[i] = textBox
    
    local exampleLabel = Instance.new("TextLabel")
    exampleLabel.Text = "Example: Enter 1000 to auto-calculate optimal combination"
    exampleLabel.Size = UDim2.new(1, 0, 0, 15)
    exampleLabel.Position = UDim2.new(0, 0, 0, 45)
    exampleLabel.Font = Enum.Font.SourceSans
    exampleLabel.TextSize = 11
    exampleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    exampleLabel.TextXAlignment = Enum.TextXAlignment.Left
    exampleLabel.BackgroundTransparency = 1
    exampleLabel.Parent = frame
end

-- Button Area
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(0.9, 0, 0, 60)
buttonFrame.Position = UDim2.new(0.05, 0, 0, 70 + 5*55)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- Refresh Button
local refreshButton = Instance.new("TextButton")
refreshButton.Text = "Refresh Elixir Data"
refreshButton.Size = UDim2.new(0.45, 0, 0, 30)
refreshButton.Position = UDim2.new(0, 0, 0, 0)
refreshButton.Font = Enum.Font.SourceSansBold
refreshButton.TextSize = 14
refreshButton.TextColor3 = Color3.new(1, 1, 1) 
refreshButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
refreshButton.Parent = buttonFrame

-- Trade Button
local tradeButton = Instance.new("TextButton")
tradeButton.Text = "Put into Trade"
tradeButton.Size = UDim2.new(0.45, 0, 0, 30)
tradeButton.Position = UDim2.new(0.55, 0, 0, 0)
tradeButton.Font = Enum.Font.SourceSansBold
tradeButton.TextSize = 14
tradeButton.TextColor3 = Color3.new(1, 1, 1) 
tradeButton.BackgroundColor3 = Color3.fromRGB(80, 120, 80)
tradeButton.Parent = buttonFrame

-- Status Display
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "System Ready, Waiting for Operation..."
statusLabel.Size = UDim2.new(0.9, 0, 0, 35)
statusLabel.Position = UDim2.new(0.05, 0, 0, 65 + 5*55 + 65)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(80, 120, 80)
statusLabel.TextWrapped = true
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = mainFrame

-- Get Remote Events
local elixirSyncEvent = ReplicatedStorage
    ["\228\186\139\228\187\182"]          -- Remote
    ["\229\174\162\230\136\183\231\171\175"] -- Sync Module
    ["\229\174\162\230\136\183\231\171\175\228\184\185\232\141\175"] -- Elixir Controller
    ["\228\184\185\232\141\175\230\149\176\230\141\174\229\143\152\229\140\150"] -- Data Update Event

local addTradeItemEvent = ReplicatedStorage
    ["\228\186\139\228\187\182"]  -- Remote
    ["\229\133\172\231\148\168"]  -- Public
    ["\228\186\164\230\152\147"]  -- Trade
    ["\230\150\176\229\162\158\228\186\164\230\152\147\231\137\169\229\147\129"] -- Add Trade Item

local confirmTradeEvent = ReplicatedStorage
    ["\228\186\139\228\187\182"]  -- Remote
    ["\229\133\172\231\148\168"]  -- Public
    ["\228\186\164\230\152\147"]  -- Trade
    :WaitForChild("\233\148\129\229\174\154\228\186\164\230\152\147") -- Lock Trade

-- Elixir Data Storage
local elixirData = {}

-- Data Sync Processing
elixirSyncEvent.Event:Connect(function(data)
    elixirData = data
end)

-- Debug Print Elixir Data
local function debugPrintElixirData()
    if not elixirData then
        print("No Elixir Data Obtained")
        return
    end
    
    local backpack = elixirData[BACKPACK_KEY] or {}
    
    -- Print first 10 items as example
    for i = 1, math.min(10, #backpack) do
        local item = backpack[i]
        if item and type(item) == "table" then
            -- Get Fields
            local itemType = item[TYPE_KEY] or "Unknown"
            local quality = item[QUALITY_KEY] or "Unknown"
            local count = item[COUNT_KEY] or "Unknown"
            local index = item[INDEX_KEY] or "No Index"
            
            print(string.format("Item %d: Type=%s, Quality=%s, Count=%s, Index=%s", 
                i, itemType, quality, count, index))
        else
            print("Item " .. i .. ": Invalid Data Format")
        end
    end
end

-- Cache backpack data keys to avoid repeated lookups
local BACKPACK_KEY = "\232\131\140\229\140\133"
local COUNT_KEY = "\230\149\176\233\135\143"
local TYPE_KEY = "\231\177\187\229\158\139"
local QUALITY_KEY = "品质"
local INDEX_KEY = "索引"

-- Calculate Elixir Points (Optimized: reduce table lookups and type conversions)
local function calculateElixirPoints()
    if not elixirData then
        warn("Unable to obtain Elixir Data")
        return {}, 0
    end
    
    debugPrintElixirData()
    
    local backpack = elixirData[BACKPACK_KEY]
    if not backpack or #backpack == 0 then
        warn("No items in Backpack")
        return {}, 0
    end
    
    local typeTotals = {0, 0, 0, 0, 0}  -- Total points per type
    local grandTotal = 0                -- Grand total points
    
    -- Iterate through backpack items (Optimized: reduce function calls)
    local item, count, elixirType, quality, points
    for i = 1, #backpack do
        item = backpack[i]
        if item and type(item) == "table" then
            -- Safe field access (cached lookup results)
            count = item[COUNT_KEY]
    if count then
                count = tonumber(count) or 0
                if count > 0 then
                    elixirType = item[TYPE_KEY]
                    if elixirType then
                        elixirType = tonumber(elixirType) or 0
                        if elixirType >= 1 and elixirType <= 5 then
                            quality = item[QUALITY_KEY]
                            if quality then
                                quality = tonumber(quality) or 0
                                points = qualityPoints[quality]
                                if points then
                                    points = points * count
                                    typeTotals[elixirType] = typeTotals[elixirType] + points
                                    grandTotal = grandTotal + points
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return typeTotals, grandTotal
end

-- Smart Elixir Combination Algorithm (Optimized: dynamic programming, less allocation)
local function calculateElixirs(targetPoints, availableElixirs, adjustRange)
    adjustRange = adjustRange or 50 -- Allowed adjustment range
    
    if #availableElixirs == 0 then
        return {}, 0
    end

    -- Sort points ascending (Optimized: more efficient comparison)
    table.sort(availableElixirs, function(a, b) 
        return a.points < b.points 
    end)

    -- Pre-allocate used table, reduced memory allocation
    local used = {}
    local elixir, usedItem
    for i = 1, #availableElixirs do
        elixir = availableElixirs[i]
        used[i] = {
            type = elixir.type, 
            quality = elixir.quality, 
            count = 0, 
            points = elixir.points, 
            index = elixir.index
        }
    end

    local currentPoints = 0
    local targetMinusRange = targetPoints - adjustRange

    -- Phase 1: Greedy approach near target (don't exceed too much)
    for i = 1, #availableElixirs do
        elixir = availableElixirs[i]
        usedItem = used[i]
        local points = elixir.points
        
        -- Calculate max quantity to add, not exceeding target too much
        if currentPoints < targetPoints then
            local needPoints = targetPoints - currentPoints
            local maxCount = math.ceil(needPoints / points)  -- Round up to at least meet target
            local take = math.min(maxCount, elixir.count)
            usedItem.count = take
            currentPoints = currentPoints + points * take
        else
            -- If already reached target, try adding more within allowed range
            local maxCount = math.floor((targetMinusRange + adjustRange - currentPoints) / points)
            if maxCount > 0 then
                local take = math.min(maxCount, elixir.count)
                usedItem.count = take
                currentPoints = currentPoints + points * take
            end
        end
    end

    local diff = targetPoints - currentPoints

    -- Phase 2: If target not reached, use DP to supplement (ensure >= target)
    if diff > 0 then
        -- Generate candidate elixirs for supplement (remaining quantity)
        local smallElixirs = {}
        local remain
        for i = 1, #availableElixirs do
            remain = availableElixirs[i].count - used[i].count
            if remain > 0 then
                smallElixirs[#smallElixirs + 1] = {
                    index = i, 
                    points = availableElixirs[i].points, 
                    count = remain
                }
            end
        end

        if #smallElixirs > 0 then
            -- Backpack search range: reach at least diff, at most diff + adjustRange
            local minPoints = diff  -- Must meet target
            local maxPoints = diff + adjustRange  -- Not too far over
            
            -- Use array instead of hash table for speed
            local dp = {}
            dp[0] = {}
            local dpKeys = {0}
            local dpKeysCount = 1

            -- Binary optimization backpack (optimized: reduce items)
            for i = 1, #smallElixirs do
                local e = smallElixirs[i]
                local items = {}
                local c = e.count
                local k = 1
                while c > 0 do
                    local take = math.min(k, c)
                    items[#items + 1] = {index = e.index, points = e.points, count = take}
                    c = c - take
                    k = k * 2
                end

                -- Update DP (optimized: use temp table to reduce allocation)
                local newDP = {}
                local newKeys = {}
                local newKeysCount = 0
                
                for j = 1, dpKeysCount do
                    local s = dpKeys[j]
                    local combo = dp[s]
                    if combo then
                        for _, item in ipairs(items) do
                            local newS = s + item.points * item.count
                            -- Only consider solutions in [minPoints, maxPoints] range
                            if newS >= minPoints and newS <= maxPoints and not dp[newS] then
                                local newCombo = {}
                                for k = 1, #combo do
                                    newCombo[k] = combo[k]
                                end
                                newCombo[#newCombo + 1] = {index = item.index, count = item.count}
                                newDP[newS] = newCombo
                                newKeysCount = newKeysCount + 1
                                newKeys[newKeysCount] = newS
                            end
                        end
                    end
                end
                
                -- Merge new states
                for j = 1, newKeysCount do
                    local s = newKeys[j]
                    if not dp[s] then
                        dp[s] = newDP[s]
                        dpKeysCount = dpKeysCount + 1
                        dpKeys[dpKeysCount] = s
                    end
                end
            end

            -- Find closest solution >= diff (ensure meeting target)
            local best = nil
            local bestPoints = math.huge
            for j = 1, dpKeysCount do
                local s = dpKeys[j]
                -- Only consider solutions >= diff (at least target points)
                if s >= diff and s < bestPoints then
                    bestPoints = s
                    best = dp[s]
                end
            end

            -- Apply supplement
            if best then
                for j = 1, #best do
                    local v = best[j]
                    used[v.index].count = used[v.index].count + v.count
                    currentPoints = currentPoints + availableElixirs[v.index].points * v.count
                end
            else
                -- If DP finds no solution, use greedy to at least reach target
                for i = 1, #smallElixirs do
                    local e = smallElixirs[i]
                    if currentPoints < targetPoints then
                        local needPoints = targetPoints - currentPoints
                        local needCount = math.ceil(needPoints / e.points)
                        local take = math.min(needCount, e.count)
                        if take > 0 then
                            used[e.index].count = used[e.index].count + take
                            currentPoints = currentPoints + e.points * take
                        end
                    else
                        break
                    end
                end
            end
        end
    end

    print(string.format("[Elixir Optimization] Target: %d, Actual: %d, Diff: %+d", targetPoints, currentPoints, currentPoints - targetPoints))

    -- Filter out zero counts (Optimized: pre-allocate table)
    local finalCombo = {}
    for i = 1, #used do
        local v = used[i]
        if v.count > 0 then
            finalCombo[#finalCombo + 1] = v
        end
    end

    return finalCombo, currentPoints
end


-- Execute trade operation (Optimized: reduce data access and string operations)
tradeButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Calculating optimal elixir combination..."
    task.wait(0.1)
    
    -- Get input points requirement (Optimized: reduce loops and function calls)
    local requirements = {}
    local input, text
    for i = 1, 5 do
        text = inputFrames[i].Text
        if text and text ~= "" then
            input = tonumber(text)
            if input and input > 0 then
                requirements[i] = input
            end
        end
    end
    
    if not next(requirements) then
        statusLabel.Text = "Error: Please enter at least one elixir type points"
        return
    end
    
    -- Check for elixir data (Optimized: use cached keys)
    local backpack = elixirData and elixirData[BACKPACK_KEY]
    if not backpack or #backpack == 0 then
        statusLabel.Text = "Error: No elixir data obtained, please refresh first"
        return
    end
    
    -- Prepare available elixirs (Optimized: reduce table lookup and type conversion)
    local availableElixirs = {}
    local item, count, elixirType, quality, index, points
    for i = 1, #backpack do
        item = backpack[i]
        if item and type(item) == "table" then
            count = item[COUNT_KEY]
            if count then
                count = tonumber(count) or 0
                if count > 0 then
                    elixirType = item[TYPE_KEY]
                    if elixirType then
                        elixirType = tonumber(elixirType) or 0
                        if elixirType >= 1 and elixirType <= 5 then
                            quality = item[QUALITY_KEY]
                            if quality then
                                quality = tonumber(quality) or 0
                                points = qualityPoints[quality]
                                if points then
                                    index = item[INDEX_KEY]
                                    if index and index ~= "" then
                                        availableElixirs[#availableElixirs + 1] = {
                                            type = elixirType,
                                            quality = quality,
                                            count = count,
                                            points = points,
                                            index = index
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if #availableElixirs == 0 then
        statusLabel.Text = "Error: No available elixirs"
        return
    end
    
    -- Group by type (Optimized: pre-allocate table)
    local elixirsByType = {}
    local elixir, typeList
    for i = 1, #availableElixirs do
        elixir = availableElixirs[i]
        typeList = elixirsByType[elixir.type]
        if not typeList then
            typeList = {}
            elixirsByType[elixir.type] = typeList
        end
        typeList[#typeList + 1] = elixir
    end
    
    -- Process each requirement (Optimized: use array instead of pairs)
    local tradeResults = {}
    local usedElixirs, totalPoints, result
    for elixirType = 1, 5 do
        if requirements[elixirType] then
            typeList = elixirsByType[elixirType]
            if typeList and #typeList > 0 then
                usedElixirs, totalPoints = calculateElixirs(requirements[elixirType], typeList)
                tradeResults[#tradeResults + 1] = {
                    type = elixirType,
                    target = requirements[elixirType],
                    achieved = totalPoints,
                    elixirs = usedElixirs
                }
            end
        end
    end
    
    if #tradeResults == 0 then
        statusLabel.Text = "No valid trade requirements"
        return
    end
    
    -- Show results and execution (Optimized: use table.concat)
    local resultParts = {"【Trade Scheme】"}
    local elixirTypeName
    for i = 1, #tradeResults do
        result = tradeResults[i]
        elixirTypeName = elixirTypes[result.type]
        resultParts[#resultParts + 1] = string.format("%s Elixir: Demand %d -> Actual %d", 
            elixirTypeName, result.target, result.achieved)
        
        -- Add items to trade
        for j = 1, #result.elixirs do
            elixir = result.elixirs[j]
            addTradeItemEvent:FireServer("丹药", elixir.index, elixir.count)
            resultParts[#resultParts + 1] = string.format(" - Putting %d %s Elixir (Qual %d, %d pts)",
                elixir.count, elixirTypeName, elixir.quality, elixir.points)
        end
    end
    
    resultParts[#resultParts + 1] = "\nTrade items automatically placed!"
    statusLabel.Text = table.concat(resultParts, "\n")
end)

-- Refresh button feature (Optimized: lower wait and UI updates)
refreshButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Refreshing data..."
    task.wait(0.05)  -- Reduced wait
    
    -- Wait for data update (Optimized: os.clock() for precision)
    local startTime = os.clock()
    local timeout = 5
    while not elixirData or not elixirData[BACKPACK_KEY] do
        if os.clock() - startTime > timeout then
            statusLabel.Text = "Error: Timeout obtaining elixir data"
            return
        end
        task.wait(0.05)  -- Lower wait interval
    end
    
    local typeTotals, grandTotal = calculateElixirPoints()
    totalPointsLabel.Text = "Total Elixir Points: " .. tostring(grandTotal)
    
    -- Bulk update UI (Optimized: lower string formatting)
    local total, quality8Count
    for i = 1, 5 do
        total = typeTotals[i]
        quality8Count = math.floor(total / 10)
        pointsLabels[i].Text = string.format("Total: %d (~%d Qual 8)", total, quality8Count)
    end
    
    statusLabel.Text = "Data Refresh Complete " .. os.date("%H:%M:%S")
end)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Window drag functionality (Optimized: less events and calculation)
local dragging = false
local dragStart, startPos
local connection

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        -- Optimized: connect once
        if connection then
            connection:Disconnect()
        end
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Fold functionality (Optimized: cache children)
local isFolded = false
local originalSize = mainFrame.Size
local foldedSize = UDim2.new(0.5, 0, 0, 40)  -- Title bar height only
local childrenCache = {}  -- Cache children list

-- Initialize Cache
do
    local children = mainFrame:GetChildren()
    for i = 1, #children do
        if children[i] ~= titleBar then
            childrenCache[#childrenCache + 1] = children[i]
        end
    end
end

foldButton.MouseButton1Click:Connect(function()
    isFolded = not isFolded
    
    if isFolded then
        -- Fold UI (Title bar only)
        mainFrame.Size = foldedSize
        foldButton.Text = "▲"
        
        -- Hide all content (using cache)
        for i = 1, #childrenCache do
            childrenCache[i].Visible = false
        end
    else
        -- Unfold UI
        mainFrame.Size = originalSize
        foldButton.Text = "▼"
        
        -- Show all content (using cache)
        for i = 1, #childrenCache do
            childrenCache[i].Visible = true
        end
    end
end)

-- Initial refresh (optimized: add error handling, use task.wait)
task.spawn(function()
    refreshButton.MouseButton1Click:Wait()
    task.wait(0.2)  -- Reduced wait time
    
    -- Safely get event (optimized: add error handling)
    local elixirModule = ReplicatedStorage:FindFirstChild("\228\186\139\228\187\182")
    if elixirModule then
        local functionModule = elixirModule:FindFirstChild("\229\133\172\231\148\168")
        if functionModule then
            local refreshModule = functionModule:FindFirstChild("\231\130\188\228\184\185")
            if refreshModule then
                local elixirEvent = refreshModule:FindFirstChild("\229\136\182\228\189\156")
                if elixirEvent then
                    elixirEvent:FireServer()
                end
            end
        end
    end
end)

