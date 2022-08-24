local FS = require("fs")
local Request = require("coro-http").request

local ApplicationData = TypeWriter.ApplicationData .. "/Discord-RPC/"
FS.mkdirSync(ApplicationData)

local GetNodeFile = ApplicationData .. "Get-Node.twr"
local OpenIPCFile = ApplicationData .. "Open-IPC.twr"

local Success, Error = pcall(
    function ()
        local _, GetNode = Request(
            "GET",
            "https://github.com/corebytee/get-node/releases/latest/download/Get-Node.twr"
        )
        FS.writeFileSync(GetNodeFile, GetNode)

        local _, OpenIPC = Request(
            "GET",
            "https://github.com/CoreBytee/open-ipc/releases/latest/download/IPC-Bootstrap.twr"
        )
        FS.writeFileSync(OpenIPCFile, OpenIPC)
    end
)
if Success == false then
    error("Failed to download dependencies " .. Error)
end

TypeWriter.Runtime.LoadInternal("BetterEmitter")
TypeWriter.Runtime.LoadFile(GetNodeFile)
TypeWriter.Runtime.LoadFile(OpenIPCFile)
local NodePath = Import("ga.corebyte.get-node").Download()
local IPClient = Import("openipc.bootstrap").LoadAll()

local ExtractedVersion = FS.readFileSync(ApplicationData .. "version.txt")
local CurrentVersion = TypeWriter.LoadedPackages["Discord-RPC"].Package.Version
p(CurrentVersion)

if CurrentVersion ~= ExtractedVersion then
    require("coro-fs").rmrf(ApplicationData .. "/Node/")
    local Files = {
        "index.js",
        "OpenIPC-NodeJs.zip",
        "package.json",
    }
    FS.mkdirSync(ApplicationData .. "/Node/")
    for Index, FilePath in pairs(Files) do
        local FileData = TypeWriter.LoadedPackages["Discord-RPC"].Resources["/Node/" .. FilePath]
        FS.writeFileSync(ApplicationData .. "/Node/" .. FilePath, FileData)
    end
    FS.writeFileSync(ApplicationData .. "version.txt", CurrentVersion)
    Import("ga.CoreLauncher.RPC.Lib.Unzip")(ApplicationData .. "/Node/OpenIPC-NodeJs.zip", ApplicationData .. "/Node/OpenIPC")
end