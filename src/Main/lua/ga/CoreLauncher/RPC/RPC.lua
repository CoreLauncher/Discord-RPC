return function (NodePath, ApplicationData)
    local Emitter = Import("ga.corebyte.BetterEmitter")
    local Spawn = require("coro-spawn")
    local Json = require("json")
    local Base = require("base64")

    local RPC = Emitter:extend()

    function RPC:initialize(ClientId)
        local Data = {}
        Data.SessionId = string.random(32)
        Data.Channel = "DiscordRPC-" .. Data.SessionId
        Data.ClientId = ClientId
        self.Data = Data
        self.IPC = Import("openipc.connector"):new(Data.Channel, "Main")
        local Result = Spawn(
            NodePath .. "/node",
            {
                args = {
                    ".", Base.encode(Json.encode(Data))
                },
                cwd = ApplicationData .. "/Node/",
                stdio = {
                    process.stdin.handle,
                    process.stdout.handle,
                    process.stderr.handle,
                }
            }
        )
        self.IPC:RegisterMessage(
            "Connected",
            function ()
                self:Emit("ConnectedNode")
            end
        )
        self:WaitFor("ConnectedNode")
    end

    function RPC:SetActivity(Activity)
        return self.IPC:Send("Node", "SetActivity", Activity)
    end

    function RPC:ClearActivity()
        return self.IPC:Send("Node", "ClearActivity")
    end

    function RPC:Disconnect()
        self:ClearActivity()
        self.IPC:Send("Node", "Disconnect")
        self.IPC:Disconnect()
    end

    return RPC
end