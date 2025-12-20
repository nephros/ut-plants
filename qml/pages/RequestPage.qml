import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.6
import Nemo.DBus 2.0

import "../util"

Page { id: requestPage
   objectName: "requestPage"

   ListModel { id: imageModel }

   SilicaListView { id: imageView
      anchors.fill: parent

      clip: true
      spacing: units.gu(1)

      model: imageModel

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
         busy: imageModel.count == 0
         MenuItem { text: enabled ? i18n.tr("Add from Gallery") : i18n.tr("Can not add more than 5 images"); enabled: imageModel.count < 5; onClicked: addNewImage() }
         //MenuItem { text: i18n.tr("Take Pictures"); onClicked: openCameraExternally() }
         MenuItem { text: i18n.tr("Take Photos"); onClicked: openCameraPage() }
         MenuItem {
            enabled: imageModel.count > 0
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
      PushUpMenu {
         visible: imageModel.count > 0
         quickSelect: true
         MenuItem { text: i18n.tr("Remove All")
             onClicked: Remorse.popupAction(requestPage, i18n.tr("Cleared"), function() { imageModel.clear() }, 2800 )
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
                                 "organ": PlantUtils.organs[0].name
                              })
         }
      })
   }

   // populated when coming from Sailfish.Share
   property var sharedImages: ([])
   onSharedImagesChanged: {
       console.debug("Request: received", sharedImages.length, "images")
       if (sharedImages.length >0) requestPage.importImages(sharedImages)
   }

   /*
   function openCameraExternally() {
       cameraInterface.call("showViewfinder", "")
   }
   DBusInterface { id: cameraInterface
     service: "com.jolla.camera"
     path: "/"
     iface: "com.jolla.camera.ui";
   }
   */
   function openCameraPage() {
      var camPage = pageStack.push(cameraPage)
      camPage.accepted.connect(function() { requestPage.importImages(camPage.capturedImages) })
   }
   Component { id: cameraPage
        Dialog { id: camPageRoot
            property var capturedImages: ([]) // to gather the dialog results
            onAccepted: {
                if (result === DialogResult.Accepted) {
                    for (var i = 0; i<imagesModel.count; ++i) {
                        const im = imagesModel.get(i)
                        if (im.use) capturedImages.push(im.url)
                    }
                }
            }
            ListModel { id: imagesModel } // for the preview
            DialogHeader { id: header
                acceptText: i18n.tr("Use Photos")
                cancelText: i18n.tr("Back")
            }
            Camera { id: camera
                captureMode: Camera.CaptureStillImage
                imageCapture {
                    onImageCaptured: {
                        //photoPreview.source = preview  // Show the preview in an Image
                        console.debug("preview image:", preview)
                    }
                    onImageSaved: {
                        flashRect.run()
                        imagesModel.append( { "use": true, "path": path, "url": Qt.resolvedUrl("file://" + path) })
                        console.debug("saved image:", path)
                    }
                }
                exposure {
                    //exposureCompensation: -1.0
                    exposureMode: Camera.ExposureLargeAperture
                    meteringMode: Camera.MeteringSpot
                }
                focus {
                    focusMode: Camera.FocusMacro
                }
                flash.mode: Camera.FlashOff
            }
            VideoOutput { id: video
                z: -1
                source: camera
                anchors.fill: parent
                focus : visible // to receive focus and capture key events when visible
            }

            Rectangle { id: flashRect
                anchors.centerIn: video
                height: video.height
                width: video.width
                visible: anim.running
                function run() { anim.start() }
                ParallelAnimation { id: anim
                   ColorAnimation {
                      target: flashRect
                      duration: 1500
                      from: "white"; to: "transparent"
                      easing.type: Easing.OutQuad
                   }
                   PropertyAnimation {
                      target: flashRect
                      duration: 1500
                      property: "opacity"
                      from: 0.8; to: 0.0
                      easing.type: Easing.OutQuad
                      onStopped: flashRect.opacity = from
                   }
                }
            }

            SlideshowView { id: photoPreview
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: header.bottom
                anchors.topMargin: Theme.paddingMedium
                width: parent.width - Theme.itemSizeMedium
                height: Theme.iconSizeLarge
                //z: video.z + 1
                //clip: true
                orientation: Qt.Horizontal
                model: imagesModel
                itemHeight: Theme.iconSizeLarge
                itemWidth: Theme.iconSizeLarge
                delegate: Image {
                    onStatusChanged: console.debug("I:", status, url)
                    source: url
                    height: Theme.iconSizeLarge
                    width: height
                    opacity: use ? 1.0 : Theme.opacityLow
                    BackgroundItem {
                        anchors.fill: parent
                        onClicked: imagesModel.setProperty(index, "use", false)
                    }
                    Icon {
                        source: use ? "image://theme/icon-s-accept" :  "image://theme/icon-s-decline"
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        height: Theme.iconSizeExtraSmall
                        width: height
                    }
                }
            }
            /*
            TextSwitch { id: focusWait
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: shooter.top
                text: i18n.tr("Wait for focus")
                checked: true
            }
            */
            IconButton { id: shooter
                icon.source: "image://theme/icon-camera-shutter"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: video.bottom
                anchors.bottomMargin: Theme.itemSizeLarge
                icon.width: Theme.iconSizeExtraLarge
                icon.height: Theme.iconSizeExtraLarge
                onClicked: shoot()
                onPressed: searchAndShoot()
            }
            Image { id: openCam
                source: "image://theme/icon-launcher-camera"
                anchors.right: parent.right
                anchors.rightMargin: Theme.itemSizeLarge
                anchors.bottom: video.bottom
                anchors.bottomMargin: Theme.itemSizeLarge
                sourceSize.width: Theme.iconSizeLauncher
                sourceSize.height: Theme.iconSizeLauncher
                width: Theme.iconSizeLauncher
                height: Theme.iconSizeLauncher
                BackgroundItem { anchors.fill: parent
                    onClicked:  { cameraInterface.call("showViewfinder", ""); pageStack.pop() }
                    DBusInterface { id: cameraInterface
                      service: "com.jolla.camera"
                      path: "/"
                      iface: "com.jolla.camera.ui";
                    }
                }
            }
            function searchAndShoot() {
                camera.lockStatusChanged.connect(function() {
                    if (camera.lockStatus === Camera.Locked) {
                        console.debug("focus locked")
                        camera.imageCapture.captureToLocation(
                            StandardPaths.temporary
                            + "/" + Qt.application.name + "_"
                            + Date.now() + ".jpg"
                        )
                    }
                })
                camera.searchAndLock()
            }
            function shoot() {
                camera.imageCapture.captureToLocation(
                    StandardPaths.temporary
                    + "/" + Qt.application.name + "_"
                    + Date.now() + ".jpg"
                )
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
