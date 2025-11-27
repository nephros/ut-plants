import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import QtPositioning 5.4

import "../util"
import "../util/languages-iso-639-1-2-3.js" as Lang
import "../util/country-flags.js" as Flags

Rectangle { id: gbifCard
   radius: 10
   color: brand.background
   height: contents.height
   anchors.margins: units.gu(2)
   anchors.horizontalCenter: parent.horizontalCenter

   property int xhrs: 0
   property bool loading: xhrs>0
   opacity: loading ? 0.5 : 1.0
   Behavior on opacity { FadeAnimator{} }

   property string species
   property string gbifId: "-1"
   property var _speciesData: ({})
   property var _speciesMedia: ([])
   property var _speciesNames: ([])

   property var _countryData: ([])

   property bool allowLocation: settings.allowLocation

   readonly property string agent: "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"

   onSpeciesChanged: if(species) lookupSpeciesByName(species)
   onGbifIdChanged:  if(gbifId != "-1") {
      gbifCard.lookupDetails(gbifId)
      gbifCard.lookupNames(gbifId)
      gbifCard.lookupMedia(gbifId)
   }

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
         spacing: units.gu(1)
         Repeater {
            model: _speciesData ? taxonomy.taxa : undefined
            delegate: Row {
              spacing: units.gu(1)
              Item { height: 1; width: units.gu(2)*index }
              Label { font.pixelSize: Theme.fontSizeSmall; text: taxonomy.taxaNames[index]; color: brand.foreground }
              Label { font.pixelSize: Theme.fontSizeSmall; text: _speciesData[modelData];    color: brand.foreground; font.italic: true }
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
         ViewPlaceholder {
            text: i18n.tr("No images found")
            enabled: !_speciesMedia.count
         }
      }

      WebView { id: occmapView
         width: resultImagesList.width
         height: width *3/4
         anchors.horizontalCenter: parent.horizontalCenter
         active: gbifId != "-1"
         httpUserAgent: gbifCard.agent
         url: "https://api.gbif.org/v1/map/?"
             + "type=TAXON"
             + "&key=" + gbifId
             + "&layer=SP_2020_2030"
             + (Theme.colorScheme === Theme.LightOnDark ? "&style=light" : + "&style=classic")
             //+ "&resolution=4"
      }

      WebView { id: posmapView
         width: resultImagesList.width
         height: width *3/4
         anchors.horizontalCenter: parent.horizontalCenter
         active: (gbifId!="-1") && pos.valid
         httpUserAgent: gbifCard.agent
         property bool positionSet: false
         property string templateUrl: "https://api.gbif.org/v1/map/point.html?"
             + "type=TAXON"
             + "&key=" + gbifId
             + "&zoom=8"
             + (Theme.colorScheme === Theme.LightOnDark ? "&style=light" : "&style=classic")
         Component.onCompleted: if (!allowLocation) url = templateUrl
         PositionSource { id: pos
             updateInterval: posmapView.positionSet ? 1000*60*5 : 5000 // 5s or 5min
             active: allowLocation && parent.visible
             onPositionChanged: {
               if (!valid) return
               const coord = pos.position.coordinate
               console.debug("New position:", coord.latitude, coord.longitude)
               if ( (coord.latitude != coord.latitude) || (coord.longitude != coord.longitude) ) return // only sane way to test for NaN:
               const lat = coord.latitude.toFixed(5)
               const lon = coord.longitude.toFixed(5)
               //posmapView.load( posmapView.templateUrl
               posmapView.url = posmapView.templateUrl
                              + "&point=" + lat + ","  + lon
                              + "&lat=" + lat + "&lng=" + lon // !! lng not lon !!
               //               )
               console.debug("Loaded", posmapView.url)
               posmapView.positionSet = true
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
           property var lang: Lang.iso3ToLang(modelData)
           property var flag: Flags.flag(lang["1"]).flag
           text: flag + " " + lang.local + ": " + _speciesNames[modelData].join(", ")
        }
      }
  }
  BusyIndicator {
    anchors.centerIn: parent
    running: gbifCard.loading
    size: BusyIndicatorSize.Large
  }

  function lookupSpeciesByName(species) {
     const url="https://api.gbif.org/v1/species/match?"
        + "name=" + encodeURI(species)
        + "&rank=species&limit=1&verbose=false"
     function cb(rdata) {
        gbifCard.gbifId = rdata.speciesKey
     }
     lookup(url,cb)
  }

  function lookupCountries() {
     const url="https://api.gbif.org/v1/enumeration/country"
     function cb(rdata) { gbifCard._countryData = rdata }
     lookup(url,cb)
  }
  function lookupDetails(key) {
     const url="https://api.gbif.org/v1/species/" + key
     function cb(rdata) { gbifCard._speciesData = rdata }
     lookup(url,cb)
  }
  function lookupNames(key) {
     const url="https://api.gbif.org/v1/species/" + key + "/vernacularNames?limit=10"
     function cb(rdata) {
         var names = {}
         rdata.results.forEach(function(e) {
             var n = names[e.language] 
             if (!n) n = []
             if (n.indexOf(e.vernacularName) == -1) {
                 n.push(e.vernacularName)
                 names[e.language] = n
             }
         })
         gbifCard._speciesNames = names
     }
     lookup(url,cb)
  }
  function lookupMedia(key) {
     const url="https://api.gbif.org/v1/species/" + key + "/media/"
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
     gbifCard.xhrs += 1
     r.onreadystatechange = function(event) {
         if (r.readyState == XMLHttpRequest.DONE) {
             if (r.status === 200 || r.status == 0) {
                 var rdata = JSON.parse(r.response);
                 callback(rdata)
             } else {
                 console.debug("error in processing request.", query, r.status, r.statusText);
             }
             gbifCard.xhrs -= 1
         }
     }
  }
}
