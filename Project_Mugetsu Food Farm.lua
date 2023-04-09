
--[[
    Farm food in Project Mugetsu efficiently using a poorly made priority based system
    to prioritise corps that contain the most exp

    Credits: Kaiden#2444
--]]

local GENERAL_LOOP_DELAY = 0.05

local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Visuals = workspace.World.Visuals
local Remotes = game:GetService("ReplicatedStorage").Remotes.Server.Initiate_Server

local QueuePriority = { --info from trello not sure if its valid
    Arrancar = 1, -- 4xp
    Starrk = 1, 
    Arrogante = 1,
    Toshiro = 1,
    
    Adjucha = 2, -- 3xp
    Shikai_Soul_Reaper = 2, -- 3xp
    Vasto_Lorde = 3, -- 2.75 xp
    Soul_Reaper = 4, -- 2xp
    Base_Hollow = 5, -- 1xp
    Human = 5 -- 1xp
}

local FoodQueue = {}

local function RemoveHoles(t)
    local n = #t
    local j = 0
    for i = 1, n do
        if t[i] ~= nil then
            j = j + 1
            if i ~= j then
                t[j] = t[i]
                t[i] = nil
            end
        end
    end
end

local function UpdateQueue()
    -- Remove any nil elements from the table
    for Index, Food in ipairs(FoodQueue) do
        if not Food or not Food.Parent or Food.Transparency ~= 0 then
            FoodQueue[Index] = nil
        end
    end

    --Remove any holes
    RemoveHoles(FoodQueue)
    
    --Sort the food queue by priority
    pcall(function()
        table.sort(FoodQueue, function(FoodX, FoodY) 
            return (FoodX:GetAttribute("Priority")) < (FoodY:GetAttribute("Priority")) 
        end)
    end)
end

local function OnFoodAdded(Object)
    local ProximityPrompt = Object:WaitForChild("Eat_Part", 5)
    if not ProximityPrompt then return end
    
    if Object.Transparency ~= 0 then return end
    
    local QueueType = Object.amount_of_exp.Value
    local Priority = QueuePriority[QueueType]
    
    if not Priority then
        warn("Unknown queue type:", QueueType)
        return
    end

    if string.find(Object.Name, "Shikai") then
        Object:SetAttribute("Priority", 2)
    else
        Object:SetAttribute("Priority", Priority)
    end
    Object:SetAttribute("Type", QueueType)
    
    table.insert(FoodQueue, Object)
    UpdateQueue()
end

local function IsAlive(Model)
    if not Model or not Model.Parent then return end
    local Humanoid = Model:FindFirstChild("Humanoid")

    if not Humanoid or not Model:FindFirstChild("HumanoidRootPart") then return end
    if Humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
    
    return true
end

--load/populate the food queue 
Visuals.ChildAdded:Connect(OnFoodAdded)
for _, Object in ipairs(Visuals:GetChildren()) do
    task.spawn(OnFoodAdded, Object)
end

--Eat most important food(the one that gives most exp)
local IsEating = false

task.defer(function()
    while _G.IsEnabled do
        task.wait(GENERAL_LOOP_DELAY)

        local Character = Client.Character

        if not IsAlive(Character) then continue end
        Character:PivotTo(CFrame.new(0, 200, 0)) --teleport to secure place
        if IsEating then continue end

        UpdateQueue()
        
        local FoodObject = FoodQueue[1] --first index = food with most priority aka most exp
        if not FoodObject then continue end
        
        IsEating = true
        Remotes:FireServer("Eat_Body_Part", FoodObject)
        
        print("Attempting to eat: "..FoodObject:GetAttribute("Type").." Transparency: "..FoodObject.Transparency)
        
        repeat task.wait(GENERAL_LOOP_DELAY)
            Character:PivotTo(CFrame.new(0, 200, 0)) --teleport to secure place
        until FoodObject.Transparency == 1 or not FoodObject.Parent

        ------task.wait(1)
        
        IsEating = false
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Credits";
    Text = "Script created by: Kaiden#2444";
    Duration = 5;
})
