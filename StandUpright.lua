if not game:IsLoaded() then 
    game.Loaded:Wait()
end

--//Dependencies
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/uwuware-ui/main/main.lua"))()
local MaidClass = loadstring(game:HttpGet("https://raw.githubusercontent.com/Quenty/NevermoreEngine/version2/Modules/Shared/Events/Maid.lua"))()

--//Variables
local Client = Players.LocalPlayer

local DataFolder = Client:WaitForChild("Data")
local QuestFolder = DataFolder:WaitForChild("Quests")

local ClientStand = DataFolder:WaitForChild("Stand")
local ClientAttribute = DataFolder:WaitForChild("Attri")

local Window = Library:CreateWindow("Noob Upright")

local MainFolder = Window:AddFolder("Main")
local StandFolder = Window:AddFolder("Stand Farm")
local ShopFolder = Window:AddFolder("Shop")
local MiscFolder = Window:AddFolder("Misc")
local CreditsFolder = Window:AddFolder("Credits")

local Map = workspace.Map
local ItemFolder = workspace.Items
local NPCFolder = Map:FindFirstChild("NPCs")
local LivingFolder = workspace.Living

local TargetMob = nil
local LastAttack = 0 

local CurrentMaid = MaidClass.new()

local WhitelistedStands = {"dtw", "jotarosstarplatinum", "pm"}
local WhitelistedAttributes = {"godly", "legendary", "invincible", "daemon"}

local NoclipParts = {}
local MobValues = {"Bad Gi", "Jotaro Over Heaven"}
local StandList = {}
local StandBlacklist = {"CauldronBlack", "TalkingBen", "GER"}
local QuestList = {
    ["Bad Gi"] = "1+",
    ["Giorno Giovanna"] = "5+",
    ["Scary Monster"] = "10+",
    ["Rker Dummy"] = "15+",
    ["Dio Over Heaven"] = "25+",
    ["Yoshikage Kira"] = "30+",
    ["Angelo"] = "40+",
    ["Alien"] = "50+",
    ["Jotaro Part 4"] = "65+",
    ["Kakyoin"] = "75+",
    ["Jungle Bandit"] = "90+",
}

