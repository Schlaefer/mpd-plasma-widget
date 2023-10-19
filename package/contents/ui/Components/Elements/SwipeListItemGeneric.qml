import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami


Kirigami.SwipeListItem {
    property int highlightIndex: -1
    property int carretIndex: -1

    width: root.width ? root.width : implicitWidth

    backgroundColor:
        (highlightIndex !== index)
        ? Kirigami.Theme.backgroundColor
        : Kirigami.Theme.highlightColor
    alternatingBackground: true
    alternateBackgroundColor:
        (highlightIndex !== index)
        ? Kirigami.Theme.alternateBackgroundColor
        : Kirigami.Theme.highlightColor
}
