import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
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
