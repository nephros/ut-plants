import QtQuick 2.6
import Sailfish.Silica 1.0
import "../compat"

Page {
   id: settingsPage
   anchors.fill: parent
   //signal updateIntervalChanged(var interval, var enabled)
   signal apiKeyChanged(string key)

   SilicaFlickable {
      id: flickable
      anchors.fill: parent

      contentWidth: parent.width
      contentHeight: settingsColumn.height

      //flickableDirection: Flickable.AutoFlickIfNeeded

      PageHeader {
         id: header
         title: i18n.tr("Settings")
      }

      Column {
         id: settingsColumn
         anchors.left: parent.left
         anchors.right: parent.right
         anchors.top: header.bottom

         SectionHeader {
            text: i18n.tr("Pl@ntNet API key")
            font.bold: true
            color: Theme.primaryColor
         }

         Label {
            anchors.left: parent.left
            anchors.right: parent.right
            textFormat: Text.StyledText
            text:  i18n.tr("In order to use the Pl@ntNet plant identification service, it is necessary to register at their website as developer and obtain an API-Key. This key needs to be configured within this app.\n\nPlease visit <a href=\"https://my.plantnet.org/signup\">https://my.plantnet.org/signup</a> and create a developer account. Afterwards visit <a href=\"https://my.plantnet.org/account\">https://my.plantnet.org/account</a> and click the eye-symbol at the very top (\"my API key\") to show the API-Key. Copy this key and paste it into the below text input field.")
            color: Theme.primaryColor
            linkColor: Theme.highlightColor
            wrapMode: Text.WordWrap
            onLinkActivated: Qt.openUrlExternally(link)
         }

         Column {
            anchors.left: parent.left
            anchors.right: parent.right

            SectionHeader { text: i18n.tr("API-Key:") }

            PasswordField {
               id: apiKeyInput
               placeholderText: i18n.tr("Enter API-Key")
               width: parent.width - units.gu(2)
               inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
               passwordEchoMode: TextInput.Normal
               //placeholderText: settings.apiKey ? i18n.tr("API Key set, fill in to update") : i18n.tr("API Key not set")
               label: settings.apiKey ? i18n.tr("API Key set, fill in to update") : i18n.tr("API Key not set")
               description: i18n.tr("The value will be saved on Enter, but not shown again here.")
               EnterKey.onClicked: {
                  settingsPage.apiKeyChanged(apiKeyInput.text)
                  apiKeyInput.focus = false
               }
            }
         }
         TextSwitch {
            anchors.left: parent.left
            anchors.right: parent.right

            text: i18n.tr("Respect locale")
            description: i18n.tr("If disabled, results will be shown in English. Otherwise, the user language will be used if available.")
            checked: settings.useLocale
            onCheckedChanged: settings.useLocale = checked
         }

         TextSwitch {
            anchors.left: parent.left
            anchors.right: parent.right

            text: i18n.tr("Keep display on while using the app")
            checked: settings.keepDisplayOn
            onCheckedChanged: settings.keepDisplayOn = checked
         }
      }
   }

   /*
   Rectangle {
      id: keyboardRect
      width: parent.width
      height: parent.height * 0.3
      anchors.bottom: parent.bottom
      color: "white"
      visible: false
   }
   */
}
