import QtQuick
import org.kde.kirigami as Kirigami


Kirigami.SwipeListItem {
    property int highlightIndex: -1
    property int carretIndex: -1

    width: width ? width : implicitWidth

    // Kirigami.Theme.inherit: false
    // Kirigami.Theme.useAlternateBackgroundColor: true

}
