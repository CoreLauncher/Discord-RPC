local Spawn = require("coro-spawn")
return function (NodePath)
    return function (Path)
        local Result = Spawn(
            NodePath .. "/npm" .. (({["win32"] = ".cmd"})[TypeWriter.Os] or ""),
            {
                args = {
                    "install",
                    "--omit=dev"
                },
                cwd = Path,
                stdio = {
                    process.stdin.handle,
                    process.stdout.handle,
                    process.stderr.handle,
                }
            }
        )
        Result.waitExit()
    end
end
