import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "./../../Mpdw.js" as Mpdw

Item {
    id: root

    property alias loadingPriority: image.loadingPriority
    property bool isSelected: false

    Layout.preferredHeight: appWindow.narrowLayout ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.large
    Layout.preferredWidth: appWindow.narrowLayout ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.large

    Kirigami.Icon {
        id: coverPlaceholderIcon
        source: Mpdw.icons.queuePlaceholderCover
        anchors.fill: parent
        visible: !image.source.toString()
    }

    Image {
        id: image
        anchors.fill: parent

        property int loadingPriority: 100

        mipmap: true
        fillMode: Image.PreserveAspectFit

        sourceSize.height: Kirigami.Units.iconSizes.large
        sourceSize.width: Kirigami.Units.iconSizes.large

        function setCover(coverPath) {
            if (coverPath === null) {
                return false
            }
            image.source = coverPath + "-small.jpg"
        }

        function onGotCover(id) {
            // @BOGUS Why did we do that? What's happening here?
            if (typeof (coverManager) === "undefined") {
                return
            }
            let coverPath = coverManager.getCover(model)
            if (coverPath === undefined) {
                return false
            }
            coverManager.gotCover.disconnect(onGotCover)
            setCover(coverPath)
        }

        Component.onCompleted: {
            if (model.orphaned) {
                return
            }

            let coverPath = coverManager.getCover(model, loadingPriority)
            if (coverPath) {
                setCover(coverPath)

                return
            }
            coverManager.gotCover.connect(onGotCover)
        }
    }

    Rectangle {
        readonly property int offset: 4
        height: Kirigami.Units.iconSizes.medium / 2
        width: Kirigami.Units.iconSizes.medium / 2
        x: parent.width - width + offset
        y: parent.width - height + offset
        color: Kirigami.Theme.activeBackgroundColor
        border.color: Kirigami.Theme.hoverColor
        visible: isSelected

        Kirigami.Icon {
            color: Kirigami.Theme.activeTextColor
            source: Mpdw.icons.selectMarker
            anchors.fill: parent
        }
    }
}
