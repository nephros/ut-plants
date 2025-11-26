import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

import "../util"
import "../compat"

Page {
   id: mainPage
   objectName: "mainPage"
   //property bool loadingScreenShown: false

   Component.onCompleted: {
      var err = plantsModel.init()

      if (err) {
         pageStack.push(Qt.resolvedUrl("../dialogs/ErrorDialog.qml"),
                    {
                        "title": i18n.tr("Failed to init storage directory"),
                        "text": i18n.tr("Storage directory could not be initialized (%1).").arg(err)
                    }
         )
      } else {
         plantsModel.reload()
      }
   }

    SilicaListView { id: plantList
       anchors.fill: parent
       header: PageHeader {
           title: i18n.tr('Plants')
           description: app.loadingScreenShown
           ? i18n.tr("Plant is being identified, please wait.")
           : (plantList.count > 0 )
           ? (plantList.count == 1)
           ? i18n.tr("1 identified plant")
           : i18n.tr( "%1 identified plants").arg(plantList.count)
           : ""
           BusyIndicator {
             anchors.verticalCenter: parent.verticalCenter
               anchors.left: extraContent.left
               anchors.leftMargin: units.gu(1)
               size: BusyIndicatorSize.Medium
               running: app.loadingScreenShown
           }
       }
       clip: true
       spacing: units.gu(1)

       model: plantsModel

       delegate: Component {
         ListItem {
            anchors.margins: units.gu(2)
            contentHeight: plantItem.height
            PlantItem { id: plantItem
               imageUrl: "image://plants/" + plant.id
               mainText: plant.species
               subText: plant.commonNames
               plantObject: plant
               listMode: true
               moving: plantList.moving
            }
            onClicked: pageStack.push(Qt.resolvedUrl("PlantPage.qml"), { "plant": plant })
            menu: ContextMenu {
               MenuItem { text: i18n.tr("Remove")
                 onClicked: remorseDelete(function() { deletePlant(plant.id) })
               }
            }
            function deletePlant(plantID) {
               var err = plantsModel.deletePlant(plantID)
               if (err) {
                 pageStack.push(Qt.resolvedUrl("../dialogs/ErrorDialog.qml"),
                     { "title": i18n.tr("Deleting plant failed"),
                     "text": i18n.tr("Plant could not be deleted (%1).").arg(err)
                     }
                     )
               }
            }
         }
      }
      ViewPlaceholder {
         id: placeholder
         text: i18n.tr("No plants identified yet")
         hintText: i18n.tr("Pull down to start a new identification")
         enabled: !plantsModel.count
      }
      PushUpMenu {
         MenuItem {
            text: i18n.tr("New identification")
            enabled: !app.loadingScreenShown
            onClicked: {
               if (!settings.apiKey) {
                  var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/ErrorDialog.qml"),
                      { "title": i18n.tr("API Key missing"),
                      "text":  i18n.tr("The Pl@ntNet API-Key has not been configured yet. Without this, the app will not work.")
                      })

                  dialog.accepted.connect(function () {
                      mainPage.openSettings()
                      })
               } else {
                  mainPage.openIdentify()
               }
            }
         }
      }
      PullDownMenu {
         MenuItem {
            text: i18n.tr("New identification")
            enabled: !app.loadingScreenShown
            onClicked: {
               if (!settings.apiKey) {
                  var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/ErrorDialog.qml"),
                      { "title": i18n.tr("API Key missing"),
                      "text":  i18n.tr("The Pl@ntNet API-Key has not been configured yet. Without this, the app will not work.")
                      })

                  dialog.accepted.connect(function () {
                      mainPage.openSettings()
                      })
               } else {
                  mainPage.openIdentify()
               }
            }
         }
         MenuItem {
            text: i18n.tr('Settings')
            onClicked: {
               mainPage.openSettings()
            }
         }
      }
      Disclaimer {
         id: disclaimer
         visible: !settings.disclaimerAccepted
      }

      Rectangle {
         color: "#67676799"
         anchors.fill: parent
         visible: disclaimer.visible
         z: 100
         MouseArea {
            anchors.fill: parent
            onClicked: {}
         }
      }
   }

   function openIdentify() {
     pageStack.push(Qt.resolvedUrl("RequestPage.qml"), {
         "plantsModel": plantsModel
         })
   }
   function openSettings() {
      var p = pageStack.push(Qt.resolvedUrl("./SettingsPage.qml"),
          { languages: plantsModel.availableLanguages(),
            regions: plantsModel.availableRegions()
          }
      )

      p.regChanged.connect(function (reg) {
        console.info("Storing region from Settings:", reg)
        plantsModel.setRegion(reg)
      })
      p.langChanged.connect(function (lang) {
        console.info("Storing language from Settings:", lang)
        plantsModel.setLanguage(lang)
      })
      p.apiKeyChanged.connect(function (key) {
         console.info("Storing API key from Settings")
         plantsModel.setApiKey(key)
         settings.apiKey = (key.length > 0)
      })
   }
}
