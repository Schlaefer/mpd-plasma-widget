import QtQuick
import org.kde.plasma.components as PlasmaComponents
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQControls
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_cfgMpdHost: cfgMpdHost.text
    property alias cfg_cfgMpdPort: cfgMpdPort.text
    property alias cfg_cfgCacheRoot: cfgCacheRoot.cleanPath
    property alias cfg_cfgCacheForDays: cfgCacheForDays.value

    Kirigami.FormLayout {
        Item {
            Kirigami.FormData.label: i18n("MPD Connection")
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.TextField {
            id: cfgMpdHost

            Kirigami.FormData.label: i18n("MPD Server Address:")
            placeholderText: i18n("localhost/192.168.y.x")
            Layout.preferredWidth: 200
        }

        PlasmaComponents.TextField {
            id: cfgMpdPort

            Kirigami.FormData.label: i18n("MPD Server Port:")
            placeholderText: i18n("6600")
            Layout.preferredWidth: 200
        }

        Item {
            Kirigami.FormData.label: i18n("Local Cover Cache")
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Path to Cover Cache Folder:")

            PlasmaComponents.TextField {
                id: cfgCacheRootText

                text: cfgCacheRoot.cleanPath
                placeholderText: i18n("No file selected.")
                Layout.preferredWidth: 200
            }

            PlasmaComponents.Button {
                text: i18n("Select Folder")
                onClicked: cfgCacheRoot.open()
            }

            FolderDialog {
                id: cfgCacheRoot

                property string cleanPath

                title: i18n("Please Choose a Folder")
                onAccepted: {
                    cleanPath = decodeURIComponent(cfgCacheRoot.currentFolder.toString().replace(/^file:\/\//, ""))
                }
            }
        }

        PlasmaComponents.SpinBox {
            id: cfgCacheForDays

            Kirigami.FormData.label: i18n("Cache Covers for Days:")
        }
    }
}
