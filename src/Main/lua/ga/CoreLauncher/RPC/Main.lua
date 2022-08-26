local FS = require("fs")
local Request = require("coro-http").request

local ApplicationData = TypeWriter.ApplicationData .. "/Discord-RPC/"
FS.mkdirSync(ApplicationData)

local GetNodeFile = ApplicationData .. "Get-Node.twr"
local OpenIPCFile = ApplicationData .. "Open-IPC.twr"

local NodePath
local function LoadLibraries()
    TypeWriter.Runtime.LoadInternal("BetterEmitter")
    TypeWriter.Runtime.LoadFile(GetNodeFile)
    TypeWriter.Runtime.LoadFile(OpenIPCFile)
    NodePath = FS.readFileSync(ApplicationData .. "/NodePath.txt")
    TypeWriter.Runtime.LoadFile(TypeWriter.ApplicationData .. "/Open-IPC/IPC-Connector.twr")
end

local ExtractedVersion = FS.readFileSync(ApplicationData .. "version.txt")
local CurrentVersion = TypeWriter.LoadedPackages["Discord-RPC"].Package.Version
p(CurrentVersion)

if CurrentVersion ~= ExtractedVersion then
    TypeWriter.Logger.Info("Updating Libraries")
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
    LoadLibraries()
    
    TypeWriter.Logger.Info("Updating Extracting Libraries")
    local NodePath = Import("ga.corebyte.get-node").Download()
    local IPClient = Import("openipc.bootstrap").LoadAll()
    FS.writeFileSync(ApplicationData .. "/NodePath.txt", NodePath)

    TypeWriter.Logger.Info("Updating files")
    local NodeFiles = ApplicationData .. "/Node/"
    require("coro-fs").rmrf(NodeFiles)
    local Files = {
        "index.js",
        "OpenIPC-NodeJs.zip",
        "package.json",
    }
    FS.mkdirSync(NodeFiles)
    for Index, FilePath in pairs(Files) do
        local FileData = TypeWriter.LoadedPackages["Discord-RPC"].Resources["/Node/" .. FilePath]
        FS.writeFileSync(NodeFiles .. FilePath, FileData)
    end

    TypeWriter.Logger.Info("Unpacking files")
    Import("ga.CoreLauncher.RPC.Lib.Unzip")(NodeFiles .. "/OpenIPC-NodeJs.zip", NodeFiles .. "/OpenIPC")
    FS.writeFileSync(ApplicationData .. "version.txt", CurrentVersion)

    TypeWriter.Logger.Info("Installing npm libraries")
    local NPM = Import("ga.CoreLauncher.RPC.Lib.NPM")(NodePath)
    NPM(NodeFiles)
    NPM(NodeFiles .. "/OpenIPC")
else
    LoadLibraries()
end

return Import("ga.CoreLauncher.RPC.RPC")(NodePath, ApplicationData)