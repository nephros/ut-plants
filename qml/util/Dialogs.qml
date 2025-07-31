pragma Singleton

import QtQuick 2.4
import Sailfish.Silica 1.0

import "../util"

Item {
   Component {
      id: questionDialogComponent

      Dialog {
         id: questionDialog
         property alias title: head.title 
         property alias acceptButtonTitle: head.acceptText
         property alias cancelButtonTitle: head.cancelText
         property alias text: content.text
         DialogHeader { id: head }
         Label { id: content
            anchors.top: head.bottom
            anchors.topMargin: Theme.paddingLarge
            x: Theme.horizontalPageMargin
            wrapMode: Text.Wrap
         }
      }
   }
   Component {
      id: errorDialogComponent

      Dialog {
         id: errorDialog
         property alias title: head.title 
         //property alias acceptButtonTitle: head.acceptText
         //property alias cancelButtonTitle: head.cancelText
         canAccept: false
         property alias text: content.text
         DialogHeader { id: head ; cancelText: i18n.tr("Close") }
         Label { id: content
            anchors.top: head.bottom
            anchors.topMargin: Theme.paddingLarge
            x: Theme.horizontalPageMargin
            wrapMode: Text.Wrap
         }
      }
   }
   Component {
      id: pickerDialogComponent

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
            model: PlantUtils.organs.length
            delegate: TextSwitch {
               text: PlantUtils.organs[index].title
               checked:   pickerDialog.selection == PlantUtils.organs[index].name
               onClicked: pickerDialog.selection = PlantUtils.organs[index].name
            }
         }
      }
   }
   Component {
      id: storageErrorDialogComponent

      Dialog {
         id: storageErrorDialog
         //property alias title: head.title 
         //property alias acceptButtonTitle: head.acceptText
         //property alias cancelButtonTitle: head.cancelText
         //property alias text: content.text
         canAccept: false
         property string errorString
         DialogHeader { id: head ; cancelText: i18n.tr("Close"); title: i18n.tr("Failed to init storage directory") }
         Label { id: content
            anchors.top: head.bottom
            anchors.topMargin: Theme.paddingLarge
            x: Theme.horizontalPageMargin
            wrapMode: Text.Wrap
            text: i18n.tr("Storage directory could not be initialized (%1).").arg(errorString)
         }


}
   }

   function showQuestionDialog(parent, title, text, acceptButtonTitle, cancelButtonTitle, acceptButtonColor) {
      return pageStack.push(questionDialogComponent, {
                                "title": title,
                                "text": text,
                                "acceptButtonTitle": acceptButtonTitle,
                                "cancelButtonTitle": cancelButtonTitle,
                                "acceptButtonColor": acceptButtonColor
                             })
   }
   function showErrorDialog(parent, title, text) {
      return pageStack.push(errorDialogComponent, {
                                "title": title,
                                "text": text
                             })
   }
   function showPickerDialog(parent) {
      return pageStack.push(pickerDialogComponent)
   }

/*
   Component {
      id: questionDialogComponent

      Dialog {
         id: questionDialog
         property string acceptButtonTitle: i18n.tr("Okay")
         property string cancelButtonTitle: i18n.tr("Cancel")
         property color acceptButtonColor: LomiriColors.green

         signal accepted
         signal rejected

         Button {
            text: acceptButtonTitle
            color: acceptButtonColor
            onClicked: {
               questionDialog.accepted()
               PopupUtils.close(questionDialog)
            }
         }
         Button {
            text: cancelButtonTitle
            onClicked: {
               questionDialog.rejected()
               PopupUtils.close(questionDialog)
            }
         }
      }
   }

   Component {
      id: errorDialogComponent

      Dialog {
         id: errorDialog
         signal accepted

         Button {
            text: i18n.tr("Close")
            onClicked: {
               errorDialog.accepted()
               PopupUtils.close(errorDialog)
            }
         }
      }
   }

   Component {
      id: pickerDialogComponent

      Dialog {
         id: pickerDialog
         property string selection: PlantUtils.organs[0].name
         property color acceptButtonColor: LomiriColors.green

         signal accepted

         Text {
            text: i18n.tr("Select plant part")
         }

         Repeater {
            model: PlantUtils.organs.length

            QC.RadioButton {
               text: PlantUtils.organs[index].title
               onClicked: selection = PlantUtils.organs[index].name
            }
         }

         Button {
            text: i18n.tr("Select")
            color: acceptButtonColor
            onClicked: {
               pickerDialog.accepted()
               PopupUtils.close(pickerDialog)
            }
         }
      }
   }

   Component {
      id: storageErrorDialogComponent

      Dialog {
         id: storageErrorDialog
         title: i18n.tr("Failed to init storage directory")
         text: i18n.tr("Storage directory could not be initialized (%1).").arg(
                  errorString)

         property string errorString

         Button {
            text: i18n.tr("Close")
            onClicked: {
               PopupUtils.close(storageErrorDialog)
            }
         }
      }
   }

   function showQuestionDialog(parent, title, text, acceptButtonTitle, cancelButtonTitle, acceptButtonColor) {
      return PopupUtils.open(questionDialogComponent, parent, {
                                "title": title,
                                "text": text,
                                "acceptButtonTitle": acceptButtonTitle,
                                "cancelButtonTitle": cancelButtonTitle,
                                "acceptButtonColor": acceptButtonColor
                             })
   }

   function showErrorDialog(parent, title, text) {
      return PopupUtils.open(errorDialogComponent, parent, {
                                "title": title,
                                "text": text
                             })
   }

   function showPickerDialog(parent) {
      return PopupUtils.open(pickerDialogComponent, parent, {})
   }
*/
}
