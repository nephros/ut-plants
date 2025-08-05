import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

import PlantsModel 1.0

Dialog {
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

   DialogHeader { id: header
      title: i18n.tr('Identification results')
      acceptText: i18n.tr("Save")
      cancelText: i18n.tr("Back")
   }
   canAccept:      !resultList.dragging && !resultList.moving && !resultList.flicking
   backNavigation: !resultList.dragging && !resultList.moving && !resultList.flicking
   onDone: if (result === Dialog.Accepted) {
      var err = plantsModel.savePlant(resultsData[resultList.currentIndex])
      if (err) {
         acceptDestinationProperties = {
                  "title":i18n.tr("Saving result failed"),
                  "text": i18n.tr("Result could not be saved (%1).").arg(err)
                }
         acceptDestination = Qt.resolvedUrl("../dialogs/ErrorDialog.qml")
         acceptDestinationAction = PageStackAction.Push
      }
   }

   ListView { id: resultList
      anchors.top: header.bottom
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right

      clip: true
      orientation: ListView.Horizontal
      snapMode: ListView.SnapToItem
      highlightRangeMode: ListView.StrictlyEnforceRange

      model: resultsModel

      footerPositioning: ListView.OverlayFooter
      footer: Label {
             z: 100
             height: units.gu(2)
             text: i18n.tr("%1/%2 results").arg(resultList.currentIndex+1).arg(resultsModel.count)
             color: Theme.highlightColor
             horizontalAlignment: Qt.AlignHCenter
             width: parent.width
      }
      delegate: Component {
          PlantCard {
             width: resultList.width - units.gu(2)*2
             plant: resultsData[index]
             resultView: true
         }
      }
   }
}