--//Functions
local function AddNoclipParts(Character)
    NoclipParts = {}
    Character:WaitForChild("Head")
    for _, BasePart in pairs(Character:GetChildren()) do
        if not BasePart:IsA("BasePart") then continue end
        NoclipParts[#NoclipParts + 1] = BasePart
    end
end

local function IsAlive(Model)
    if not Model or not Model.Parent then return end
    local Humanoid = Model:FindFirstChildWhichIsA("Humanoid")

    if not Humanoid or not Model:FindFirstChild("HumanoidRootPart") then return end
    if Humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
    
    return true
end

local function GetQuest()
    local NPC = QuestList[Library.flags.Target]
    if not NPC then return end

    local Boss = LivingFolder:FindFirstChild("Boss")
    if Boss and Library.flags.LairFarm then
        TargetMob = Boss
        return
    end 

    for _, Folder in ipairs(QuestFolder:GetChildren()) do 
        local EnemyObject = Folder:FindFirstChild("Enemy")

        if EnemyObject and EnemyObject.Value == Library.flags.Target then
            if Folder.Completed.Value then
                NPC.QuestDone:FireServer()
            end
            return
        end 
    end

    NPC.Done:FireServer() --get quest
end

local function Attack()
    local Character = Client.Character
    if not Character then return end

    local EventFolder = Character:FindFirstChild("StandEvents")
    if not EventFolder then return end
    
    EventFolder.M1:FireServer()

    if Library.flags.StandAttack then        
        local Stand = Character:FindFirstChild("Stand")
        if not Stand then return end

        if not Character.Aura.Value then
            EventFolder.Summon:FireServer()
        end
        
        if os.clock() - LastAttack < 1 then return end --lag prevention
        LastAttack = os.clock()

        for _, Event in ipairs(EventFolder:GetChildren()) do 
            if Event.Name == "Block" then continue end
            if Event.Name == "Quote" then continue end
            if Event.Name == "Pose" then continue end
            if Event.Name == "Summon" then continue end
            if Event.Name == "TogglePilot" then continue end
            
            Event:FireServer(true)
        end 
    end 
end

local function GetItem(Tool)
    if not Library.flags.Itemfarm then return end
    if not Tool:IsA("Tool") then return end
    local Handle = Tool:WaitForChild("Handle", 5)

    local Character = Client.Character
    if not Character then return end

    repeat
        Character.HumanoidRootPart.CFrame = Handle.CFrame * CFrame.new(0, 0, 3)
        task.wait(2)
        Character.Humanoid:EquipTool(Tool)
    until not Tool or Tool.Parent ~= ItemFolder or Tool.Parent ~= workspace
end

local function RunGetItem()
    if not Library.flags.Itemfarm then return end

    for _, Tool in ipairs(ItemFolder:GetChildren()) do
        GetItem(Tool)
    end

    for _, Tool in ipairs(workspace:GetChildren()) do
        GetItem(Tool)
    end
end 

local function SetTargetMob()
    if Library.flags.LairFarm and LivingFolder:FindFirstChild("Boss") then 
        TargetMob = LivingFolder.Boss
        return 
    end

    for _, Mob in ipairs(LivingFolder:GetChildren()) do 
        if Players:GetPlayerFromCharacter(Mob) then continue end
        if not IsAlive(Mob) then continue end
        if Mob.Name ~= Library.flags.Target then continue end

        TargetMob = Mob
        return
    end
    
    --do something if no mobs are there

end

local function GetLair()
    if not Library.flags.LairFarm then return end

    for _, NPC in ipairs(NPCFolder:GetChildren()) do --eeeeeeeeee
        if not NPC:FindFirstChild("Head") then continue end

        local SubUI = NPC.Head:FindFirstChild("Sub")
        if not SubUI or not SubUI:FindFirstChildWhichIsA("TextBox") or SubUI:FindFirstChildWhichIsA("TextBox").Text ~= "Lair Quest" then continue end

        local MainUI = NPC.Head:FindFirstChild("Main")
        if not MainUI then continue end

        local TextBox = MainUI:FindFirstChildWhichIsA("TextBox")
        if not TextBox then continue end
        
        if string.lower(TextBox.Text):find(string.lower(Library.flags.LairTarget.."+")) then
            NPC.Done:FireServer()
        end
    end
end

local function OnCharacterAdded(Character)
    CurrentMaid:DoCleaning()

    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character:WaitForChild("Humanoid")

    CurrentMaid:GiveTask(RunService.Heartbeat:Connect(function()
        if not Library.flags.MobFarm then return end
        if not IsAlive(Character) then return end

        if not IsAlive(TargetMob) or TargetMob.Name ~= Library.flags.Target and TargetMob.Name ~= "Boss" then
            return SetTargetMob()
        end

        if Library.flags.AutoQuest then --auto quest
            GetQuest()
        end
        
        HumanoidRootPart.CFrame = TargetMob.HumanoidRootPart.CFrame * CFrame.new(0, Library.flags.MobDistance, 0) * CFrame.Angles(math.rad(90), 0, 0)
        Attack(Character)
    end))
    CurrentMaid:GiveTask(RunService.Stepped:Connect(function()
        if not Library.flags.MobFarm then return end

        for Index = 1, #NoclipParts do --noclip
            NoclipParts[Index].CanCollide = false
        end

        if HumanoidRootPart.RotVelocity.Magnitude >= 50 or HumanoidRootPart.Velocity.Magnitude >= 50 then --fling prevention
            HumanoidRootPart.RotVelocity = Vector3.new()
            HumanoidRootPart.Velocity = Vector3.new()
        end
    end))

    --calls
    AddNoclipParts(Character)
    GetLair()
    RunGetItem()
end

--//Init
Client.CharacterAdded:Connect(OnCharacterAdded)
if Client.Character then
    task.spawn(OnCharacterAdded, Client.Character)
end

ItemFolder.ChildAdded:Connect(GetItem)
workspace.ChildAdded:Connect(GetItem)

local OldNameCall; OldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...) --anti cheat bypass
    local Method = getnamecallmethod()
 
    if Method == "Raycast" or Method == "Kick" or Method == "FireServer" and tostring(self) == "PlayerStandMainHandle" then
        return wait(9e9)
    end 
    
    return OldNameCall(self, ...)
