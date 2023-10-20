import QtQuick 2.0
import org.kde.plasma.configuration 2.0
import "../ui/Mpdw.js" as Mpdw

ConfigModel {
    ConfigCategory {
        name: qsTr("General")
        icon: Mpdw.icons.appConfigGeneral
        source: "configGeneral.qml"
    }
}
