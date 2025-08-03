import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import QtGraphicalEffects 1.0

import "../util"

import PlantsModel 1.0

Page { id: requestPage
   property var plantsModel: null

   PageHeader {
      id: header
      title: i18n.tr('New identification')
   }

   function importImages(urls) {
      urls.forEach(function (fileUrl) {
         if (imageModel.count < 6) {
            imageModel.insert(imageModel.count - 1, {
                                 "type": 'image',
                                 "url": fileUrl + '',
                                 "organ": PlantUtils.organs[1].name
                              })
         }
      })
   }

   Text {
      id: titleText
      anchors.top: header.bottom
      anchors.topMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width * 0.9
      text: i18n.tr(
               'Add up to 5 images for identification. The images must be of the same plant. The more images are provided, the better the identification result will be.') + '\n\n' + i18n.tr(
               'Pl@ntNet recommends images with the smaller side larger than 600px and smaller than 2000px. Ideally a square image zoomed on the organ around 1280x1280px.')
      color: Theme.primaryColor

      wrapMode: Text.WordWrap
   }

   ListModel {
      id: imageModel
      ListElement {
         type: "placeholder"
         url: ''
         organ: ''
      }
   }

   /* apparently not used anywhere?
   Component {
      id: selectorDelegate
      OptionSelectorDelegate {
         text: title
      }
   }
   */

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

   SilicaListView {
      id: imageList
      property double rowSpacing: units.gu(1)

      header: ComboBox { id: langMenu
          label: i18n.tr("Result Language")
          value: "en"
          menu: ContextMenu {
              Repeater { model: plantsModel.availableLanguages
                  delegate: MenuItem { text: modelData }
              }
          }
          Connections { target: plantsModel
              onLanguagesChanged: function(langs) {
                  if (langs.length == 1) {
                    langMenu.value = "en"
                  }
              }
          }
          onValueChanged: plantsModel.setLanguage(value)
      }
      model: imageModel
      anchors.topMargin: units.gu(2)
      anchors.top: titleText.bottom
      anchors.bottom: analyzeButton.top
      anchors.bottomMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width * 0.9
      spacing: rowSpacing
      clip: true

      delegate: Component {
         PlantItem {
            imageUrl: url || ''
            mainText: organ && PlantUtils.toTitle(organ) || ''
            listMode: false
            placeholder: type === "placeholder"
            visible: !placeholder || imageModel.count < 6

            onClicked: function () {
               if (type !== "placeholder")
                  return

               addNewImage()
            }

            onEdit: function () {
               var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/PickerDialog.qml"))

               dialog.accepted.connect(function () {
                  mainText = PlantUtils.toTitle(dialog.selection)
               })
            }

            onDelete: function () {
               imageModel.remove(index, 1)
            }
         }
      }
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
