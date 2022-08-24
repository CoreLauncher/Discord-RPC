local Spawn = require("coro-spawn")
return function (Path)
    local Result = Spawn(
        NodePath .. "/npm" .. (({["win32"] = ".cmd"})[TypeWriter.Os] or ""),
        {
            args = {
                "install",
                "--omit=dev"
            },
            cwd = Location,
            stdio = {
                process.stdin.handle,
                process.stdout.handle,
                process.stderr.handle,
            }
        }
    )
    Result.waitExit()
end