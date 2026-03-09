import QtQuick
import QtTest
import QtQuick.Controls as QQC2
import "../../../package/contents/ui/Components/Elements"

TestCase {
    id: root

    name: "Dynamic Menu"

    signal handlerCalled(string text)

    DynamicMenu {
        id: testItem

        actions: [
        {
            text: "text1",
            icon: "home",
            shortcut: "A",
            handler: () => { root.handlerCalled('handlerA') },
            enabled: false
        },
        { separator: true },
        {
            text: "text2",
            icon: "home",
            shortcut: "B",
            handler: () => { root.handlerCalled('handlerB') },
            enabled: true,
        },
        ]
    }

    SignalSpy {
        id: handlerSpy
        target: root
        signalName: "handlerCalled"
    }

    function test_creation() {
        testItem.open()
        verify(testItem.visible)

        let item = testItem.contentItem.itemAtIndex(0)
        verify(item !== null)
        compare(item.text, "text1")
        compare(item.icon.name, "home")
        compare(item.action.shortcut, "A")
        verify(!item.enabled)

        item = testItem.contentItem.itemAtIndex(1)
        verify(item !== null)
        compare(item.separator, true)

        item = testItem.contentItem.itemAtIndex(2)
        verify(item !== null)
        compare(item.text, "text2")
        compare(item.icon.name, "home")
        compare(item.action.shortcut, "B")
        verify(item.enabled)
    }

    function test_interactionDisabledItem() {
        testItem.open()
        verify(testItem.visible)
        const item = testItem.contentItem.itemAtIndex(0)
        compare(handlerSpy.count, 0)
        mouseClick(item)
        compare(handlerSpy.count, 0)
    }

    function test_interactionEnabledItem() {
        testItem.open()
        verify(testItem.visible)
        const item = testItem.contentItem.itemAtIndex(2)
        compare(handlerSpy.count, 0)
        mouseClick(item)
        compare(handlerSpy.count, 1)
        compare(handlerSpy.signalArguments[0][0], "handlerB")
    }
}