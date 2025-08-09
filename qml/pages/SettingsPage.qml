import QtQuick 2.6
import Sailfish.Silica 1.0
import "../compat"

Page {
   id: settingsPage
   anchors.fill: parent
   //signal updateIntervalChanged(var interval, var enabled)
   signal apiKeyChanged(string key)
   signal langChanged(string lang)

   property var languages
   property string language

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
               passwordEchoMode: focus ? TextInput.Normal : TextInput.Password
               inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
               EnterKey.onClicked: {
                  settingsPage.apiKeyChanged(apiKeyInput.text)
                  apiKeyInput.focus = false
               }
            }
         }
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

         TextSwitch {
            anchors.left: parent.left
            anchors.right: parent.right
            text: i18n.tr("Prevent device sleep on pending request")
            checked: settings.preventSleep
            onCheckedChanged: settings.preventSleep = checked
         }

         Slider {
             anchors.left: parent.left
             anchors.right: parent.right
             value: settings.numResults
             minimumValue: 1
             maximumValue: 10
             stepSize: 1
             label: i18n.tr("Maximum number of species in identification results − a higher number increases response time")
             onValueChanged: settings.numResults = sliderValue
         }
 
         TextSwitch {
            enabled: false
            anchors.left: parent.left
            anchors.right: parent.right
            text: i18n.tr("Narrow search by current Location")
            description: i18n.tr("Use the devices Location capabilities to return results for local plants only.")
            checked: settings.useLocation
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
