--Credits to Nahida

local Teleport = {
    TeleportSpeed = 50
}

local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local Player = Players.LocalPlayer;

local NextFrame = RunService.Heartbeat;

_G.TeleportCount = 0

local function ImprovedTeleport(Target)
    if (typeof(Target) == "Instance" and Target:IsA("BasePart")) then Target = Target.Position; end;
    if (typeof(Target) == "CFrame") then Target = Target.p end;

    local HRP = (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"));
    if (not HRP) then return; end;

    local StartingPosition = HRP.Position;
    local PositionDelta = (Target - StartingPosition);--Calculating the difference between the start and end positions.
    local StartTime = tick();
    local TotalDuration = (StartingPosition - Target).magnitude / Teleport.TeleportSpeed;
    
    _G.TeleportCount += 1
    OldTeleportCount = _G.TeleportCount
    
    repeat NextFrame:Wait();
        local Delta = tick() - StartTime;
        local Progress = math.min(Delta / TotalDuration, 1);--Getting the percentage of completion of the teleport (between 0-1, not 0-100)
        --We also use math.min in order to maximize it at 1, in case the player gets an FPS drop, so it doesn't go past the target.
        local MappedPosition = StartingPosition + (PositionDelta * Progress);
        HRP.Velocity = Vector3.new();--Resetting the effect of gravity so it doesn't get too much and drag the player below the ground.
        HRP.CFrame = CFrame.new(MappedPosition);
    until (HRP.Position - Target).magnitude <= Teleport.TeleportSpeed / 2 or _G.TeleportCount ~= OldTeleportCount;
    
    HRP.Anchored = false;
    
    if _G.TeleportCount ~= OldTeleportCount then return end --if we override the teleport to another destination we may not actually be near the target which could kick us
    HRP.CFrame = CFrame.new(Target);
end

Teleport.TeleportTo = ImprovedTeleport

return Teleport
