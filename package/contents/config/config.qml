import QtQuick
import org.kde.plasma.configuration
import "../ui/Mpdw.js" as Mpdw

ConfigModel {
    ConfigCategory {
        name: qsTr("General")
        icon: Mpdw.icons.appConfigGeneral
        source: "Config/configGeneral.qml"
    }
    ConfigCategory {
        name: qsTr("Appearance")
        icon: Mpdw.icons.appConfigAppearance
        source: "Config/configAppearance.qml"
    }
}
