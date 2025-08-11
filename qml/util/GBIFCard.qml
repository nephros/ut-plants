import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import QtPositioning 5.4

import "../util"

Rectangle { id: gbifCard
   radius: 10
   color: brand.background
   height: contents.height
   anchors.margins: units.gu(2)
   anchors.horizontalCenter: parent.horizontalCenter

   property string species: nil
   property var _resultData: ({})
   property var _speciesData: ({})
   property var _speciesMedia: ([])
   property var _speciesNames: ([])

   readonly property string agent: "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"

   onSpeciesChanged: if(species) lookupSpecies(species)

   property double elementSpacing: units.gu(2)

   QtObject { id: brand
      //readonly property color background: Theme.colorScheme === Theme.LightOnDark ? "#8eb533" : "#f6f8ed"
      //readonly property color foreground: Theme.colorScheme === Theme.LightOnDark ? "#f6f8ed" : "#394611"
      readonly property color background: "#41af46"
      readonly property color foreground: "#fff"
      //readonly property color warn:       Theme.colorScheme === Theme.LightOnDark ? "#ffe629" : Theme.highlightFromColor("#ffe629", Theme.colorScheme)
      //readonly property color danger:     Theme.colorScheme === Theme.LightOnDark ? "#d13415" : Theme.highlightFromColor("#d13415", Theme.colorScheme)
      readonly property color warn:       "#e18114"
      readonly property color danger:     "#d32f2f"

   }


   Column {
      id: contents
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      padding: units.gu(2)

      spacing: parent.elementSpacing

      Row { id: nameRow
         width: parent.width - parent.padding*2
         anchors.horizontalCenter: parent.horizontalCenter
         spacing: units.gu(1)
         Image { id: logo
            source: "https://www.gbif.org/img/full_logo_white.svg"
            //"https://rs.gbif.org/style/logo.svg"
            height: Theme.iconSizeMedium
            width: parent.width - (scoreRow.width + parent.spacing)
            sourceSize.height: Theme.iconSizeSmall
            fillMode: Image.PreserveAspectFit
         }
         Row { id: scoreRow
            height: logo.height
            spacing: units.gu(1)
            Icon {
               anchors.verticalCenter: scoreLabel.verticalCenter
               source: "image://theme/icon-m-diagnostic"
               width: height
               height: scoreLabel.height
            }
            Label { id: scoreLabel
               property int scoreValue: _resultData.confidence

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

      Label {
         color: brand.foreground
         text: i18n.tr("Taxonomy")
         font.bold: true
      }

      Label {
         text: i18n.tr("Class") + " " + _resultData.class
         font.italic: true
         font.bold: true
         color: brand.foreground
      }

      Column { id: taxonomy
         readonly property var taxa: [  "phylum", "order", "family", "genus", ]
         readonly property var taxaNames: [  i18n.tr("Phylum"), i18n.tr("Order"), i18n.tr("Family"), i18n.tr("Genus"), ]
         width: nameRow.width
         spacing: units.gu(1)
         Repeater {
            model: taxonomy.taxa;
            delegate: Row {
              spacing: units.gu(1)
              Item { height: 1; width: units.gu(2)*index }
              Label { font.pixelSize: Theme.fontSizeSmall; text: taxonomy.taxaNames[index]; color: brand.foreground }
              Label { font.pixelSize: Theme.fontSizeSmall; text: _resultData[modelData];    color: brand.foreground; font.italic: true }
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

      WebView { id: occmapView
         width: resultImagesList.width
         height: width *3/4
         anchors.horizontalCenter: parent.horizontalCenter
         active: _resultData.speciesKey
         httpUserAgent: gbifCard.agent
         url: "https://api.gbif.org/v1/map/?"
             + "type=TAXON"
             + "&key=" + _resultData.speciesKey
             + "&layer=SP_2020_2030"
             + (Theme.colorScheme === Theme.LightOnDark ? "&style=light" : + "&style=classic")
             //+ "&resolution=4"
      }

      WebView { id: posmapView
         width: resultImagesList.width
         height: width *3/4
         anchors.horizontalCenter: parent.horizontalCenter
         active: _resultData.speciesKey && pos.valid
         httpUserAgent: gbifCard.agent
         property string templateUrl: "https://api.gbif.org/v1/map/point.html?"
             + "type=TAXON"
             + "&key=" + _resultData.speciesKey
             + "&zoom=8"
             + (Theme.colorScheme === Theme.LightOnDark ? "&style=light" : "&style=classic")
             PositionSource { id: pos
                 updateInterval: 5000
                 active: parent.visible
                 onPositionChanged: {
                   if (!valid) return
                   const coord = pos.position.coordinate
                   const lat = coord.latitude.toFixed(5)
                   const lon = coord.longitude.toFixed(5)
                   console.debug("New position:", coord.latitude, coord.longitude)
                   posmapView.load( posmapView.templateUrl
                                  + "&point=" + lat + ","  + lon
                                  + "&lat=" + lat + "&lng=" + lon // !! lng not lon !!
                                  )
                 }
             }
      }

      /*
      QC.PageIndicator {
         anchors.horizontalCenter: parent.horizontalCenter
         currentIndex: resultImagesList.currentIndex
         count: resultImagesList.count
      }
      */

      Label {
         color: brand.foreground
         text: i18n.tr("Vernacular name")
         font.bold: true
      }

      Label {
         color: brand.foreground
         width: parent.width
         text: _speciesData.vernacularName
         wrapMode: Text.WordWrap
      }
      Repeater {
        model: Object.keys(_speciesNames)
        delegate: Label {
           color: brand.foreground
           width: parent.width
           wrapMode: Text.WordWrap
           text:  modelData + ": " + _speciesNames[modelData].join(", ")
        }
      }
   }
  function lookupSpecies(species) {
     const url="https://api.gbif.org/v1/species/match?"
        + "name=" + encodeURI(species)
        + "&rank=species&limit=1&verbose=false"
     function cb(rdata) {
        gbifCard._resultData = rdata
        gbifCard.lookupDetails(rdata.speciesKey)
        gbifCard.lookupNames(rdata.speciesKey)
        gbifCard.lookupMedia(rdata.speciesKey)
     }
     lookup(url,cb)
  }
  function lookupDetails(speciesKey) {
     const url="https://api.gbif.org/v1/species/" + speciesKey
     function cb(rdata) { gbifCard._speciesData = rdata }
     lookup(url,cb)
  }
  function lookupNames(speciesKey) {
     const url="https://api.gbif.org/v1/species/" + speciesKey + "/vernacularNames?limit=10"
     function cb(rdata) {
         var names = {}
         rdata.results.forEach(function(e) {
             var n = names[e.language] 
             if (!n) n = []
             n.push(e.vernacularName)
             names[e.language] = n

         })
         gbifCard._speciesNames = names
     }
     lookup(url,cb)
  }
  function lookupMedia(speciesKey) {
     const url="https://api.gbif.org/v1/species/" + speciesKey + "/media/"
     function cb(rdata) {
        gbifCard._speciesMedia = rdata.results.filter(function(e) { return e.type == "StillImage" } )
     }
     lookup(url,cb)
  }
  function lookup(url, callback) {
     var query = Qt.resolvedUrl(url);
     var r = new XMLHttpRequest();
     r.open("GET", query);
     r.setRequestHeader('User-Agent', gbifCard.agent);
     r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
     r.setRequestHeader('Accept', 'application/json');
     r.setRequestHeader('Origin', '');

     r.send();
     r.onreadystatechange = function(event) {
         if (r.readyState == XMLHttpRequest.DONE) {
             if (r.status === 200 || r.status == 0) {
                 var rdata = JSON.parse(r.response);
                 callback(rdata)
             } else {
                 console.debug("error in processing request.", query, r.status, r.statusText);
             }
         }
     }
  }
}