end))

for _, Connection in pairs(getconnections(Client.Idled)) do --anti afk
    Connection:Disable()
end

for _, QuestNPC in ipairs(NPCFolder:GetChildren()) do --Quests
    if not QuestNPC:FindFirstChild("Head") then continue end
    local MainUI = QuestNPC.Head:FindFirstChild("Main")
    if not MainUI then continue end
    local TextBox = MainUI:FindFirstChildWhichIsA("TextBox")
    if not TextBox then continue end
 
    for MobName, NPCName in pairs(QuestList) do
        if type(NPCName) == "userdata" then continue end
        if TextBox.Text:find(NPCName) then
            QuestList[MobName] = QuestNPC
        end 
    end 
end

for MobName, _ in pairs(QuestList) do
    if table.find(MobValues, MobName) then continue end
    MobValues[#MobValues + 1] = MobName
end
 
for _, Mob in ipairs(LivingFolder:GetChildren()) do
    if Players:GetPlayerFromCharacter(Mob) then continue end
    if table.find(MobValues, Mob.Name) then continue end
    MobValues[#MobValues + 1] = Mob.Name
end
 
for _, StandObject in ipairs(ReplicatedStorage.StandNameConvert:GetChildren()) do 
    if table.find(StandList, StandObject.Name) then continue end
    if table.find(StandBlacklist, StandObject.Name) then continue end
    if string.lower(StandObject.Name):find("oh") or string.lower(StandObject.Name):find("overheaven")  then continue end
 
    StandList[#StandList + 1] = StandObject.Name
end

--//UI shit
Window:AddBind({text = "UI Toggle", key = Enum.KeyCode.End, callback = function() Library:Close() end})

--Main Folder
MainFolder:AddList({text = "Mob Target", flag = "Target", values = MobValues})
MainFolder:AddList({text = "Lair Target", flag = "LairTarget", values = {"Lvl. 15", "Lvl. 40", "Lvl. 80", "Lvl. 100"}}) 
MainFolder:AddSlider({text = "Mob Distance", flag = "MobDistance", min = -8, max = 5})
MainFolder:AddBox({text = "Auto Farm Players", flag = "TargetPlayer"})

MainFolder:AddToggle({text = "ENABLE FARM", flag = "MobFarm"})
MainFolder:AddToggle({text = "Lair Farm", flag = "LairFarm", callback = GetLair}) --get lair quest
MainFolder:AddToggle({text = "Item Farm", flag = "Itemfarm", callback = RunGetItem})
MainFolder:AddToggle({text = "Auto Quest", flag = "AutoQuest"})
MainFolder:AddToggle({text = "Auto Stand Skills", flag = "StandAttack"})
MainFolder:AddToggle({text = "Player Farm", flag = "PlayerFarm" ,callback = function(Bool)
    if not Bool then return end

    for _, Player in ipairs(Players:GetPlayers()) do
        if string.lower(Player.Name) ~= string.lower(Library.flags.TargetPlayer) then continue end

        while Library.flags.PlayerFarm and task.wait() do
            local Character = Client.Character
            if not IsAlive(Character) then continue end
            if not IsAlive(Player.Character) then continue end
            
            Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, Library.flags.MobDistance)
            Attack()
        end
        break
    end 
end})

--Stand Folder
StandFolder:AddLabel({text = "Stand Selection"})
StandFolder:AddList({text = "Stand Selector1", flag = "TargetStand1", values = StandList})
StandFolder:AddList({text = "Stand Selector2", flag = "TargetStand2", values = StandList})
StandFolder:AddList({text = "Stand Selector3", flag = "TargetStand3", values = StandList})
StandFolder:AddList({text = "Stand Selector4", flag = "TargetStand4", values = StandList})

StandFolder:AddLabel({text = "Attribute Selection"})
StandFolder:AddList({text = "Attribute Selector1", flag = "TargetAttribute1", values = WhitelistedAttributes})
StandFolder:AddList({text = "Attribute Selector2", flag = "TargetAttribute2", values = WhitelistedAttributes})
StandFolder:AddList({text = "Attribute Selector3", flag = "TargetAttribute3", values = WhitelistedAttributes})
StandFolder:AddList({text = "Attribute Selector4", flag = "TargetAttribute4", values = WhitelistedAttributes})

StandFolder:AddLabel({text = "Arrow Selection"})
StandFolder:AddList({text = "Arrow Selector", flag = "Arrow", values = {"Stand Arrow", "Charged Arrow"}})

StandFolder:AddToggle({text = "Whitelist Rare Stands", flag = "RareStand"})
StandFolder:AddToggle({text = "Stand Farm", flag = "StandFarm", callback = function()
    local Character = Client.Character
    
    while IsAlive(Character) and Library.flags.StandFarm do
        task.wait(0.2)
        
        local Flags = Library.flags
        local Stand = string.lower(ClientStand.Value)
        local Attribute = string.lower(ClientAttribute.Value)

        local CanStop = false

        for Index = 1, 4 do
            if Stand == string.lower(Flags["TargetStand"..Index]) or Attribute == string.lower(Flags["TargetAttribute"..Index]) then --can never be too careful hehe
                CanStop = true
                break
            end 
        end

        if CanStop or string.lower(Stand):find("ova") or Flags.RareStand and table.find(WhitelistedStands, Stand) then --better if statement then before
            warn("Got good stand!")
            return
        end

        local Arrow = Client.Backpack:FindFirstChild(Flags.Arrow) or Character:FindFirstChild(Flags.Arrow)
        local Fruit = Client.Backpack:FindFirstChild("Rokakaka") or Character:FindFirstChild("Rokakaka")
 
        if not Arrow or not Fruit then continue end
        
        if ClientStand.Value == "None" then 
            repeat
                Arrow.Parent = Character
                task.wait(0.3)
                Arrow.Use:FireServer()
            until ClientStand.Value ~= "None" or not Library.flags.StandFarm or not IsAlive(Character)
        else
            repeat 
                Fruit.Parent = Character
                task.wait(0.3)
                Fruit.Use:FireServer()
            until ClientStand.Value == "None" or not Library.flags.StandFarm or not IsAlive(Character)
        end 
    end 
end})

--Shop Folder
for Index, ItemName in ipairs({"5x Roka $12500", "1x Roka $2500", "5x Arrow $17500", "$3500 1x Arrow"}) do
    ShopFolder:AddButton({text = ItemName, callback = function()
        ReplicatedStorage.Events.BuyItem:FireServer("MerchantAU", "Option"..tostring(Index))
    end})
end

--Misc Folder
MiscFolder:AddLabel({text = "Item Drop"})
MiscFolder:AddBox({text = "Drop Amount", callback = function(Amount)
    Amount = tonumber(Amount)

    if not Amount then return end
    if Amount <= 0 then return end

    for _ = 1, Amount do
        local Tool = Client.Backpack:FindFirstChildWhichIsA("Tool") or Client.Character:FindFirstChildWhichIsA("Tool")
        if not Tool then break end

        Tool.Parent = Client.Character
        task.wait(0.2)
        require(game.Players.LocalPlayer.PlayerScripts.ChatScript.ChatMain).MessagePosted:fire("/dropitem")
    end
end})
MiscFolder:AddLabel({text = "Stand Storage"})

for Index = 1, 3 do 
    MiscFolder:AddButton({text = "Storage"..Index, callback = function()
        ReplicatedStorage.Events.SwitchStand:FireServer("Slot"..Index)
    end})
end

--Credits Folder
CreditsFolder:AddLabel({text = "Script: Kaiden#2444"})
CreditsFolder:AddLabel({text = "UI Library: Jan"})

--Load UI
Library:Init()
