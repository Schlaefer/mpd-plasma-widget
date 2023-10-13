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

            property string itDesc: qsTr("Queue")
            property string itSc: "1"

            iconName: "draw-arrow-back"
            text: itDesc
            tooltip: itDesc + " (" + itSc + ")"
            shortcut: itSc
            checkable: true
            checked: queuePage.visible
            onTriggered: {
                if (!queuePage.visible) {
                    while (appWindow.pageStack.depth > 0)
                        appWindow.pageStack.pop()
                    appWindow.pageStack.push(queuePage)
                }
            }
        }
    }
}
