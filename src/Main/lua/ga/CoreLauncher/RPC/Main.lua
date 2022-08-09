local FS = require("fs")
local ApplicationData = TypeWriter.ApplicationData .. "/Discord-RPC/"
FS.mkdirSync(ApplicationData)
local GetNodeFile = ApplicationData .. "Get-Node.twr"
local Success = pcall(
    function ()
        local Response, Body = require("coro-http").request(
            "GET",
            "https://github.com/corebytee/get-node/releases/latest/download/Get-Node.twr"
        )
        FS.writeFileSync(GetNodeFile, Body)
    end
)
if FS.existsSync(GetNodeFile) == false then
    error("Failed to download Get-Node.twr")
end
TypeWriter.Runtime.LoadInternal("BetterEmitter")
TypeWriter.Runtime.LoadFile(GetNodeFile)
local NodePath = Import("ga.corebyte.get-node").Download()


local InstalledPackageJson = FS.readFileSync(ApplicationData .. "/package.json")
local PackageJson = TypeWriter.LoadedPackages["Discord-RPC"].Resources["/package.json"]
FS.writeFileSync(ApplicationData .. "/package.json", PackageJson)
if InstalledPackageJson ~= PackageJson then
    require("coro-fs").rmrf(ApplicationData .. "/node_modules")
    local Result = require("coro-spawn")(
        NodePath .. "/npm" .. (({["win32"] = ".cmd"})[TypeWriter.Os] or ""),
        {
            args = {
                "i"
            },
            cwd = ApplicationData
        }
    )
    Result.waitExit()
end

return Import("ga.CoreLauncher.RPC.RPC")(NodePath, ApplicationData)