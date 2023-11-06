import QtQuick
import org.kde.kirigami as Kirigami


Kirigami.SwipeListItem {
    property int highlightIndex: -1
    property int carretIndex: -1

    width: width ? width : implicitWidth

    /* @TODO Removed in plasma 6? Remove?
    backgroundColor:
        (highlightIndex !== index)
        ? Kirigami.Theme.backgroundColor
        : Kirigami.Theme.highlightColor
    alternatingBackground: true
    alternateBackgroundColor:
        (highlightIndex !== index)
        ? Kirigami.Theme.alternateBackgroundColor
        : Kirigami.Theme.highlightColor
    */
}
