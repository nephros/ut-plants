import QtQuick 2.6
import Sailfish.Silica 1.0
//import Sailfish.WebView 1.0
import QtPositioning 5.4
import QtGraphicalEffects 1.0

import "latLngToTileXY.js" as LatLonToTile

GBIFCardBase { id: root

   property bool allowLocation: settings.allowLocation
   readonly property string agent: "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"

   cardTitle: i18n.tr("Occurrence Map")

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

      Rectangle {
         width: nameRow.width
         anchors.horizontalCenter: nameRow.horizontalCenter
         height: 1
         color: brand.foreground
      }

      /*
       * Web Mercator tiles use the standard Google/OpenStreetMap tile schema;
       * at zoom zero a single tile covers the Earth between -180° to +180°,
       * and -85.06° to 85.06°. The default tile size for PNG tiles is
       * 512×512px.
       * https://tile.gbif.org/ui/
       */
      Rectangle { id: mapContainer
          width: nameRow.width
          height: width 
          property int tile_z: 1
          property int tile_x: 1
          property int tile_y: 0
          property string position: "%1/%2/%3".arg(Math.max(0,tile_z)).arg(Math.max(0,tile_x)).arg(Math.max(0,tile_y))
          property string srs: "3857" // Web Mercator
          //property string srs: "4326"   // Plate Caree/WGS84
          function reset() {
             tile_z = 0; tile_x = 0; tile_y = 0
          }
          Image { id: occMapImage
             visible: false
             //anchors.fill: parent
             sourceSize.width: 512; sourceSize.height: width
             source: "https://tile.gbif.org/" + parent.srs + "/omt/" + parent.position + "@1x.png"
                   //+ "?style=gbif-" + (Theme.colorScheme === Theme.LightOnDark ? "light" : + "classic")
                   + "?style=gbif-" + (Theme.colorScheme === Theme.LightOnDark ? "geyser" : + "tuatara")
          }

          Image { id: occImage
             visible: false
             //anchors.fill: occMapImage
             //anchors.centerIn: occMapImage
             sourceSize.width: 512; sourceSize.height: width
             source: "https://api.gbif.org/v2/map/occurrence/density/" + parent.position + "@1x.png"
                 + "?taxonKey=" + gbifId
                 + "&srs=EPSG:" + parent.srs
                 //+ "&style=green-noborder.poly"
                 // size of the squares in pixels on a 4096px tile. Choose a factor of 4096 so they tessalete correctly.
                 // available: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096
                 //+ "&bin=square&squareSize=64"
                 //+ "&style=green.poly"
                 + "&style=" + (Theme.colorScheme === Theme.LightOnDark ? "green.poly" : + "classic.poly")
                 + "&bin=hex&hexPerTile=85" // number of hexagons across a tile -> larger gives smaller hexes, default 51
          }
          Blend { id: blendedImage1
             anchors.fill: parent
             source: occMapImage
             foregroundSource: occImage
             mode: "normal"
          }
          Label {
             anchors.bottom: parent.bottom
             text: parent.position
             style: Text.Raised
             //color: brand.foreground
             color: Theme.darkPrimaryColor
             //styleColor: Theme.darkPrimaryColor
             styleColor: (Theme.colorScheme === Theme.LightOnDark) ? Theme.lightPrimaryColor : Theme.darkPrimaryColor
             font.pixelSize: units.gu(1)
          }
          IconButton {
             anchors.right: parent.right
             anchors.top: parent.top
             anchors.margins: units.gu(1)
             icon.source: "image://theme/icon-splus-clear?" + ((Theme.colorScheme === Theme.LightOnDark) ? "#000" : brand.foreground)
             onClicked: parent.reset()
          }
      }
      Item {
         width: mapContainer.width
         height: Theme.iconSizeMedium
         anchors.left: mapContainer.left
         IconButton { id: rembutt; anchors.left: parent.left;   anchors.margins: units.gu(1); icon.source: "image://theme/icon-m-remove"  ; onClicked: mapContainer.tile_z -= 1; enabled: mapContainer.tile_z>0 }
         IconButton { id: addbutt; anchors.left: rembutt.right; anchors.margins: units.gu(1); icon.source: "image://theme/icon-m-add"     ; onClicked: mapContainer.tile_z += 1 }

         IconButton { id: gpsbutt; anchors.horizontalCenter: parent.horizontalCenter; anchors.margins: units.gu(1);
            icon.source: "image://theme/icon-m-location?"
                       + ((pos.position.horizontalAccuracy < 5000)
                       ? Theme.presenceColor(Theme.PresenceAvailable) : brand.warn)
            onClicked: {
              //function lat2tile(lat,zoom) { Math.floor((1-Math.log(Math.tan(lat*Math.PI/180) + 1/Math.cos(lat*Math.PI/180))/Math.PI)/2 *Math.pow(2,zoom)) }
              //function lon2tile(lon,zoom) { Math.floor((lon+180)/360*Math.pow(2,zoom)) }
              const coord = pos.position.coordinate
              //const zoom = mapContainer.tile_z
              //const y = lat2tile(coord.latitude, zoom)
              //const x = lon2tile(coord.longitude, zoom)
              const zoom = 4
              function project(lat, lng, zoom) {
                 const TILE_SIZE=512
                 const siny = Math.sin((lat * Math.PI) / 180);
                 // Truncating to 0.9999 effectively limits latitude to 89.189. This is
                 // about a third of a tile past the edge of the world tile.
                 siny = Math.min(Math.max(siny, -0.9999), 0.9999);
                 return {
                   "x": TILE_SIZE * (0.5 + lng / 360),
                   "y": TILE_SIZE * (0.5 - Math.log((1 + siny) / (1 - siny)) / (4 * Math.PI)),
                 };
              }

              //var res = LatLonToTile.latLngToTileXY(coord.latitude, coord.longitude, zoom)
              var res = project(coord.latitude, coord.longitude, zoom)
              mapContainer.tile_z = zoom
              const scale = 1 << zoom
              mapContainer.tile_x = Math.floor(res.x*scale/512)
              mapContainer.tile_y = Math.floor(res.y*scale/512)
              console.debug("New tile:", mapContainer.tile_z, mapContainer.tile_x, mapContainer.tile_y)
            }
         }
         IconButton { id: dwnbutt; anchors.right: gpsbutt.left;  anchors.margins: units.gu(1); rotation: -90; icon.source: "image://theme/icon-m-left"  ; onClicked: mapContainer.tile_y -= 1; enabled: mapContainer.tile_y>0 }
         IconButton { id: upbutt;  anchors.left:  gpsbutt.right; anchors.margins: units.gu(1); rotation: 90; icon.source: "image://theme/icon-m-left" ; onClicked: mapContainer.tile_y += 1; enabled: mapContainer.tile_y<(Math.pow(2,mapContainer.tile_z)) }

         IconButton { id: lftbutt; anchors.right: rgtbutt.left; anchors.margins: units.gu(1); icon.source: "image://theme/icon-m-left"    ; onClicked: mapContainer.tile_x -= 1; enabled: mapContainer.tile_x>0 }
         IconButton { id: rgtbutt; anchors.right: parent.right; anchors.margins: units.gu(1); icon.source: "image://theme/icon-m-right"   ; onClicked: mapContainer.tile_x += 1; enabled: mapContainer.tile_x<(Math.pow(2,mapContainer.tile_z))  }
      }

/*
      ButtonLayout {
         //visible: pos.active
         Button {
            icon.source: "image://theme/icon-m-gps?"
                       + ((pos.position.horizontalAccuracy < 5000)
                       ? Theme.presenceColor(Theme.PresenceAvailable) : brand.warn)
            text: i18n.tr("Zoom and Center")
            enabled: pos.active && pos.valid
            onClicked: {
              const coord = pos.position.coordinate
              //const lat = coord.latitude.toFixed(5)
              //const lon = coord.longitude.toFixed(5)
              function lat2tile(lat,zoom) { Math.floor((1-Math.log(Math.tan(lat*Math.PI/180) + 1/Math.cos(lat*Math.PI/180))/Math.PI)/2 *Math.pow(2,zoom)) }
              function lon2tile(lon,zoom) { Math.floor((lon+180)/360*Math.pow(2,zoom)) }
              const zoom = 0
              const y = lat2tile(coord.latitude, zoom)
              const x = lon2tile(coord.longitude, zoom)
              console.debug("New tile:", zoom, x, y )
              mapContainer.tile_z = zoom
              mapContainer.tile_x = x
              mapContainer.tile_y = y
            }
         }
      }
*/
      PositionSource { id: pos
          //updateInterval: posmapView.positionSet ? 1000*60*5 : 5000 // 5s or 5min
          active: allowLocation && parent.visible
          onPositionChanged: {
            if (!valid) return
            const coord = pos.position.coordinate
            console.debug("New position:", coord.latitude, coord.longitude)
          }
      }

      /*
      WebView { id: occmapView
         width: nameRow.width
         height: width *3/4
         anchors.horizontalCenter: parent.horizontalCenter
         active: gbifId != "-1"
         httpUserAgent: root.agent
         url: "https://api.gbif.org/v1/map/?"
             + "type=TAXON"
             + "&key=" + gbifId
             + "&layer=SP_2020_2030"
             + (Theme.colorScheme === Theme.LightOnDark ? "&style=light" : + "&style=classic")
             //+ "&resolution=4"
      }

      WebView { id: posmapView
         width: nameRow.width
         height: width *3/4
         anchors.horizontalCenter: parent.horizontalCenter
         active: (gbifId != "-1") && pos.valid
         httpUserAgent: root.agent
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
      */
  }
}
