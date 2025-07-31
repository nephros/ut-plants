import QtQuick 2.4
import Sailfish.Silica 1.0

Dialog {
   id: pickerDialog
   property alias title: head.title 
   property alias acceptButtonTitle: head.acceptText
   property alias cancelButtonTitle: head.cancelText
   //property alias text: content.text
   property string selection: PlantUtils.organs[0].name
   DialogHeader { id: head; title: i18n.tr("Select plant part") }
   ColumnView { id: content
      anchors.top: head.bottom
      anchors.topMargin: Theme.paddingLarge
      x: Theme.horizontalPageMargin
      width: parent.width - Theme.horizontalPageMargin*2
      model: PlantUtils.organs.length
      delegate: TextSwitch {
         text: PlantUtils.organs[index].title
         checked:   pickerDialog.selection == PlantUtils.organs[index].name
         onClicked: pickerDialog.selection = PlantUtils.organs[index].name
      }
   }
}
