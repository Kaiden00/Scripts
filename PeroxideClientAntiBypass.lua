
local Client = game:GetService("Players").LocalPlayer

if not Client then
    game:GetService("Players"):GetPropertyChangedSignal("LocalPlayer"):Wait()
    Client = game:GetService("Players").LocalPlayer
end

Client:Kick("Bypass patched!")
