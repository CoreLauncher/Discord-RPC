return function (NodePath, ApplicationData)
    local Emitter = Import("ga.corebyte.BetterEmitter")
    local Spawn = require("coro-spawn")
    local Json = require("json")

    local RPC = Emitter:extend()

    function RPC:initialize(ClientId)
        
    end

    function RPC:SetActivity(Activity)
        
    end

    function RPC:ClearActivity()
        
    end

    return RPC
end