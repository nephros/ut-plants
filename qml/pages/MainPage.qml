import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

import "../util"
import "../compat"

import PlantsModel 1.0

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

   PlantsModel {
      id: plantsModel

      onLanguageChanged: console.debug("language now:", plantsModel.language)
      onAvailableLanguagesChanged: console.debug("languages now:", plantsModel.availableLanguages)
      onIdentificationResult: {
         app.loadingScreenShown = false

         if (error) {
            pageStack.push(Qt.resolvedUrl("../dialogs/ErrorDialog.qml"),
                        {
                          "title": i18n.tr("Identification failed"),
                          "text":  i18n.tr("Failed to send identification request to Pl@ntNet (%1).").arg(error)
                        }
            )
            return
         }

         pageStack.push(Qt.resolvedUrl("ResultsPage.qml"), {
                           "resultsData": result,
                           "plantsModel": plantsModel
                        })
      }
   }

   SilicaListView { id: plantList
      anchors.fill: parent
      header: PageHeader {
         title: i18n.tr('Plants')
         description: (plantList.count > 0 )
                       ? (plantList.count == 1)
                          ? i18n.tr("1 identified plant")
                          : i18n.tr( "%1 identified plants").arg(plantList.count)
                       : ""
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
            }
            onClicked: pageStack.push(Qt.resolvedUrl("PlantPage.qml"), { "plant": plant })
            menu: ContextMenu {
               MenuItem { text: i18n.tr("Remove")
                  onClicked: remorseDelete(function() { deletePlant(plantID) })
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

      PullDownMenu {
          MenuItem {
             text: i18n.tr("New identification")
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

   /* moved to app window docked panel
   LoadingScreen {
      visible: mainPage.loadingScreenShown
   }
   */

   /* SFOS: replaced by ViewPlaceholder, below:
   Rectangle {
      id: placeholder
      radius: units.gu(4)
      border.width: 2
      border.color: "#cdcdcd"
      visible: !plantsModel.count

      anchors.centerIn: parent
      width: parent.width * 0.7
      height: units.gu(8)

      Column {
         anchors.centerIn: parent
         spacing: units.gu(2)

         Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("No plants identified yet")
         }
      }
   }
   */

   /* SFOS: replaced with Pulley Menu entry, above:
   Button {
      id: analyzeButton
      anchors.top: header.bottom
      anchors.topMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      text: i18n.tr("New identification")
      onClicked: {
         if (!settings.apiKey) {
            var dialog = Dialogs.showErrorDialog(
                     root, i18n.tr("API Key missing"), i18n.tr(
                        "The Pl@ntNet API-Key has not been configured yet. Without this, the app will not work."))

            dialog.accepted.connect(function () {
               mainPage.openSettings()
            })
         } else {
            pageStack.push(Qt.resolvedUrl("RequestPage.qml"), {
                              "plantsModel": plantsModel
                           })
         }
      }
   }
   */


   /* Moved into Page header
   Text {
      id: footerText
      visible: plantList.count > 0
      anchors.bottom: parent.bottom
      anchors.bottomMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      text: plantList.count == 1 ? i18n.tr("1 identified plant") : i18n.tr(
                                      "%1 identified plants").arg(
                                      plantList.count)
   }
   */

   function openIdentify() {
      pageStack.push(Qt.resolvedUrl("RequestPage.qml"), {
                        "plantsModel": plantsModel
                     })
   }
   function openSettings() {
      var p = pageStack.push(Qt.resolvedUrl("./SettingsPage.qml"),
          { languages: plantsModel.availableLanguages, language: plantsModel.language }
      )

      p.langChanged.connect(function (lang) {
        plantsModel.setLanguage(lang)
      })
      p.apiKeyChanged.connect(function (key) {
         console.info("Storing API key from Settings")
         plantsModel.setApiKey(key)
         settings.apiKey = true
      })
   }
}
