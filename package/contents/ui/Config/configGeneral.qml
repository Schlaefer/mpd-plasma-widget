import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQControls

Kirigami.FormLayout {
    id: page

    property alias cfg_cfgMpdHost: cfgMpdHost.text
    property alias cfg_cfgMpdPort: cfgMpdPort.text
    property alias cfg_cfgCacheRoot: cfgCacheRoot.cleanPath
    property alias cfg_cfgCacheForDays: cfgCacheForDays.value

    Item {
        Kirigami.FormData.label: i18n("MPD Connection")
        Kirigami.FormData.isSection: true
    }

    TextField {
        id: cfgMpdHost

        Kirigami.FormData.label: i18n("MPD Server Address:")
        placeholderText: i18n("192.168.y.x")
        Layout.preferredWidth: 200
    }

    TextField {
        id: cfgMpdPort

        Kirigami.FormData.label: i18n("MPD Server Port:")
        placeholderText: i18n("6600")
        Layout.preferredWidth: 200
    }

    Item {
        Kirigami.FormData.label: i18n("Local Covers")
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Path to Cover Folder:")

        TextField {
            id: cfgCacheRootText

            text: cfgCacheRoot.cleanPath
            placeholderText: i18n("No file selected.")
            Layout.preferredWidth: 200
        }

        Button {
            text: i18n("Select Folder")
            onClicked: cfgCacheRoot.open()
        }

        FolderDialog {
            id: cfgCacheRoot

            property string cleanPath

            title: i18n("Please Choose a Folder")
            onAccepted: {
                cleanPath = decodeURIComponent(cfgCacheRoot.currentFolder.toString(
                                                   ).replace(/^file:\/\//, ""))
            }
        }
    }

    SpinBox {
        id: cfgCacheForDays

        Kirigami.FormData.label: i18n("Cache Covers for Days:")
    }

}
