import QtQuick 2.4
import Sailfish.Silica 1.0

Dialog {
   id: errorDialog
   property alias title: head.title
   canAccept: false
   property alias text: content.text
   DialogHeader { id: head ; cancelText: i18n.tr("Close"); acceptText: "" }
   Label { id: content
      anchors.top: head.bottom
      anchors.topMargin: Theme.paddingLarge
      x: Theme.horizontalPageMargin
      width: parent.width - Theme.horizontalPageMargin*2
      color: Theme.secondaryColor
      wrapMode: Text.Wrap
   }
}

