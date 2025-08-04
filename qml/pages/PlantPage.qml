import QtQuick 2.6
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

import "../util"

Page {
   id: plantPage
   anchors.fill: parent

   property var plant: nil

   SilicaFlickable {
      anchors.fill: parent
      contentHeight: header.height + plantCard.height
      PullDownMenu {
          MenuItem {
              text: i18n.tr("Copy names to Clipboard")
              onDelayedClick: Clipboard.text = plant.commonNames
          }
          MenuItem {
              text: i18n.tr("Copy species to Clipboard")
              onDelayedClick: Clipboard.text = plant.species
          }
          MenuItem {
              text: i18n.tr("Search on Wikipedia")
              // FIXME: support language:
              onClicked: Qt.openUrlExternally("https://wikipedia.org/w/index.php?"
                   + '&profile=advanced'
                   + '&search=%1'.arg(encodeURI(plant.species)) + "+deepcat%3APlants"
                   )
          }
      }
      PageHeader {
         id: header
         //title: i18n.tr('Plant details')
         title: plant.commonNames.split(", ")[0]
         description: plant.species

      }

      PlantCard {
         id: plantCard
         plant: plantPage.plant

         anchors.top: header.bottom
         anchors.topMargin: units.gu(2)
         anchors.bottomMargin: units.gu(2)
         width: parent.width
      }
   }
}
