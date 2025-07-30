import QtQuick 2.6
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

import "../util"

Page {
   id: plantPage
   anchors.fill: parent

   property var plant: nil

   header: PageHeader {
      id: header
      title: i18n.tr('Plant details')
   }

   PlantCard {
      id: plantCard
      plant: plantPage.plant

      anchors.top: header.bottom
      anchors.topMargin: units.gu(2)
      anchors.bottom: parent.bottom
      anchors.bottomMargin: units.gu(2)
      width: parent.width
   }
}
