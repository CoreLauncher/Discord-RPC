(async function() {
    const LaunchArgs = JSON.parse(Buffer.from(process.argv[2], "base64"))
    const RPC = new (require("@xhayper/discord-rpc").Client)({clientId: LaunchArgs.ClientId})
    await RPC.login()
    const IpcConnection = new (require("./OpenIPC/index.js"))(LaunchArgs.Channel, "Node")

    IpcConnection.RegisterMessage(
        "SetActivity",
        async function(Activity) {
            return await RPC.user?.setActivity(
                Activity
            );
        }
    )

    IpcConnection.RegisterMessage(
        "ClearActivity",
        async function() {
            return await RPC.user?.clearActivity();
        }
    )

    IpcConnection.RegisterMessage(
        "Disconnect",
        async function() {
            await RPC.destroy()
            Disconnect()
        }
    )

    async function Disconnect() {
        await IpcConnection.Disconnect()
    }

    IpcConnection.Send("Main", "Connected")
})()