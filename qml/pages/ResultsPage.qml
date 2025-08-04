import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

import PlantsModel 1.0

Page {
   id: resultsPage

   property var plantsModel: nil
   property var resultsData: []

   Component.onCompleted: {
      resultsData.forEach(function (res) {
         resultsModel.append(res)
      })
   }

   ListModel {
      id: resultsModel
   }

   SilicaFlickable {
      anchors.fill: parent
      contentHeight: header.height + resultList.height

      PageHeader { id: header
         title: i18n.tr('Identification results')
         description: i18n.tr("%1/%2 results").arg(resultList.currentIndex+1).arg(resultsModel.count)
      }

      ListView { id: resultList

         width: parent.width - units.gu(2)*2
         height: width*0.8
         anchors.top: header.bottom
         anchors.horizontalCenter: parent.horizontalCenter

         clip: true
         orientation: ListView.Horizontal
         snapMode: ListView.SnapToItem
         highlightRangeMode: ListView.StrictlyEnforceRange

         model: resultsModel

         delegate: Component {
             PlantCard {
                width: resultList.width
                plant: resultsData[index]
                resultView: true
            }
         }
      }
     PullDownMenu {
        visible: resultsData.length
        MenuItem {
           text: i18n.tr("Save all results")
           onClicked: {
              var err = false
              for (var i=0; i<resultsData.length; ++i) {
                 const plant = resultsData[i]
                 err = err && plantsModel.savePlant(plant)
              }
              if (err) {
                 pageStack.push(Qt.resolvedUrl("dialogs/ErrorDialog.qml"),
                        {
                          "title":i18n.tr("Saving result failed"),
                          "text": i18n.tr("Result could not be saved (%1).").arg(err)
                        }
                 )
              } else {
                 pageStack.pop()
              }
           }
        }
        MenuItem {
           text: i18n.tr("Save this result")
           onClicked: {
              var err = plantsModel.savePlant(resultList[currentIndex])
              if (!err) {
                 pageStack.pop()
              } else {
                 pageStack.push(Qt.resolvedUrl("dialogs/ErrorDialog.qml"),
                        {
                          "title":i18n.tr("Saving result failed"),
                          "text": i18n.tr("Result could not be saved (%1).").arg(err)
                        }
                 )
              }
           }
        }
     }
   }
}
