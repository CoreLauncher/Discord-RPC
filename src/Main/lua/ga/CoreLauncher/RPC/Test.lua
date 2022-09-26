print("Hello World!")
local RPC = Import("ga.CoreLauncher.RPC"):new("791927279357657088")
p(RPC:SetActivity(
    {
        state = string.random(16),
        buttons = {
            {
                label = "test",
                url = "https://cubic-inc.ga"
            }
        }
    }
))

Wait(1)
p("exit")

RPC:Disconnect()