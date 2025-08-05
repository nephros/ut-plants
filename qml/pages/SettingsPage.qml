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
   onLanguagesChanged: console.debug("Settings: languages:", languages)
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
      }

      Column {
         id: settingsColumn
         anchors.left: parent.left
         anchors.right: parent.right
         anchors.top: header.bottom

         SectionHeader {
            text: i18n.tr("Pl@ntNet API key")
            font.bold: true
            color: Theme.highlightColor
         }

         Label {
            anchors.left: parent.left
            anchors.right: parent.right
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

         ComboBox {
            enabled: settings.apiKey && (settingsPage.languages.length > 1)
            label: i18n.tr("Result Language")
            description: enabled ? "" : i18n.tr("After setting the API key, and restarting the app, a language can be chosen here.")
            value: settingsPage.language
            menu: ContextMenu {
                Repeater { model: settingsPage.languages
                    delegate: MenuItem { text: modelData }
                }
            }
            onValueChanged: settingsPage.langChanged(value)
         }

         /*
         TextSwitch {
            anchors.left: parent.left
            anchors.right: parent.right

            text: i18n.tr("Keep display on while using the app")
            checked: settings.keepDisplayOn
            onCheckedChanged: settings.keepDisplayOn = checked
         }
         */
         TextSwitch {
            anchors.left: parent.left
            anchors.right: parent.right

            text: i18n.tr("Prevent device sleep on outstanding request")
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
