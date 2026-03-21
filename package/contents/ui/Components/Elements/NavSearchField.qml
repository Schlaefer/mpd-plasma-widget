pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.SearchField {
    id: root

    required property int pageWidth
    property string tooltip: undefined

    signal escapePressed(var event)
    signal tabPressed(var event)

    Layout.alignment: Qt.AlignRight
    Layout.rightMargin: Kirigami.Units.smallSpacing

    // Per default the text field is stuck at 200 width and cut off at small sizes.
    // implicitWidth: root.pageWidth > 400 ? 200 : (root.pageWidth / 2) - (10000 / root.pageWidth)
    // onTextChanged: root.textChanged(text)
    focusSequence: undefined // Disables default Ctrl+F behavior
    ToolTip.text: root.tooltip // Disables default Ctrl+F tooltip
    // Don't double navigate in search field (left, right) and
    // list view (up, down) at the same time.
    Keys.onUpPressed: event => { event.accepted = true }
    Keys.onDownPressed: event => { event.accepted = true }

    Keys.onEscapePressed: event => {
        root.text.length > 0 ? root.text = "" : root.escapePressed(event)
    }
    Keys.onTabPressed: event => root.tabPressed(event)

    function forceActiveFocus() {
        rootFocusTimer.start()
    }

    // @BOGUS We wait here for starting up and immediately switching from Queue to
    // Artists, which is still being drawn.
    Timer {
        id: rootFocusTimer
        interval: 1
        onTriggered: {
            root.forceActiveFocus()
            root.selectAll()
        }
    }
}
