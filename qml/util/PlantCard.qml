import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

Rectangle { id: plantCard
   width: parent.width * 0.8
   height: parent.height
   anchors.centerIn: parent
   radius: 10
   color: brand.background

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
      anchors.margins: units.gu(1)

      spacing: plantCard.elementSpacing

      Item {
         id: header
         width: parent.width
         height: units.gu(4)

         Column {
            id: nameColumn
            anchors.top: parent.top
            anchors.left: parent.left

            Text {
               text: i18n.tr("Name")
               font.bold: true
               color: brand.foreground
            }
            Text {
               text: plant.species
               color: brand.foreground
            }
         }

         Row {
            anchors.top: parent.top
            anchors.right: parent.right
            height: nameColumn.height

            spacing: units.gu(1)

            Icon {
               anchors.verticalCenter: scoreLabel.verticalCenter
               source: "image://theme/icon-m-diagnostic"
               width: height
               height: scoreLabel.height
            }
            Label { id: scoreLabel
               property int scoreValue: Math.round(plant.score * 100)

               anchors.verticalCenter: parent.verticalCenter
               text: scoreValue + "%"
               font.pixelSize: units.gu(2)
               font.bold: true

               color: scoreValue > 80 ? brand.foreground : (scoreValue
                                                   > 50 ? brand.warn : brand.danger)
            }
         }
      }

      Rectangle {
         width: parent.width
         height: 1
         color: brand.foreground
      }

      ListView {
         id: resultImagesList
         anchors.left: parent.left
         width: parent.width
         height: parent.height * 0.5
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

      Text {
         color: brand.foreground
         text: i18n.tr("Common names")
         font.bold: true
      }

      Text {
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
