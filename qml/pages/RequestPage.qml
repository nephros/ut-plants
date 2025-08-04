import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import QtGraphicalEffects 1.0

import "../util"

import PlantsModel 1.0

Page { id: requestPage
   property var plantsModel: null


   ListModel { id: imageModel }


   SilicaListView { id: imageView
      anchors.fill: parent
      anchors.topMargin: units.gu(2)
      anchors.bottomMargin: units.gu(2)

      clip: true
      spacing: units.gu(1)

      model: imageModel

      footerPositioning: ListView.InlineFooter
      footer: (count > 0) ? footerLanel : undefined
      Component{ id: footerLabel; Label {
         width: parent.width
         anchors.topMargin: units.gu(2)
         clip: true
         text: i18n.tr('Use the Pushup menu to submit for identification.')
         color: Theme.secondaryHighlightColor
         wrapMode: Text.WordWrap
      }}
      header: Column {
         width: parent.width
         spacing: units.gu(1)
         bottomPadding: units.gu(2)
         PageHeader {
            id: header
            title: i18n.tr('New identification')
         }
         Label {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Theme.horizontalPageMargin
            text: i18n.tr('Add up to 5 images for identification. The images must be of the same plant. The more images are provided, the better the identification result will be.')
            color: Theme.highlightColor
            wrapMode: Text.WordWrap
         }
         Label {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Theme.horizontalPageMargin
            text: i18n.tr('Pl@ntNet recommends images with the smaller side larger than 600px and smaller than 2000px. Ideally a square image zoomed on the organ around 1280x1280px.')
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryHighlightColor
            wrapMode: Text.WordWrap
         }
      }
      delegate: Component {
         ListItem { id: listItem
            contentHeight: plantItem.height
            PlantItem { id: plantItem
               imageUrl: url || ''
               mainText: organ ? PlantUtils.toTitle(organ) : ''
               listMode: false
            }
            /*
            onClicked: {
               var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/PickerDialog.qml"))
               dialog.accepted.connect(function () {
                  mainText = PlantUtils.toTitle(dialog.selection)
               })
            }
            */
            openMenuOnPressAndHold: false
            onClicked: if (menuOpen) { closeMenu() } else { openMenu() }
            // avoid confusion about indexes in the Repeater:
            function setOrgan(name) { imageModel.setProperty(index, "organ", name) }
            menu: ContextMenu {
               MenuLabel { text: i18n.tr("Select plant part") }
               Repeater {
                  model: PlantUtils.organs
                  delegate: MenuItem {
                    text: modelData.title
                    onClicked: listItem.setOrgan(modelData.name)
                  }
               }
               MenuLabel { text: "--" }
               MenuItem { text: i18n.tr("Remove image")
                  onClicked: remorseDelete(function() { imageModel.remove(index, 1) })
               }
            }
         }
      }
      PullDownMenu {
         quickSelect: true
         MenuItem { text: i18n.tr("Add Images"); onClicked: addNewImage() }
         MenuItem { text: i18n.tr("Clear"); visible: imageModel.count > 0
             onClicked: Remorse.popupAction(requestPage, function() { imageModel.clear() } )
         }
      }
      PushUpMenu {
         visible: imageModel.count > 0
         busy: visible
         quickSelect: true
         MenuItem {
            text: i18n.tr("Identify")
            onClicked: {
               var request = []
               for (var i = 0; i < imageModel.count; i++) {
                  var entry = imageModel.get(i)
                  request.push({
                                  "url": entry.url.replace("file://", ""),
                                  "organ": entry.organ
                               })
               }
               plantsModel.identifyPlant(request)
               app.loadingScreenShown = true
               pageStack.pop()
            }
         }
      }
      ViewPlaceholder {
          text: i18n.tr("No images")
          hintText: i18n.tr("Pull down to add new images")
          verticalOffset: imageView.headerItem.height + Theme.itemSizeLarge
          enabled: !imageModel.count
      }

   /* moved to the top, and emptied
   ListModel {
      id: imageModel
      ListElement {
         type: "placeholder"
         url: ''
         organ: ''
      }
   }
   */

   /* apparently not used anywhere?
   Component {
      id: selectorDelegate
      OptionSelectorDelegate {
         text: title
      }
   }
   */

   /* moved to a PullUpMenu
   Button {
      id: analyzeButton
      anchors.bottom: parent.bottom
      anchors.bottomMargin: units.gu(6)
      anchors.horizontalCenter: parent.horizontalCenter

      text: i18n.tr("Identify")
      enabled: imageModel.count > 1
      onClicked: {
         var request = []

         for (var i = 0; i < imageModel.count; i++) {
            var entry = imageModel.get(i)

            if (entry.type === "placeholder")
               continue

            request.push({
                            "url": entry.url.replace("file://", ""),
                            "organ": entry.organ
                         })
         }

         plantsModel.identifyPlant(request)
         app.loadingScreenShown = true
         pageStack.pop()
      }
   }
   */

   }
   function importImages(urls) {
      urls.forEach(function (fileUrl) {
         if (imageModel.count < 6) {
            imageModel.append({
                                 "type": 'image',
                                 "url": fileUrl + '',
                                 "organ": PlantUtils.organs[1].name
                              })
         }
      })
   }

   /*
   function addNewImage() {
      var importPage = pageStack.push(Qt.resolvedUrl("ImportPage.qml"), {})
      importPage.imported.connect(importImages)
   }
   */
   function addNewImage() {
      var importPage = pageStack.push(imagePicker)
      importPage.accepted.connect(function() { requestPage.importImages(importPage.selectedFiles) })
   }
   Component { id: imagePicker
     MultiImagePickerDialog {
        property var selectedFiles: []
        onAccepted: {
            selectedFiles = ""
            var urls = []
            for (var i = 0; i < selectedContent.count; ++i) {
                var url = selectedContent.get(i).url
                // Handle url upload
                urls.push(selectedContent.get(i).url)
            }
            selectedFiles = urls
        }
     }
   }
}
