import QtQuick 2.6
import Sailfish.Silica 1.0
import "../compat"

Page {
   id: settingsPage
   anchors.fill: parent
   //signal updateIntervalChanged(var interval, var enabled)
   signal apiKeyChanged(string key)
   signal langChanged(string lang)

   property ListModel languages
   property string language
   property string languageName
   onLanguageChanged: {
       if(!!languages) {
          for (var i=0; i<settingsPage.languages.count; ++i) {
             const l = settingsPage.languages.get(i)
             if (l==settingsPage.language) {
                languageName = l.name
                break
             }
          }
       }
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
         ValueButton {
            enabled: (!!languages && (languages.count > 1))
            label: i18n.tr("Result Language")
            description: i18n.tr("The language to use for Identification results. Default is to use the current Locale, or English if not available.")
            value: settingsPage.languageName
            onClicked: {
               var dlg = pageStack.push(langSelector)
               dlg.accepted.connect(function() {
                  settingsPage.langChanged(dlg.selectedLanguage)
               })
            }
         }
         Component { id: langSelector
            Dialog { id: langDialog
              property ListModel languages: settingsPage.languages
              property string selectedLanguage
              DialogHeader{ id: head }
              SilicaListView {
                width: parent.width
                anchors.top: head.bottom
                anchors.bottom: parent.bottom
                model: languages
                delegate: ListItem {
                  anchors.margins: units.gu(2)
                  Label { text: model.language + ": " + name }
                  onClicked: { langDialog.selectedLanguage = language; langDialog.accept() }
                }
              }
            }
         }
         /*
         ComboBox {
            enabled: settings.apiKey && (settingsPage.languages.count > 1)
            label: i18n.tr("Result Language")
            description: enabled ? i18n.tr("Determined from Locale, or default (English)") : i18n.tr("After setting the API key, and restarting the app, a language can be chosen here.")
            currentIndex: settingsPage.languageIdx
            menu: ContextMenu {
                Repeater { model: settingsPage.languages
                    delegate: MenuItem { text: model.language + ": " + name }
                }
            }
            onValueChanged: settingsPage.langChanged(settingsPage.languages.get(currentIndex).language)
         }
         */

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
