import QtQuick

QtObject {
    required property string title
    property list<string> playlists: undefined

    property bool canSave: !isEmpty && isValid && isUnique
    property bool isEmpty: title.length === 0
    property bool isUnique: _unique()
    property bool isValid: PlaylistUtils.validate(title)

    function _unique(): bool {
        if (typeof playlists === 'undefined') {
            throw new Error ("PlaylistObject: playlists is undefined")
        }

        return PlaylistUtils.unique(title, playlists)
    }
}
