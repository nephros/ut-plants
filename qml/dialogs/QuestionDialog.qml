import QtQuick 2.4
import Sailfish.Silica 1.0

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
      width: parent.width - Theme.horizontalPageMargin*2
      color: Theme.highlightColor
      wrapMode: Text.Wrap
   }
}

