local FS = require("fs")
local Request = require("coro-http").request

local ApplicationData = TypeWriter.ApplicationData .. "/Discord-RPC/"
FS.mkdirSync(ApplicationData)

TypeWriter.Runtime.LoadInternal("BetterEmitter")
local Resources = TypeWriter.LoadedPackages["Discord-RPC"].Resources
TypeWriter.Runtime.LoadJson(Resources["/OpenIPC-TypeWriter.twr"])
TypeWriter.Runtime.LoadJson(Resources["/Get-Node.twr"])
local NodePath = Import("ga.corebyte.get-node").Download()

local ThisVersion = TypeWriter.LoadedPackages["Discord-RPC"].Package.Version
local ThatVersion = FS.readFileSync(ApplicationData .. "version.txt")

if ThisVersion ~= ThatVersion then
    TypeWriter.Logger.Info("Out of date Discord-RPC version found, Updating...")

    local NodeFiles = ApplicationData .. "/Node/"
    require("coro-fs").rmrf(NodeFiles)
    local Files = {
        "index.js",
        "OpenIPC-NodeJs.zip",
        "package.json",
    }
    FS.mkdirSync(NodeFiles)
    for Index, FilePath in pairs(Files) do
        local FileData = Resources["/Node/" .. FilePath]
        FS.writeFileSync(NodeFiles .. FilePath, FileData)
    end

    Import("ga.CoreLauncher.RPC.Lib.Unzip")(NodeFiles .. "/OpenIPC-NodeJs.zip", NodeFiles .. "/OpenIPC")
    FS.writeFileSync(ApplicationData .. "version.txt", ThisVersion)

    TypeWriter.Logger.Info("Installing npm libraries")
    local NPM = Import("ga.CoreLauncher.RPC.Lib.NPM")(NodePath)
    NPM(NodeFiles)
    NPM(NodeFiles .. "/OpenIPC")
end

return Import("ga.CoreLauncher.RPC.RPC")(NodePath, ApplicationData)
