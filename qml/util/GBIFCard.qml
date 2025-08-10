import QtQuick 2.6
import Sailfish.Silica 1.0

import "../util"

Rectangle { id: gbifCard
   radius: 10
   QtObject { id: brand
      //readonly property color background: Theme.colorScheme === Theme.LightOnDark ? "#8eb533" : "#f6f8ed"
      //readonly property color foreground: Theme.colorScheme === Theme.LightOnDark ? "#f6f8ed" : "#394611"
      readonly property color background: "#41af46"
      readonly property color foreground: "#fff"
      readonly property color warn:       Theme.colorScheme === Theme.LightOnDark ? "#ffe629" : Theme.highlightFromColor("#ffe629", Theme.colorScheme)
      readonly property color danger:     Theme.colorScheme === Theme.LightOnDark ? "#d13415" : Theme.highlightFromColor("#d13415", Theme.colorScheme)

   }

   color: brand.background
   height: contents.height
   anchors.margins: units.gu(2)
   anchors.horizontalCenter: parent.horizontalCenter

   property string species
   property var _resultData
   property double elementSpacing: units.gu(2)

   onSpeciesChanged: if(species) lookup(species)

   Column {
      id: contents
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      padding: units.gu(2)

      spacing: parent.elementSpacing

      Row { id: logoRow
         width: parent.width - parent.padding*2
         height: logo.height
         Image { id: logo
            source: "https://rs.gbif.org/style/logo.svg"
            height: Theme.iconSizeSmall
			width: parent.width
            sourceSize.height: Theme.iconSizeSmall
            fillMode: Image.PreserveAspectFit
         }
      }
      Row { id: nameRow
         width: parent.width - parent.padding*2
         anchors.horizontalCenter: parent.horizontalCenter
         spacing: units.gu(1)
         Label { id: nameLabel
            width: parent.width - (scoreRow.width + parent.spacing)
            text: i18n.tr("Name")
            font.bold: true
            color: brand.foreground
         }
         Row { id: scoreRow
            height: nameLabel.height
            spacing: units.gu(1)
            Icon {
               anchors.verticalCenter: scoreLabel.verticalCenter
               source: "image://theme/icon-m-diagnostic"
               width: height
               height: scoreLabel.height
            }
            Label { id: scoreLabel
               property int scoreValue: Math.round(_resultData.confidence)

               anchors.top: parent.top
               text: scoreValue + "%"
               font.pixelSize: units.gu(2)
               font.bold: true

               color: scoreValue > 80
                        ? brand.foreground
                        : (scoreValue > 50 ? brand.warn : brand.danger)
            }
         }
      }
      Grid { id: taxonomy
         readonly property var taxa: [ "kingdom", "phylum", "order", "family", "genus", ]
         readonly property var taxaNames: [ i18n.tr("Kingdom"), i18n.tr("Phylum"), i18n.tr("Order"), i18n.tr("Family"), i18n.tr("Genus"), ]
         rows: 2
         columns: taxa.length
         Repeater { model: taxonomy.taxa; delegate: Label { text: taxonomy.taxaNames[index]; color: brand.foreground } }
         Repeater { model: taxonomy.taxa; delegate: Label { text: _resultData[modelData]; color: brand.foreground } }
      }

      Rectangle {
         width: nameRow.width
         anchors.horizontalCenter: nameRow.horizontalCenter
         height: 1
         color: brand.foreground
      }

      Label {
         visible: _resultData.family
         text: _resultData.family
         font.italic: true
         color: brand.foreground
      }

	  /*
      ListView {
         id: resultImagesList
         anchors.horizontalCenter: parent.horizontalCenter
         width: parent.width - units.gu(2)
         height: width
         model: resultImageModel

         clip: true
         orientation: ListView.Horizontal
         snapMode: ListView.SnapToItem
         highlightRangeMode: ListView.StrictlyEnforceRange

         delegate: Component {
            Item {
               width: resultImagesList.width
               height: resultImagesList.height

               Image {
                  source: prepareImageUrl(url)
                  width: parent.width
                  height: parent.height
                  asynchronous: true

                  fillMode: Image.PreserveAspectCrop
               }

               Label {
                  color: brand.foreground
                  text: copyright
                  style: Text.Raised
                  styleColor: Theme.darkPrimaryColor
                  font.pixelSize: units.gu(1)
               }
            }
         }
      }
	  */

      /*
      QC.PageIndicator {
         anchors.horizontalCenter: parent.horizontalCenter
         currentIndex: resultImagesList.currentIndex
         count: resultImagesList.count
      }
      */

	  /*
      Label {
         color: brand.foreground
         text: i18n.tr("Common names")
         font.bold: true
      }

      Label {
         color: brand.foreground
         width: parent.width
         text: _resultData.commonNames
         wrapMode: Text.WordWrap
      }
	  */
   }

  function lookup(species) {
     const url="https://api.gbif.org/v1/species/match?"
        + "name=" + encodeURI(species)
        + "&rank=species&limit=2&verbose=true"
     var query = Qt.resolvedUrl(url);
     var r = new XMLHttpRequest();
     r.open("GET", query);
     r.setRequestHeader('User-Agent', "harbour-plants/1.0 (Sailfish OS; Qt)");
     r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
     //r.setRequestHeader('X-Auth-Token', token);
     //r.setRequestHeader('X-App-Client', Qt.application.name);
     //r.setRequestHeader('X-App-Version', Qt.application.version);
     r.setRequestHeader('Accept', 'application/json');
     r.setRequestHeader('Origin', '');

     r.send();
     r.onreadystatechange = function(event) {
         if (r.readyState == XMLHttpRequest.DONE) {
             if (r.status === 200 || r.status == 0) {
                 var rdata = JSON.parse(r.response);
                 gbifCard._resultData = rdata
             } else {
                 console.debug("error in processing request.", query, r.status, r.statusText);
             }
         }
     }
  }
}
