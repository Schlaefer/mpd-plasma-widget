import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami


Kirigami.SwipeListItem {
    property int highlightIndex: -1

    width: root.width ? root.width : implicitWidth

    alternatingBackground: true
    // I don't know what you mean, looks very save very normal to me.
    backgroundColor: (model.checked)
                     ? Kirigami.Theme.highlightColor
                     : (highlightIndex !== index)
                       ? Kirigami.Theme.backgroundColor
                       : Qt.application.active
                         ? Kirigami.Theme.focusColor
                         : Kirigami.Theme.highlightColor
    alternateBackgroundColor: (model.checked)
                              ? Kirigami.Theme.highlightColor
                              : (highlightIndex !== index)
                                ? Kirigami.Theme.alternateBackgroundColor
                                : Qt.application.active
                                  ? Kirigami.Theme.focusColor
                                  : Kirigami.Theme.highlightColor
}
