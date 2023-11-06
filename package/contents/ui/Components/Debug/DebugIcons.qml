import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw

Kirigami.ApplicationWindow {
    id: root

    Kirigami.ScrollablePage {
        anchors.fill: parent
        
        GridLayout {
            columns: 3
            
            Repeater {
                model: Object.keys(Mpdw.icons).map(function(title) {
                        return {title: title, icon: Mpdw.icons[title]}
                    })
                delegate: RowLayout {
                    Kirigami.Icon {
                        source: modelData.icon
                    }
                    QQC2.Label {
                        Layout.preferredWidth: 200
                        text: modelData.title
                    }
                }
                
            }
        }
    }
}
