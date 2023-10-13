import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.PlaceholderMessage {
    anchors.centerIn: undefined
    width: parent.width - (Kirigami.Units.largeSpacing * 4)
    text: qsTr("Queue is empty")
    // @TODO how does this work?
    // Also can be left out in WidgetLayout?
    // This is a calculated property? How does it update?
    visible: !mpdState.countQueue()
}
