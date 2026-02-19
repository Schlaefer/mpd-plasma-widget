import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "./../../Mpdw.js" as Mpdw

Item {
    id: root

    property alias loadingPriority: image.loadingPriority
    property bool isSelected: false

    Layout.preferredHeight: (win.narrowLayout ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.large)
        // Move picture inside the automatic Kirigami mouse hover highlight
        + (Kirigami.Units.mediumSpacing)
    Layout.preferredWidth: win.narrowLayout ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.large

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

        asynchronous: true
        cache: true
        mipmap: true

        fillMode: Image.PreserveAspectFit

        sourceSize.height: Kirigami.Units.iconSizes.large
        sourceSize.width: Kirigami.Units.iconSizes.large

        function setCover(coverPath) {
            if (coverPath === null) {
                return false
            }
            image.source = "file://" + coverPath + "-small.jpg"
        }

        function onGotCover(id) {
            // @BOGUS Why did we do that? What's happening here?
            if (typeof (coverManager) === "undefined") {
                return
            }

            let coverPath = coverManager.getCover(model, loadingPriority)
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
