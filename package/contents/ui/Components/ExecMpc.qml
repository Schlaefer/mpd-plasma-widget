ExecGeneric {
    id: root

    /**
     * Executes mpc commands
     *
     * @param {string} command Command to execute
     * @param {Object} params Optional params
     * @param {function} params.callback Callback to execute after the command
     * @param {string} params.id Id to identify async response
     */
    function execMpc(command, callback) {
        if (mpcAvailable !== true || mpcConnectionAvailable !== true) {
            return
        }
        let cmd = "mpc --host=" + cfgMpdHost + " " + command
        exec(cmd, callback)
    }
}
