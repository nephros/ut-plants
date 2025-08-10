import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

Page {
   id: plantPage

   property var plant: nil

   SilicaFlickable {
      anchors.fill: parent
      contentHeight: header.height + plantCard.height + toolsRow.height + (moreLoader.loaded ? moreLoader.item.height : 0)

      PageHeader { id: header
         title: plant.family ? plant.commonNames.split(", ")[0] : i18n.tr('Plant details')
         description: plant.family ? plant.family : plant.commonNames.split(", ")[0] 
      }

      PlantCard { id: plantCard
         width: parent.width - units.gu(2)*2
         anchors.top: header.bottom
         plant: plantPage.plant
      }
      Row { id: toolsRow
         //width: plantCard.width
         anchors.top: plantCard.bottom
         anchors.horizontalCenter: plantCard.horizontalCenter
         spacing: units.gu(3)
         Column {
             width: wikiButt.width
             IconButton { id: wikiButt
                icon.source: Theme.colorScheme === Theme.LightOnDark
                   ? "https://upload.wikimedia.org/wikipedia/commons/4/4c/W-white.png"
                   : "https://upload.wikimedia.org/wikipedia/commons/4/4c/W-white.png"
                icon.width:Theme.iconSizeSmall
                icon.height:Theme.iconSizeSmall
                onClicked: moreLoader.setSource("../util/WikiCard.qml", { "species": plant.species } )
             }
             Label {
               anchors.horizontalCenter: parent.horizontalCenter
               wrapMode: Text.Wrap
               text: "Wikipedia"
               color: Theme.secondaryHighlightColor
               font.pixelSize: Theme.fontSizeTiny
            }
         }
         Column {
             width: gbifButt.width
             IconButton { id: gbifButt
                //readonly property string _svg: 'data:image/svg+xml;utf8,<svg class="logo" viewBox="90 239.1 539.7 523.9" xmlns="http://www.w3.org/2000/svg"> <path class="gbif-logo-svg" d="M325.5,495.4c0-89.7,43.8-167.4,174.2-167.4C499.6,417.9,440.5,495.4,325.5,495.4"></path> <path class="gbif-logo-svg" d="M534.3,731c24.4,0,43.2-3.5,62.4-10.5c0-71-42.4-121.8-117.2-158.4c-57.2-28.7-127.7-43.6-192.1-43.6c28.2-84.6,7.6-189.7-19.7-247.4c-30.3,60.4-49.2,164-20.1,248.3c-57.1,4.2-102.4,29.1-121.6,61.9c-1.4,2.5-4.4,7.8-2.6,8.8c1.4,0.7,3.6-1.5,4.9-2.7c20.6-19.1,47.9-28.4,74.2-28.4c60.7,0,103.4,50.3,133.7,80.5C401.3,704.3,464.8,731.2,534.3,731"></path> </svg> '
                readonly property string _svg: 'data:image/svg+xml;utf8,<svg class="logo" xmlns="http://www.w3.org/2000/svg"> <path class="gbif-logo-svg" d="M325.5,495.4c0-89.7,43.8-167.4,174.2-167.4C499.6,417.9,440.5,495.4,325.5,495.4"></path> <path class="gbif-logo-svg" d="M534.3,731c24.4,0,43.2-3.5,62.4-10.5c0-71-42.4-121.8-117.2-158.4c-57.2-28.7-127.7-43.6-192.1-43.6c28.2-84.6,7.6-189.7-19.7-247.4c-30.3,60.4-49.2,164-20.1,248.3c-57.1,4.2-102.4,29.1-121.6,61.9c-1.4,2.5-4.4,7.8-2.6,8.8c1.4,0.7,3.6-1.5,4.9-2.7c20.6-19.1,47.9-28.4,74.2-28.4c60.7,0,103.4,50.3,133.7,80.5C401.3,704.3,464.8,731.2,534.3,731"></path> </svg> '
                icon.source: _svg
                icon.width:Theme.iconSizeSmall
                icon.height:Theme.iconSizeSmall
                onClicked: moreLoader.setSource("../util/GBIFCard.qml", { "species": plant.species } )
             }
             Label {
               anchors.horizontalCenter: parent.horizontalCenter
               wrapMode: Text.Wrap
               text: "GBIF"
               color: Theme.secondaryHighlightColor
               font.pixelSize: Theme.fontSizeTiny
            }
         }
         Column {
             width: powoButt.width
             IconButton { id: powoButt
                icon.source: "image://theme/icon-s-cloud-download"
                icon.width:Theme.iconSizeSmall
                icon.height:Theme.iconSizeSmall
             }
             Label {
               anchors.horizontalCenter: parent.horizontalCenter
               wrapMode: Text.Wrap
               text: "POWO"
               color: Theme.secondaryHighlightColor
               font.pixelSize: Theme.fontSizeTiny
            }
         }
         Column {
             width: ipniButt.width
             IconButton { id: ipniButt
                icon.source: "image://theme/icon-s-cloud-download"
                icon.width:Theme.iconSizeSmall
                icon.height:Theme.iconSizeSmall
             }
             Label {
               anchors.horizontalCenter: parent.horizontalCenter
               wrapMode: Text.Wrap
               text: "IPNI"
               color: Theme.secondaryHighlightColor
               font.pixelSize: Theme.fontSizeTiny
            }
         }
      }
      Loader { id: moreLoader
         width: plantCard.width
         anchors.horizontalCenter: plantCard.horizontalCenter
         property bool loaded: moreLoader.status === Loader.Ready
         anchors.top: toolsRow.bottom
      }
      /*
      GBIFCard { id: gbifCard
         width: parent.width - units.gu(2)*2
         anchors.top: plantCard.bottom
         species: plantPage.plant.species
      }
      */

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
              visible: plant.family
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
