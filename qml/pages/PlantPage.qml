import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

Page {
   id: plantPage

   property var plant: nil

   SilicaFlickable {
      anchors.fill: parent
      contentHeight: header.height + plantCard.height

      PageHeader { id: header
         //title: i18n.tr('Plant details')
         title: plant.commonNames.split(", ")[0]
         description: plant.family
      }

      PlantCard { id: plantCard
         width: parent.width - units.gu(2)*2
         anchors.top: header.bottom
         plant: plantPage.plant
      }

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
              text: i18n.tr("Copy family to Clipboard")
              onDelayedClick: Clipboard.text = plant.family
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
   }
}
