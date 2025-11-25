import QtQuick 2.6
import Sailfish.Silica 1.0
import "../compat"

Page {
   id: settingsPage
   anchors.fill: parent
   //signal updateIntervalChanged(var interval, var enabled)
   signal apiKeyChanged(string key)
   // careful to not use C++-defined signal names!
   signal langChanged(string lang)
   signal regChanged(string region)

   property var languages
   property string language: plantsModel.language

   property var regions
   property string region: plantsModel.region

   function checkApiKey(key) {
      var ok = false
      var r = new XMLHttpRequest();
      r.open("HEAD", "https://my-api.plantnet.org/v2/quota?api-key=" + key, true) // sync request
      r.onreadystatechange = function(event) {
         if (r.readyState == XMLHttpRequest.DONE) {
            if (r.status === 401) { ok = false; console.warn("API key check: failed.") }
            else if (r.status === 200) {
              ok = true
              console.debug("API key check: key OK.")
              settingsPage.apiKeyChanged(key)
            }
         }
      }
      r.send();
      return ok
   }
   SilicaFlickable {
      id: flickable
      anchors.fill: parent

      contentWidth: parent.width
      contentHeight: settingsColumn.height

      //flickableDirection: Flickable.AutoFlickIfNeeded

      PageHeader {
         id: header
         title: i18n.tr("Settings")
         description: "%1 v%2".arg(Qt.application.name).arg(Qt.application.version)
      }

      Column {
         id: settingsColumn
         anchors.left: parent.left
         anchors.right: parent.right
         anchors.top: header.bottom

         spacing: Theme.paddingMedium

         SectionHeader {
            text: i18n.tr("Pl@ntNet API key")
            font.bold: true
            color: Theme.highlightColor
         }

         Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin
            textFormat: Text.StyledText
            text:  i18n.tr("In order to use the Pl@ntNet plant identification service, it is necessary to register at their website as developer and obtain an API-Key. This key needs to be configured within this app.\n\nPlease visit <a href=\"https://my.plantnet.org/signup\">https://my.plantnet.org/signup</a> and create a developer account. Afterwards visit <a href=\"https://my.plantnet.org/account\">https://my.plantnet.org/account</a> and click the eye-symbol at the very top (\"my API key\") to show the API-Key. Copy this key and paste it into the below text input field.")
            color: Theme.highlightColor
            linkColor: Theme.primaryColor
            wrapMode: Text.WordWrap
            onLinkActivated: Qt.openUrlExternally(link)
         }

         Column {
            anchors.left: parent.left
            anchors.right: parent.right

            SectionHeader { text: i18n.tr("API-Key:") }

            PasswordField {
               id: apiKeyInput
               text: settings.apiKey ? i18n.tr("New API Key") : ""
               placeholderText: i18n.tr("Enter API-Key")
               label: i18n.tr("The value will be saved on Enter.")
               labelVisible: focus
               description: focus ? "" : (settings.apiKey ? i18n.tr("API Key already stored. Edit to update") : i18n.tr("No API Key stored"))
               passwordEchoMode: TextInput.PasswordEchoOnEdit
               inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
               onFocusChanged: if (focus) { selectAll() }
               EnterKey.enabled: text.length > 0
               EnterKey.iconSource: "image://theme/icon-m-enter-accept"
               EnterKey.onClicked: {
                  //settingsPage.apiKeyChanged(apiKeyInput.text)
                  var ok  = settingsPage.checkApiKey(apiKeyInput.text)
                  if (!ok) console.warn("Check result:", ok)
                  apiKeyInput.focus = false
               }
            }
         }
         SectionHeader { text: i18n.tr("Identification:") }
         ValueButton { id: langButton
            label: i18n.tr("Result Language")
            description: i18n.tr("The language to use for Identification results. Default is to use the current Locale, or English if not available.")
            value: languages[language]
            onClicked: {
               var dlg = pageStack.push(langSelector)
               dlg.accepted.connect(function() {
                  settingsPage.langChanged(dlg.selectedLanguage)
                  settingsPage.language = dlg.selectedLanguage
               })
            }
         }
         Component { id: langSelector
            Dialog { id: langDialog
              property string selectedLanguage
              DialogHeader{ id: head }
              SilicaListView {
                width: parent.width
                anchors.top: head.bottom
                anchors.bottom: parent.bottom
                model: Object.keys(settingsPage.languages)
                delegate: ListItem {
                  anchors.margins: units.gu(2)
                  Label { text: modelData + ": " + settingsPage.languages[modelData]; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: units.gu(2)}
                  onClicked: { langDialog.selectedLanguage = modelData; langDialog.accept() }
                }
              }
            }
         }

         ValueButton { id: regionButton
            label: i18n.tr("Region or Project")
            description: i18n.tr("The Region or Project to use for Identification results. Default is to use all available.")
            value: {
              var name = "All available"
              for (var i=0; i<settingsPage.regions.length; ++i) {
                  if (settingsPage.regions[i]["id"] == settingsPage.region) {
                     name = settingsPage.regions[i]["title"]
                     break
                  }
              }
              return name
            }
            onClicked: {
               var dlg = pageStack.push(regionSelector)
               dlg.accepted.connect(function() {
                  settingsPage.regChanged(dlg.selectedRegion)
               })
            }
         }
         Component { id: regionSelector
            Dialog { id: regionDialog
              property string selectedRegion
              DialogHeader{ id: head }
              SilicaListView {
                width: parent.width
                anchors.top: head.bottom
                anchors.bottom: parent.bottom
                model: settingsPage.regions
                delegate: ListItem {
                  anchors.margins: units.gu(2)
                  highlighted: down || (modelData.id == settingsPage.region)
                  contentHeight: regCol.height
                  Column { id: regCol
                     width: parent.width
                     Label { id: regionTitle
                       text: modelData.title
                       anchors.left: parent.left; anchors.right: parent.right; anchors.margins: units.gu(2)
                       wrapMode: Text.WordWrap
                     }
                     Label { id: regionDesc
                       text: modelData.description
                       font.pixelSize: Theme.fontSizeSmall
                       color: Theme.secondaryHighlightColor
                       anchors.left: parent.left; anchors.right: parent.right; anchors.margins: units.gu(2)
                       wrapMode: Text.WordWrap
                     }
                     Label { text: Number(modelData.speciesCount) + " " + i18n.tr("species")
                       font.pixelSize: Theme.fontSizeSmall
                       color: Theme.secondaryColor
                       anchors.left: parent.left; anchors.right: parent.right; anchors.margins: units.gu(2)
                     }
                  }
                  onClicked: { regionDialog.selectedRegion = modelData.id; regionDialog.accept() }
                }
              }
            }
         }
         Slider {
             enabled: false
             anchors.left: parent.left
             anchors.right: parent.right
             value: settings.numResults
             valueText: sliderValue
             minimumValue: 1
             maximumValue: 10
             stepSize: 1
             label: i18n.tr("Number of results")
             onValueChanged: settings.numResults = sliderValue
         }

         SectionHeader { text: i18n.tr("App:") }
         TextSwitch {
            anchors.left: parent.left
            anchors.right: parent.right
            text: i18n.tr("Prevent device sleep on pending request")
            description: i18n.tr("If enabled, device will not go into sleep mode while waiting on an identification result.")
            checked: settings.preventSleep
            onCheckedChanged: settings.preventSleep = checked
         }

      }
   }

   /*
   Rectangle {
      id: keyboardRect
      width: parent.width
      height: parent.height * 0.3
      anchors.bottom: parent.bottom
      color: brand.foreground
      visible: false
   }
   */
}
