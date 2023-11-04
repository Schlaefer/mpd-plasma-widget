import QtQuick 2.15

ListView {
    id: root

    // Scroll without animation when active item changes
    highlightMoveDuration: 0

    Keys.onPressed: {
        event.accepted = true

        if (event.key === Qt.Key_PageUp) {
            let xPos = root.contentX
            let yPos = root.contentY
            let height = root.height

            let yBottom = yPos + height
            if (root.header) {
                yBottom -= root.headerItem.height
            }

            let topIndex = root.indexAt(xPos, yPos)
            let bottomIndex = root.indexAt(xPos, yBottom)

            let scrollAdjustment = 1
            let itemsPerPage = bottomIndex - topIndex - scrollAdjustment

            if (itemsPerPage <= 0) {
                itemsPerPage = scrollAdjustment
            }
            let newPosition = topIndex - itemsPerPage

            if  (newPosition < 0) {
                newPosition = 0
            }

            root.positionViewAtIndex(newPosition, root.Beginning)
            root.currentIndex = newPosition

            return
        }

        if (event.key === Qt.Key_PageDown) {
            let bottomIndex = root.indexAt(root.contentX, root.contentY + root.height)
            if (bottomIndex === -1) {
                // We bottomed out
                bottomIndex = root.count - 1
            }
            root.positionViewAtIndex(bottomIndex, root.Beginning)
            root.currentIndex = bottomIndex
            return
        }

        if (event.key === Qt.Key_Home) {
            root.positionViewAtIndex(0, root.Beginning)
            root.currentIndex = 0
            return
        }

        if (event.key === Qt.Key_End) {
            root.positionViewAtIndex(root.count - 1, root.Beginning)
            root.currentIndex = root.count - 1
            return
        }

        if (event.key === Qt.Key_Up) {
            let newIndex = root.currentIndex - 1
            if (newIndex >= 0) {
                root.currentIndex = newIndex
            }
            return
        }

        if (event.key === Qt.Key_Down) {
            let newIndex = root.currentIndex + 1
            if (newIndex < root.count) {
                root.currentIndex = newIndex
            }
            return
        }
    }
}
