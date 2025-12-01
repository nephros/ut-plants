import QtQuick 2.6
import Sailfish.Silica 1.0

import "languages-iso-639-1-2-3.js" as Lang
import "country-flags.js" as Flags

GBIFCardBase { id: root

   property var _speciesData: ({})
   property var _speciesMedia: ([])
   //property var _speciesNames: ([])
   //property var _countryData: ([])
   //property var _languageData

   cardTitle: species

   ListModel { id: vernaculars }

   WorkerScript { id: gbif
      Component.onCompleted: if(gbifId != "-1") {
          sendMessage({ "type": "lookupAll", "key": gbifId })
      }
      source: "gbifutils.js"
      onMessage: function(message) {
         //console.debug("WS: Got a message of type:", message.type)
         switch (message.type) {
            case "details":
              _speciesData = new Object(message.data)
            break
            case "media":
              _speciesMedia = new Object(message.data)
            break
            case "names":
              message.data.forEach(function(e) {
                //const lng = _languageData.find(function(l) { return l.iso3 == e.language })
                const lng = Lang.iso3ToLang(e.language)
                const flg = Flags.flag(lng["1"])
                vernaculars.append ({
                  "flag": flg.flag,
                  "languageName": lng.local,
                  //"languageName": lng.titleNative,
                  "names":  e.names
                })
              })
            break
            //case "languages":
            //  _languageData = message.data
            //case "countries":
            //  _countryData = new Object(message.data)
            break
            default:
               console.warn("WS: Unknown message type:", message.type)
         }
      }
   }

   Column {
      id: contents
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      padding: units.gu(2)

      spacing: parent.elementSpacing

      Row { id: nameRow
         width: parent.width - parent.padding*2
         Image { id: logo
            source: "https://www.gbif.org/img/full_logo_white.svg"
            //"https://rs.gbif.org/style/logo.svg"
            height: Theme.iconSizeMedium
            sourceSize.height: Theme.iconSizeMedium
            fillMode: Image.PreserveAspectFit
         }
      }

      Label {
         color: brand.foreground
         text: i18n.tr("Taxonomy")
         font.bold: true
      }

      Label {
         text: i18n.tr("Class") + " " + _speciesData.class
         font.italic: true
         font.bold: true
         color: brand.foreground
      }

      Column { id: taxonomy
         readonly property var taxa: [  "phylum", "order", "family", "genus", ]
         readonly property var taxaNames: [  i18n.tr("Phylum"), i18n.tr("Order"), i18n.tr("Family"), i18n.tr("Genus"), ]
         visible: _speciesData
         width: nameRow.width
         //spacing: units.gu(1)
         Repeater {
            model: _speciesData ? taxonomy.taxa : undefined
            delegate: Row {
              spacing: units.gu(1)
              Item { height: 1; width: units.gu(2)*index }
              Label { font.pixelSize: Theme.fontSizeSmall; text: taxonomy.taxaNames[index]; color: brand.foreground }
              Label { font.pixelSize: Theme.fontSizeSmall; text: _speciesData[modelData] ?_speciesData[modelData] : "";   color: brand.foreground; font.italic: true }
            }
         }
      }
/*
      Grid { id: taxonomy
         readonly property var taxa: [  "phylum", "order", "family", "genus", ]
         readonly property var taxaNames: [  i18n.tr("Phylum"), i18n.tr("Order"), i18n.tr("Family"), i18n.tr("Genus"), ]
         width: nameRow.width
         rows: 2; columns: taxa.length
         columnSpacing: units.gu(1)
         Repeater { model: taxonomy.taxa; delegate: Label { font.pixelSize: Theme.fontSizeSmall; text: taxonomy.taxaNames[index]; color: brand.foreground } }
         Repeater { model: taxonomy.taxa; delegate: Label { font.pixelSize: Theme.fontSizeSmall; text: _resultData[modelData];    color: brand.foreground; font.italic: true } }
      }
*/
      Rectangle {
         width: nameRow.width
         anchors.horizontalCenter: nameRow.horizontalCenter
         height: 1
         color: brand.foreground
      }

      ListView {
         id: resultImagesList
         visible: _speciesMedia.length >0
         anchors.horizontalCenter: parent.horizontalCenter
         width: parent.width - units.gu(2)
         height: width
         model: _speciesMedia

         clip: true
         orientation: ListView.Horizontal
         snapMode: ListView.SnapToItem
         highlightRangeMode: ListView.StrictlyEnforceRange

         delegate: Component {
            Item {
               width: resultImagesList.width
               height: resultImagesList.height

               Image {
                  source: _speciesMedia[index].identifier
                  width: parent.width
                  height: parent.height
                  asynchronous: true

                  fillMode: Image.PreserveAspectCrop
                  BusyIndicator {
                     anchors.centerIn: parent
                     running: parent.status === Image.Loading
                  }
               }

               Label {
                  color: brand.foreground
                  text: _speciesMedia[index].rightsHolder + " " + _speciesMedia[index].license
                  style: Text.Raised
                  styleColor: Theme.darkPrimaryColor
                  font.pixelSize: units.gu(1)
               }
               Label {
                  anchors.bottom: parent.bottom
                  color: brand.foreground
                  text: i18n.tr("Source:") + " " + _speciesMedia[index].source
                  style: Text.Raised
                  styleColor: Theme.darkPrimaryColor
                  font.pixelSize: units.gu(1)
               }
            }
         }
      }

      Label {
         color: brand.foreground
         text: i18n.tr("Vernacular name")
         font.bold: true
      }

      Label {
         color: brand.foreground
         width: parent.width
         text: _speciesData.vernacularName ? _speciesData.vernacularName : ""
         wrapMode: Text.WordWrap
      }
      Repeater {
         width: parent.width
         model: vernaculars
         delegate: Label {
            width: parent.width
            color: brand.foreground
            wrapMode: Text.WordWrap
            textFormat: Text.StyledText
            text: (flag ? flag + " " : "") + "<i>%1</i>: %2".arg(languageName).arg(names)
         }
      }
      /*
      Repeater {
        width: parent.width
        model: Object.keys(_speciesNames)
        delegate: Label {
           width: parent.width
           color: brand.foreground
           wrapMode: Text.WordWrap
           textFormat: Text.StyledText
           property var lang: ({})
           property string flag
           text: (flag ? flag + " " : "") + "<i>%1</i>: %2".arg(lang.local).arg(_speciesNames[modelData].join(", "))
           Component.onCompleted: {
               var ldat = Lang.iso3ToLang(modelData)
               var fdat = Flags.flag(ldat["1"])
               lang = ldat
               flag = (fdat.flag) ? fdat.flag : "  "
           }
        }
      }
      */
  }
}
