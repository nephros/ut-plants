import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle {
   id: loadingScreen
   anchors.fill: parent
   color: Qt.rgba(0.5, 0.5, 0.5, 0.5)
   z: 1000

   MouseArea {
      anchors.fill: parent
   }

   property double spacing: units.gu(2)

   Rectangle {
      id: loadingContent
      color: brand.foreground
      radius: 10
      anchors.centerIn: parent
      width: parent.width * 0.8
      height: units.gu(24)

      Column {
         anchors.centerIn: parent
         spacing: units.gu(2)

         BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: true
         }

         Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Plant is being identified, please wait.")
            wrapMode: Text.WordWrap
         }
      }
   }
}
