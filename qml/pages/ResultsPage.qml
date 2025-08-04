import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

import PlantsModel 1.0

Page {
   id: mainPage
   anchors.fill: parent

   property var plantsModel: nil
   property var resultsData: []

   Component.onCompleted: {
      resultsData.forEach(function (res) {
         resultsModel.append(res)
      })
   }

   SilicaFlickable {
     PageHeader { id: header
        title: i18n.tr('Identification results')
        description: i18n.tr("%1/%2 results").arg(resultList.currentIndex+1).arg(resultsModel.count)
     }

     ListModel {
        id: resultsModel
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
     }

     SilicaListView {
        id: resultList
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        clip: true
        orientation: ListView.Horizontal
        snapMode: ListView.SnapToItem
        highlightRangeMode: ListView.StrictlyEnforceRange

        model: resultsModel

        delegate: Component {
           ListItem {
              width:  ListView.view.width
              height: ListView.view.height
              contentHeight: plantCard.height
              PlantCard { id: plantCard
                 anchors.fill: parent
                 anchors.centerIn: parent
                 plant: resultsData[index]
                 resultView: true
              }
              menu: ContextMenu {
                 MenuItem {
                    text: i18n.tr("Save this result")
                    onClicked: {
                       var err = plantsModel.savePlant(resultsData[index])

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
     }
   }
}
