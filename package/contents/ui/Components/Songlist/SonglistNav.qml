import QtQuick.Controls as QQC2
import QtQuick.Layouts

QQC2.ToolBar {
    RowLayout {
        anchors.fill: parent

         QQC2.ToolButton {
             id: backButton
             icon.name: "go-previous"
             onClicked: app.pageStack.pop()
         }

         QQC2.Label {
             id: titleLabel
             text: root.title
             Layout.fillWidth: true
             horizontalAlignment: Text.AlignHLeft
         }
    }
}
