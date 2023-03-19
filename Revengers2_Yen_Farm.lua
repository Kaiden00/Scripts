
_G.IsEnabled = true --set to true/false to toggle


local Players = game:GetService("Players")
local Client = Players.LocalPlayer

local Crates = workspace.Game.JobStuff.Crates
local CratePoint = workspace.Game.JobStuff.CratePoint
local JobNPC = workspace.Game.NPC.Kaoru

local DialogueFunction = game:GetService("ReplicatedStorage").Events.DialogueAnswer

local function IsAlive(Model)
    if not Model or not Model.Parent then return end
    local Humanoid = Model:FindFirstChild("Humanoid")

    if not Humanoid or not Model:FindFirstChild("HumanoidRootPart") then return end
    if Humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
    
    return true
end

local function SendNotification(Title, Text, Duration)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = Title,
		Text = Text,
		Duration = Duration
	})
end

--function to keep request for job 
local function GetJob()
	if Client:FindFirstChild("GetCrates") then return end
	DialogueFunction:InvokeServer("kaoru", "take")
	if not Client:FindFirstChild("GetCrates") then
		return GetJob()
	end 
end

--function to complete the job by getting crate and then firing the touchinterest to complete job(so we won't need to teleport back)
local function DoJob(Character)
	local PrimaryPart = Character.HumanoidRootPart
	PrimaryPart.CFrame = Crates.CFrame

	local function CompleteJob()
		firetouchinterest(PrimaryPart, CratePoint, 0)
		firetouchinterest(PrimaryPart, CratePoint, 1)

		if not Character:FindFirstChild("GetCrates") then return end
		CompleteJob() --call function again if job hasn't been completed
	end

	fireclickdetector(Crates.ClickDetector)
	
	local Box = Character:WaitForChild("Box", 1)
	if not Box then
		return DoJob(Character)
	end

	CompleteJob()
end

--Autofarm loop
task.defer(function()
	while _G.IsEnabled and task.wait(0.05) do
		if Client.Stats.Yen.Value >= 100000 then --already got max cash so we should stop the farm
			SendNotification("Alert", "Cannot farm, you have got max yen!", 7)
			break
		end

		local Character = Client.Character
		if not IsAlive(Character) then continue end

		GetJob()
		DoJob(Character)
	end
end)

--Anti tp bypass
local OldNamecall = nil
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    
    if getnamecallmethod() == "FireServer" and game.IsA(self, "RemoteEvent") and tostring(self) == "Check" then
        return coroutine.yield()
    end
    
    return OldNamecall(self, ...)
end)

SendNotification("Credits", "Script created by: Kaiden#2444", 5)
