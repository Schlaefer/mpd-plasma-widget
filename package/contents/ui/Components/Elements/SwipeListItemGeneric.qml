import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami


Kirigami.SwipeListItem {
        property int highlightIndex: -1

        width: root.width ? root.width : implicitWidth
        backgroundColor: (highlightIndex === index) ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
        alternateBackgroundColor: (highlightIndex === index) ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
        alternatingBackground: true
}
