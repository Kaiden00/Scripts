local oldHook; oldHook = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}

    if not checkcaller() then return oldHook(self, ...) end

    if getnamecallmethod() == "WaitForChildWhichIsA" then
        local className, timeOut = args[1], args[2] or 60
        assert(className, "Argument 1 missing or nil")
        assert(timeOut, "illegal argument #2 (timeOut must be greater than 0)")

        local firstFind = self:FindFirstChildWhichIsA(className)
        if firstFind then return firstFind end

        local thread = coroutine.running()
        local connect; connect = self.ChildAdded:Connect(function(object)
            if object:IsA(className) then
                connect:Disconnect()
                coroutine.resume(thread, object)
            end
        end)

        task.delay(timeOut, function()
            if coroutine.status(thread) == "suspended" then
                connect:Disconnect()
                coroutine.resume(thread)
            end
        end)

        return coroutine.yield()
    end

    return oldHook(self, ...)
end)
