import QtQuick 2.6
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

import "../util"

Rectangle {
   id: item

   property var plantObject
   property string imageUrl
   property string mainText
   property string subText
   property bool listMode: true

   width: parent.width
   height: units.gu(8)
   radius: 10
   color: brand.background

   anchors.margins: units.gu(2)

   Image {
      id: thumbImage
      width:  parent.height - anchors.leftMargin
      height: width
      anchors.left: parent.left
      anchors.leftMargin: units.gu(1)
      anchors.verticalCenter: parent.verticalCenter

      source: item.imageUrl
      fillMode: Image.PreserveAspectCrop
      layer.enabled: true
      layer.effect: OpacityMask {
         maskSource: Item {
            width: thumbImage.width
            height: thumbImage.height

            Rectangle {
               anchors.centerIn: parent
               width: Math.min(thumbImage.width, thumbImage.height)
               height: width
               radius: 10
            }
         }
      }
   }

   Column {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: thumbImage.right
      anchors.leftMargin: units.gu(2)
      anchors.right: parent.right
      anchors.rightMargin: units.gu(2)
      spacing: units.gu(1)

      Label {
         visible: !item.listMode
         text: i18n.tr("Organ")
         width: parent.width
         elide: Text.ElideRight
         font.bold: true
         color: brand.foreground
      }

      Label {
         text: item.mainText
         width: parent.width
         elide: Text.ElideRight
         font.bold: !item.listMode
         font.italic: item.listMode
         color: brand.foreground
      }

      Label {
         visible: item.listMode
         text: item.subText
         width: parent.width
         elide: Text.ElideRight
         color: brand.foreground
      }
   }
}
