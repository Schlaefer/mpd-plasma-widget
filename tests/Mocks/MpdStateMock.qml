import QtQuick
import '../../package/contents/logic'

MpdState {
    final readonly property bool _connected: false

    function connect() {}
    function checkMpdConnectionAvailable() {}

    function mockPlaylistsSet(numberOfItems) {
        for (let i = 0; i < numberOfItems; i++) {
            mpdPlaylists.push(`Pl ${i + 1}`)
        }
    }

    function mockPlaylistsClear() {
        mpdPlaylists = []
    }
}