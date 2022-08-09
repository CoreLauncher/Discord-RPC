print("Hello World!")
local RPC = Import("ga.CoreLauncher.RPC"):new("791927279357657088")
RPC:SetActivity(
    {
        state = string.random(16)
    }
)