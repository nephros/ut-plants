import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

Rectangle { id: plantCard
   radius: 10
   color: brand.background
   height: contents.height
   anchors.margins: units.gu(2)
   anchors.horizontalCenter: parent.horizontalCenter

   property bool resultView: false
   property var saveFunction: null
   property var plant: null
   property double elementSpacing: units.gu(2)

   Component.onCompleted: {
      plant.images.forEach(function (image) {
         resultImageModel.append(image)
      })
   }

   ListModel {
      id: resultImageModel
   }

   Column {
      id: contents
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      padding: units.gu(2)

      spacing: plantCard.elementSpacing

      Label {
         text: i18n.tr("Name")
         font.bold: true
         color: brand.foreground
         Row {
            anchors.right: parent.right
            height: parent.height
            spacing: units.gu(1)
            Icon {
               anchors.verticalCenter: scoreLabel.verticalCenter
               source: "image://theme/icon-m-diagnostic"
               width: height
               height: scoreLabel.height
            }
            Label { id: scoreLabel
               property int scoreValue: Math.round(plant.score * 100)

               anchors.top: parent.top
               text: scoreValue + "%"
               font.pixelSize: units.gu(2)
               font.bold: true

               color: scoreValue > 80
                        ? brand.foreground
                        : (scoreValue > 50 ? brand.warn : brand.danger)
            }
         }
      }
      Label {
         text: plant.species
         color: brand.foreground
      }

      Rectangle {
         width: parent.width
         height: 1
         color: brand.foreground
      }

      ListView {
         id: resultImagesList
         anchors.horizontalCenter: parent.horizontalCenter
         width: parent.width - units.gu(2)
         height: width
         model: resultImageModel

         clip: true
         orientation: ListView.Horizontal
         snapMode: ListView.SnapToItem
         highlightRangeMode: ListView.StrictlyEnforceRange

         delegate: Component {
            Item {
               width: resultImagesList.width
               height: resultImagesList.height

               Image {
                  source: prepareImageUrl(url)
                  width: parent.width
                  height: parent.height
                  asynchronous: true

                  fillMode: Image.PreserveAspectCrop
               }

               Label {
                  color: brand.foreground
                  text: copyright
                  style: Text.Raised
                  styleColor: Theme.darkPrimaryColor
                  font.pixelSize: units.gu(1)
               }
            }
         }
      }

      /*
      QC.PageIndicator {
         anchors.horizontalCenter: parent.horizontalCenter
         currentIndex: resultImagesList.currentIndex
         count: resultImagesList.count
      }
      */

      Label {
         color: brand.foreground
         text: i18n.tr("Common names")
         font.bold: true
      }

      Label {
         color: brand.foreground
         width: parent.width
         text: plant.commonNames
         wrapMode: Text.WordWrap
      }
   }

   function prepareImageUrl(url) {
      if (!url)
         return url

      if (url[0] === '/')
         return 'file://' + url

      return url
   }
}
