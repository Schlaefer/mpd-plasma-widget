import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_mpdHost: mpdHost.text

        QQC2.TextField {
            id: mpdHost
            Kirigami.FormData.label: i18n("MPD Server Host Address:")
            placeholderText: i18n("192.168.1.….")
        }
    }
