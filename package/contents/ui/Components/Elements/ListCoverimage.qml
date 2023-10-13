import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    property alias loadingPriority: image.loadingPriority

    Layout.preferredHeight: appWindow.width
                            > appWindow.simpleLayoutBreakpoint ? Kirigami.Units.iconSizes.large : Kirigami.Units.iconSizes.medium
    Layout.preferredWidth: appWindow.width
                           > appWindow.simpleLayoutBreakpoint ? Kirigami.Units.iconSizes.large : Kirigami.Units.iconSizes.medium


    Kirigami.Icon {
        id: coverPlaceholderIcon
        source: "media-default-album"
        anchors.fill: parent
        visible: !image.source.toString()
    }

    Image {
        id: image
        anchors.fill: parent

        property int loadingPriority: 100

        mipmap: true
        fillMode: Image.PreserveAspectFit

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
            let coverPath = coverManager.getCover(model, loadingPriority)
            if (coverPath) {
                setCover(coverPath)

                return
            }
            coverManager.gotCover.connect(onGotCover)
        }
    }
}
