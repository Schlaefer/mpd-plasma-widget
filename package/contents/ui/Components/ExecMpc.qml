ExecGeneric {
    id: root

    /**
     * Executes mpc commands
     *
     * @param {string} command Command to execute
     * @param {function} callback Callback to execute after the command
     */
    function execMpc(command, callback) {
        if (mpcAvailable !== true || mpcConnectionAvailable !== true) {
            return
        }
        let cmd = ["mpc"]
        if (cfgMpdHost !== "") {
            cmd.push("--host=" + cfgMpdHost)
        }
        cmd.push(command)
        exec(cmd.join(" "), callback)
    }
}
