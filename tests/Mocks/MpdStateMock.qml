import QtQuick
import '../../package/contents/logic'

MpdState {
    id: root

    property ServerResponse r: ServerResponse {}
    final readonly property bool _connected: false

    function connect() {}
    function checkMpdConnectionAvailable() {}

    function mockReset() {
        mpdPlaylists = []
        library = undefined
        r.reset()
    }

    function getLibrary() { _getLibraryClb(0, r.libraryGetResponse())}
    function getPlaylists() { _getPlaylistsClb(0, r.playlistsGetResponse()) }

    Connections {
        target: root.r
        function onDataChanged() {
            root.getLibrary()
            root.getPlaylists()
        }
    }
}
