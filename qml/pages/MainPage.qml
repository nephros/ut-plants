import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

import "../util"
import "../compat"

import PlantsModel 1.0

Page {
   id: mainPage
   //property bool loadingScreenShown: false

   SilicaFlickable { id: flickable
   anchors.fill: parent
   PageHeader {
      id: header
      title: i18n.tr('Plants')
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
                pageStack.push(Qt.resolvedUrl("RequestPage.qml"), {
                                  "plantsModel": plantsModel
                               })
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

   /* moved to app window docked panel
   LoadingScreen {
      visible: mainPage.loadingScreenShown
   }
   */

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

   ListView {
      id: plantList
      width: parent.width * 0.9
      anchors.top: header.bottom
      anchors.bottom: footerText.top
      anchors.bottomMargin: units.gu(2)
      anchors.topMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      clip: true
      property double rowSpacing: units.gu(1)
      spacing: rowSpacing

      model: plantsModel

      delegate: Component {
         PlantItem {
            imageUrl: "image://plants/" + plant.id
            mainText: plant.species
            subText: plant.commonNames
            plantObject: plant
            listMode: true

            onClicked: function (plant) {
               pageStack.push(Qt.resolvedUrl("PlantPage.qml"), {
                                 "plant": plant
                              })
            }

            onDelete: function (plantID) {
               var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/QuestionDialog.qml"),
                                {
                                   "title": i18n.tr("Delete plant?"),
                                   "text": i18n.tr("Shall the plant '%1' be deleted? This operation can not be undone.").arg(plant.species),
                                   "acceptText": i18n.tr("Delete"),
                                   "cancelText": i18n.tr("Cancel")
                                }
                            )

               dialog.accepted.connect(function () {
                  var err = plantsModel.deletePlant(plantID)

                  if (err) {
                     pageStack.push(Qt.resolvedUrl("../dialogs/ErrorDialog.qml"),
                              { "title": i18n.tr("Deleting plant failed"),
                                "text": i18n.tr("Plant could not be deleted (%1).").arg(err)
                              }
                     )
                  }
               })
            }
         }
      }
      ViewPlaceholder {
          id: placeholder
          text: i18n.tr("No plants identified yet")
          hintText: i18n.tr("Pull down to start a new identification")
          enabled: !plantsModel.count
          flickable: flickable
      }
   }

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
