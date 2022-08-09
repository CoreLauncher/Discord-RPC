return function (NodePath, ApplicationData)
    local Emitter = Import("ga.corebyte.BetterEmitter")
    local Spawn = require("coro-spawn")
    local Json = require("json")

    local RPC = Emitter:extend()

    function RPC:initialize(ClientId)
        self.Process, Error = Spawn(
            NodePath .. "/node",
            {
                args = {
                    "-i"
                },
                cwd = ApplicationData
            }
        )
        p(Error)

        coroutine.wrap(
            function ()
                for Message in self.Process.stdout.read do
                    p(Message)
                    self:Emit("stdout", Message)
                end
            end
        )()

        coroutine.wrap(
            function ()
                for Message in self.Process.stderr.read do
                    print(Message)
                end
            end
        )()

        self:WaitForWrite("> ")
        self:Write(string.format("var Client = new (require('@xhayper/discord-rpc').Client)({clientId: '%s'}); await Client.login()", ClientId))
        self:WaitForWrite("undefined\n")
    end

    function RPC:Write(Text)
        print(Text)
        self.Process.stdin.write(Text .. "\n")
    end

    function RPC:WaitForWrite(Text)
        p("Waiting ", Text)
        self:WaitFor("stdout", nil, function (Message)
            return Message == Text
        end)
    end

    function RPC:Stop()
        require("uv").process_kill(self.Process.handle)
    end

    function RPC:SetActivity(Activity)
        local S = string.random(16)
        RPC:Write(
            string.format(
                "Client.user.setActivity(JSON.parse('%s'));",
                Json.stringify(Activity)
            )
        )

    end

    return RPC
end