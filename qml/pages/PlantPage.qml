import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

Page {
   id: plantPage

   property var plant

   SilicaFlickable {
      anchors.fill: parent
      contentHeight: header.height 
                   + plantCard.height 
                   //+ moreInfoHeader.height
                   + moreInfo.height

      PageHeader { id: header
         title: plant.family ? plant.commonNames.split(", ")[0] : i18n.tr('Plant details')
         description: plant.family ? plant.family : plant.commonNames.split(", ")[0] 
      }

      PlantCard { id: plantCard
         width: parent.width - units.gu(2)*2
         anchors.top: header.bottom
         plant: plantPage.plant
      }
      /*
      SectionHeader { id: moreInfoHeader
         anchors.top: plantCard.bottom
         text: i18n.tr("Other Sources")
         font.pixelSize: Theme.fontSizeNormal
         horizontalAlignment: Text.AlignLeft
      }
      */
      ExpandingSectionGroup { id: moreInfo
         //anchors.top: moreInfoHeader.bottom
         anchors.top: plantCard.bottom
         anchors.topMargin: spacing
         anchors.bottomMargin: spacing
         anchors.horizontalCenter: plantCard.horizontalCenter
         width: plantCard.width
         spacing: units.gu(1)
         ExpandingSection {
            title: (expanded && content.status === Loader.Ready) ? content.item.cardTitle : "Wikispecies"
            expanded: false
            onExpandedChanged: if ((expanded) && content.status === Loader.Null) {
                content.setSource("../util/WikiCard.qml", { "species": plant.species } )
            }
            //icon.source: Theme.colorScheme === Theme.LightOnDark
            //   ? "https://upload.wikimedia.org/wikipedia/commons/4/4c/W-white.png"
            //   : "https://upload.wikimedia.org/wikipedia/commons/4/4c/W-white.png"

            //   https://species.wikimedia.org//static/images/icons/specieswiki.svg
            Rectangle {
               //anchors.fill: parent
               height: parent.width
               width: parent.height
               rotation: parent.expanded ? 270 : 90
               anchors.centerIn: parent
               z: parent.content.z - 1
               gradient: Gradient {
                  GradientStop { position: -0.3; color: "#006699" } // blueish
                  GradientStop { position: 0.0;  color: "#185e3c" } // rather dark green
                  GradientStop { position: 0.5;  color: "green" }
                  GradientStop { position: 1.0;  color: "#9fdcbf" } // v. light green
                  GradientStop { position: 1.3;  color: "#2e7eb0" }
               }
               radius: 10
               /*
                * WikiSpecies colors:
                  color: "#006699" //blueish
                  color: "green;"
                * WikiMedia colors:
                  logo red: "#9a0000#
                  logo green: "#2f9a66"
                  logo blue: "#00669a"
               */
            }
         }
         ExpandingSection {
            title: expanded ? "" : "GBIF"
            //readonly property string _svg: 'data:image/svg+xml;utf8,<svg class="logo" viewBox="90 239.1 539.7 523.9" xmlns="http://www.w3.org/2000/svg"> <path class="gbif-logo-svg" d="M325.5,495.4c0-89.7,43.8-167.4,174.2-167.4C499.6,417.9,440.5,495.4,325.5,495.4"></path> <path class="gbif-logo-svg" d="M534.3,731c24.4,0,43.2-3.5,62.4-10.5c0-71-42.4-121.8-117.2-158.4c-57.2-28.7-127.7-43.6-192.1-43.6c28.2-84.6,7.6-189.7-19.7-247.4c-30.3,60.4-49.2,164-20.1,248.3c-57.1,4.2-102.4,29.1-121.6,61.9c-1.4,2.5-4.4,7.8-2.6,8.8c1.4,0.7,3.6-1.5,4.9-2.7c20.6-19.1,47.9-28.4,74.2-28.4c60.7,0,103.4,50.3,133.7,80.5C401.3,704.3,464.8,731.2,534.3,731"></path> </svg> '
            //readonly property string _svg: 'data:image/svg+xml;utf8,<svg class="logo" xmlns="http://www.w3.org/2000/svg"> <path class="gbif-logo-svg" d="M325.5,495.4c0-89.7,43.8-167.4,174.2-167.4C499.6,417.9,440.5,495.4,325.5,495.4"></path> <path class="gbif-logo-svg" d="M534.3,731c24.4,0,43.2-3.5,62.4-10.5c0-71-42.4-121.8-117.2-158.4c-57.2-28.7-127.7-43.6-192.1-43.6c28.2-84.6,7.6-189.7-19.7-247.4c-30.3,60.4-49.2,164-20.1,248.3c-57.1,4.2-102.4,29.1-121.6,61.9c-1.4,2.5-4.4,7.8-2.6,8.8c1.4,0.7,3.6-1.5,4.9-2.7c20.6-19.1,47.9-28.4,74.2-28.4c60.7,0,103.4,50.3,133.7,80.5C401.3,704.3,464.8,731.2,534.3,731"></path> </svg> '
            expanded: false
            onExpandedChanged: if ((expanded) && content.status === Loader.Null) {
                if (plant.gbifId != "-1") {
                    content.setSource("../util/GBIFCard.qml", { "gbifId": plant.gbifId } )
                } else {
                    content.setSource("../util/GBIFCard.qml", { "species": plant.species } )
                } 
            }
            Rectangle {
               anchors.fill: parent
               z: parent.content.z - 1
               color:  "#41af46"
               radius: 10
            }
         }
         ExpandingSection {
            //visible: settings.allowLocation
            title: expanded ? "" : "GBIF Map"
            //readonly property string _svg: 'data:image/svg+xml;utf8,<svg class="logo" viewBox="90 239.1 539.7 523.9" xmlns="http://www.w3.org/2000/svg"> <path class="gbif-logo-svg" d="M325.5,495.4c0-89.7,43.8-167.4,174.2-167.4C499.6,417.9,440.5,495.4,325.5,495.4"></path> <path class="gbif-logo-svg" d="M534.3,731c24.4,0,43.2-3.5,62.4-10.5c0-71-42.4-121.8-117.2-158.4c-57.2-28.7-127.7-43.6-192.1-43.6c28.2-84.6,7.6-189.7-19.7-247.4c-30.3,60.4-49.2,164-20.1,248.3c-57.1,4.2-102.4,29.1-121.6,61.9c-1.4,2.5-4.4,7.8-2.6,8.8c1.4,0.7,3.6-1.5,4.9-2.7c20.6-19.1,47.9-28.4,74.2-28.4c60.7,0,103.4,50.3,133.7,80.5C401.3,704.3,464.8,731.2,534.3,731"></path> </svg> '
            //readonly property string _svg: 'data:image/svg+xml;utf8,<svg class="logo" xmlns="http://www.w3.org/2000/svg"> <path class="gbif-logo-svg" d="M325.5,495.4c0-89.7,43.8-167.4,174.2-167.4C499.6,417.9,440.5,495.4,325.5,495.4"></path> <path class="gbif-logo-svg" d="M534.3,731c24.4,0,43.2-3.5,62.4-10.5c0-71-42.4-121.8-117.2-158.4c-57.2-28.7-127.7-43.6-192.1-43.6c28.2-84.6,7.6-189.7-19.7-247.4c-30.3,60.4-49.2,164-20.1,248.3c-57.1,4.2-102.4,29.1-121.6,61.9c-1.4,2.5-4.4,7.8-2.6,8.8c1.4,0.7,3.6-1.5,4.9-2.7c20.6-19.1,47.9-28.4,74.2-28.4c60.7,0,103.4,50.3,133.7,80.5C401.3,704.3,464.8,731.2,534.3,731"></path> </svg> '
            expanded: false
            enabled: plant.gbifId != "-1"
            opacity: enabled ? 1.0 :  Theme.opacityFaint
            onExpandedChanged: if ((expanded) && content.status === Loader.Null) {
                content.setSource("../util/GBIFMap.qml", { "gbifId": plant.gbifId } )
            }
            Rectangle {
               anchors.fill: parent
               z: parent.content.z - 1
               color:  "#41af46"
               radius: 10
            }
         }
         ExpandingSection {
            title: "POWO"
            expanded: false
            enabled: false
            opacity: enabled ? 1.0 :  Theme.opacityFaint
            //readonly property string _svg: 'data:image/svg+xml;utf8,<svg id="Plantae-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 15 15" width="100%" height="100%" role="img" aria-label="Plant"> <title>Plant</title> <path d="M15,0.7L15,0.7c-0.1-0.3-0.3-0.5-0.6-0.6v0c-1.2-0.3-7.7,0.4-11.3,4c-3.3,3.3-2,7.2-1.4,8.6L0,14.4l0.7,0.7l1.8-1.8 c0.4,0.2,1.8,0.8,3.5,0.8c1.6,0,3.4-0.5,5-2.1C14.7,8.3,15.3,1.8,15,0.7z M11.2,10.2c-1,0.2-3.4,0.5-5.6,0l2.1-2.1 c0.5,0.1,1.5,0.2,2.6,0.2c0.7,0,1.4,0,2.1-0.2C12.1,8.9,11.7,9.6,11.2,10.2z M10,1.6c-0.2,1.3-0.2,2.5-0.2,3L7.9,6.5 C7.8,5.4,7.7,3.8,8.1,2.2C8.7,1.9,9.4,1.7,10,1.6z M13.4,1l-2.6,2.6c0-0.7,0.1-1.5,0.2-2.3C12,1.1,12.8,1,13.4,1z M7,7.4L4.9,9.5 c-0.6-2.2-0.2-4.7,0-5.6C5.5,3.4,6.2,3,7,2.7C6.6,4.6,6.9,6.5,7,7.4z M12.9,7.1c-1.6,0.4-3.3,0.3-4.3,0.2l1.9-1.9c0.2,0,0.4,0,0.7,0 c0.6,0,1.4,0,2.3-0.2C13.4,5.8,13.2,6.4,12.9,7.1z M13.8,4.1c-0.8,0.2-1.6,0.2-2.3,0.2l2.6-2.6C14.1,2.3,14,3.1,13.8,4.1z M3.7,4.9 c-0.2,1.4-0.2,3.5,0.4,5.4l-1.6,1.6C1.9,10.3,1.3,7.4,3.7,4.9z M3.3,12.6L4.8,11c1.1,0.4,2.4,0.5,3.5,0.5c0.7,0,1.4,0,1.9-0.1 C7.5,13.9,4.5,13.1,3.3,12.6z"/> </svg>'
         }
         ExpandingSection {
            title: "IPNI"
            expanded: false
            enabled: false
            opacity: enabled ? 1.0 :  Theme.opacityFaint
            //icon.source: "data:image/png;base64,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"
         }
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
              visible: plant.family
              text: i18n.tr("Copy family to Clipboard")
              onDelayedClick: Clipboard.text = plant.family
          }
          MenuItem {
              text: i18n.tr("Search on Wikipedia")
              // FIXME: support language:
              onClicked: Qt.openUrlExternally("https://wikipedia.org/w/index.php?"
                   + '&title=%1'.arg(encodeURI(plant.species))
                   )
          }
      }
   }
}
