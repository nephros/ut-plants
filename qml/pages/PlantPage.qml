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
            title: (expanded && content.status === Loader.Ready) ? content.item.cardTitle : "Wikipedia"
            expanded: false
            onExpandedChanged: if ((expanded) && content.status === Loader.Null) {
                content.setSource("../util/WikiCard.qml",
                                  { "species": plant.species,
                                    "language": plantsModel.language ? Qt.locale().name.substr(0,2) : "en"
                                  })
            }
            Rectangle {
               //anchors.fill: parent
               height: parent.width
               width: parent.height
               rotation: parent.expanded ? 270 : 90
               anchors.centerIn: parent
               z: parent.content.z - 1
               gradient: Gradient {
                  /* Wikipedia, see https://foundation.wikimedia.org/wiki/Legal:Visual_identity_guidelines#toc-colorvalues */
                  GradientStop { position: 0.0; color: "#000" }
                  GradientStop { position: 1.0;  color: "#fff" }
                  /* Wikimedia/Wikispecies:
                  GradientStop { position: -0.3; color: "#006699" } // blueish
                  GradientStop { position: 0.0;  color: "#185e3c" } // rather dark green
                  GradientStop { position: 0.5;  color: "green" }
                  GradientStop { position: 1.0;  color: "#9fdcbf" } // v. light green
                  GradientStop { position: 1.3;  color: "#2e7eb0" }
                  */
               }
               radius: 10
            }
         }
         ExpandingSection {
            title: "GBIF"
            expanded: false
            enabled: false
            opacity: enabled ? 1.0 :  Theme.opacityFaint
         }
         ExpandingSection {
            title: "GBIF Maps"
            expanded: false
            enabled: false
            opacity: enabled ? 1.0 :  Theme.opacityFaint
         }
         ExpandingSection {
            title: "POWO"
            expanded: false
            enabled: false
            opacity: enabled ? 1.0 :  Theme.opacityFaint
         }
         ExpandingSection {
            title: "IPNI"
            expanded: false
            enabled: false
            opacity: enabled ? 1.0 :  Theme.opacityFaint
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
