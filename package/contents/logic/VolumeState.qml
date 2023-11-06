import QtQuick

/**
 * Decouples our internal volume state from immediatly reflecting mpd's
 */
Item {
    id: root

    /**
     * Our internal volume value that is considered as the "truth" by the UI
     */
    property int volume: 50

    function set(value) {
        if (value < 0 || value > 100) {
            throw new Error("Invalid argument: volume must be between 0 and 100, is " + value)
        }

        // If one volume slider changes every other will update and therefore
        // try to set that same value again. We ignore that identical value.
        if (volume === value) {
            return
        }

        // Use int. Otherwise our value fights with mpd's if mpd sends back a
        // value that doesn't fit the int step.
        value = Math.round(value)
        root.volume = value

        // Don't trigger sending to mpd again if we just received the "mixer"
        // event value from mpd for our own value change.
        if (root.volume === mpdState.mpdVolume) {
            return
        }

        volumeDebounceTimer.value = value
        // Don't use restart(). We don't want to send just the end value,
        // the user has to receive volume change feedback while adjusting.
        volumeDebounceTimer.start()
        // Use restart(), we only care about the final value here and don't
        // want to receive data we send before, but is outdated now (slider
        // janks back to an older value).
        volumeReceiverTimer.restart()
    }

    /**
     * Change volume by a volume step
     *
     * @param {int} Value to change the current volume on a 0 to 100 scale
     */
    function change(value) {
        value =  root.volume + value
        value = value < 0 ? 0 : value
        value = value > 100 ? 100 : value
        set(value)
    }

    /**
     * Takes a raw wheel input value, transforms into a volume value and applies
     *
     * @param {int} Raw mouse wheel value
     */
    function wheel(value) {
        // Wheel value is 120 int per "click". So divide by 120 for volume +/- 1.
        // Hope it works for your mouse, it does for mine. Good luck.
        let valueChangePerClick = 120
        let desiredVolumeChangePerClick = 2
        let volumeChange = value / valueChangePerClick * desiredVolumeChangePerClick
        change(volumeChange)
    }

    Connections {
        target: mpdState
        function onVolumeChanged() {
            // We want to react to volume changes not comming from us. But we
            // have to respect the time window we set for our own debounce-send
            // to pass - It could be us. So we have to wait for at least that
            // amount of time. Since the timer takes care of the volume update
            // if it was us we return early and let the timer handle it.
            if (volumeReceiverTimer.running) {
                return
            }
            // So it wasn't us, let's adjust our volume to the mpd state.
            root.volume = mpdState.volume
        }
    }

    /**
     * Debounce updating our "truth" from mpd
     */
    Timer {
        id: volumeReceiverTimer
        property int value
        // We have to at least wait for the time of our own send debounce-send to
        // pass, otherwise we "jank back" to a previous, outdated value mpdState
        // just received. Also wait at least a second, otherwise mpd may still
        // serve the old value.
        interval: 2 * volumeDebounceTimer.interval < 2000 ? 2000 : 2 * volumeDebounceTimer.interval
        onTriggered: {
            if (root.volume !== mpdState.volume) {
                root.volume = mpdState.volume
            }
        }
    }

    /**
     * Debounce volume sending
     *
     * Don't send every volume event our input devices generate. Plasma and mpd
     * (or someone along the way down) feel much to crash happy about that.
     */
    Timer {
        id: volumeDebounceTimer
        property int value
        interval: 100
        onTriggered: {
            mpdState.setVolume(value)
        }
    }
}
