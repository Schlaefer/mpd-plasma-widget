import QtQuick 2.15
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    property var parentPage

    Component.onCompleted: {
        parentPage.actions.main = menu.createObject(parentPage)
    }

    Component {
        id: menu

        Kirigami.Action {
            iconName: "draw-arrow-back"
            text: qsTr("Queue")
            onTriggered: appWindow.showPage(queuePage)
        }
    }
}
