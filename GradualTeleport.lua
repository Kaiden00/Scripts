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
    local PositionDelta = (Target - StartingPosition);
    local StartTime = tick();
    local TotalDuration = (StartingPosition - Target).magnitude / Teleport.TeleportSpeed;

    _G.TeleportCount += 1
    OldTeleportCount = _G.TeleportCount

    local lastProgress = 0

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    repeat NextFrame:Wait();
        local Delta = tick() - StartTime;
        local Progress = math.min(Delta / TotalDuration, 1);
        local MappedPosition = StartingPosition + (PositionDelta * Progress);
        HRP.Velocity = Vector3.new();

        -- Check if the player is about to go into the air and adjust the target position
        local raycastResult = workspace:Raycast(MappedPosition, Vector3.new(0, -5, 0), raycastParams)
        if raycastResult and raycastResult.Position.Y > MappedPosition.Y - 1.5 then
            -- If there's an object in the way, move the target position down
            Target = MappedPosition - Vector3.new(0, raycastResult.Position.Y - MappedPosition.Y + 1.5, 0)
            PositionDelta = (Target - StartingPosition)
            Progress = lastProgress -- Restore the last progress value to avoid jumping
        else
            -- Otherwise, update the last progress value
            lastProgress = Progress
        end

        HRP.CFrame = CFrame.new(MappedPosition);
    until (HRP.Position - Target).magnitude <= Teleport.TeleportSpeed / 2 or OldTeleportCount ~= _G.TeleportCount;

    HRP.Anchored = false;

    if OldTeleportCount ~= _G.TeleportCount then return end
    HRP.CFrame = CFrame.new(Target);
end


Teleport.TeleportTo = ImprovedTeleport

return Teleport
