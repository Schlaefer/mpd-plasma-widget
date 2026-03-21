pragma Singleton
import QtQuick

QtObject {
    property list<string> disallowedChars: ["/", "\r", "\n"]

    function unique(title: string, playlists: list<string>): bool {
        return playlists.indexOf(title) === -1
    }

    function validate(title: string): string {
        return title.length && !disallowedChars.some(c => title.includes(c))
    }
}
