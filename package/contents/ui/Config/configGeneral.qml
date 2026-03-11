import QtQuick
import org.kde.plasma.components as PlasmaComponents
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQControls
import org.kde.kcmutils as KCMUtils
import "../../logic"
import "./../Mpdw.js" as Mpdw

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_cfgMpdHost: cfgMpdHost.text
    property alias cfg_cfgMpdPort: cfgMpdPort.text
    property alias cfg_cfgCacheRoot: cfgCacheRoot.cleanPath
    property alias cfg_cfgCacheForDays: cfgCacheForDays.value
    property bool cfg_runtimeIsClient
    property AppContext cfg_appContext

    Kirigami.FormLayout {
        visible: !root.cfg_runtimeIsClient

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

        PlasmaComponents.Button {
            text: i18n("Refresh Local Client Data")
            icon.name: Mpdw.icons.mpdDownload
            onClicked: {
                root.cfg_appContext.getMpdState().forceReloadEverything()
            }
        }

        PlasmaComponents.Button {
            // Technically only an Update, but Update is less descriptive.
            text: i18n("Start Server Library Rescan")
            icon.name: Mpdw.icons.mpdRescan
            onClicked: {
                root.cfg_appContext.getMpdState().startServerUpdate()
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: !root.cfg_appContext.getMpdState().binaryAvailable
            type: Kirigami.MessageType.Error
            text: i18n("'python3' not available")
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
                text: i18n("Select Folder…")
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

        RowLayout {
            PlasmaComponents.Button {
                text: i18n("Clear Cover Cache")
                icon.name: Mpdw.icons.clearCache
                onClicked: {
                    root.cfg_appContext.getCoverManager().clearCache()
                }
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: !root.cfg_appContext.getCoverManager().binaryAvailable
            type: Kirigami.MessageType.Error
            text: i18n("'magick' not available. Make sure that imagemagick is installed.")
        }
    }

    Kirigami.InlineMessage {
        visible: root.cfg_runtimeIsClient
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.gridUnit
        type: Kirigami.MessageType.Information
        text: i18n("This widget picked up the General configuration of another running widget. Please change the configuration in the other widget.")
    }
}
