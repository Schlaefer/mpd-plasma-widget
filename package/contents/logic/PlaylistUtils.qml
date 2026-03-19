pragma Singleton
import QtQuick

QtObject {
    property list<string> disallowedChars: ["/", "\r", "\n"]
    property string sanitizeReplacement: qsTr(" - ")

    function sanitize(title: string): string {
        let result = title
        disallowedChars.forEach(c => {
            while (result.indexOf(c) !== -1) {
                result = result.replace(c, sanitizeReplacement)
            }
        })
        return result
    }

    function unique(title: string, playlists: list<string>): bool {
        return playlists.indexOf(title) === -1
    }

    function validate(title: string): string {
        return title.length && !disallowedChars.some(c => title.includes(c))
    }
}
