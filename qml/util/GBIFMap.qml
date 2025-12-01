import QtQuick 2.6
import Sailfish.Silica 1.0
import QtPositioning 5.4
import QtGraphicalEffects 1.0

GBIFCardBase { id: root

   property bool allowLocation: settings.allowLocation
   readonly property string agent: "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"

   cardTitle: i18n.tr("Occurrence Map")

   signal konamiCode
   onKonamiCode: {
      console.info("KONAMI!!!")
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
          property int tile_z: 3
          property int tile_x: 4
          property int tile_y: 2
          property string position: "%1/%2/%3".arg(Math.max(0,tile_z)).arg(Math.max(0,tile_x)).arg(Math.max(0,tile_y))
          property string srs: "3857" // Web Mercator
          //property string srs: "4326"   // Plate Caree/WGS84

          property int max_tiles: Math.pow(Math.pow(2, tile_z), 2)
          // 0: 1
          // 1: 2x2 = 4    = (2^zoom)^2
          // 2: 4x4 = 16
          // 3: 8x8 = 64
          property int max_x: tile_z == 0 ? 1 : Math.sqrt(max_tiles)
          property int max_y: tile_z == 0 ? 1 : Math.sqrt(max_tiles)
          property int max_z: 16 // https://labs.gbif.org/~mblissett/2025/09/wmts/GBIF-Occurrence.xml

          property color contrastColor:       (Theme.colorScheme === Theme.LightOnDark) ? Theme.lightPrimaryColor : Theme.darkPrimaryColor
          property color uiColor: (Theme.colorScheme === Theme.LightOnDark) ? Theme.darkPrimaryColor : Theme.lightPrimaryColor

          readonly property string konami: "nnssweweio"
          property string tapped: ""

          property bool failed: (occMapImage.status === Image.Error)

          onFailedChanged: if (failed) reset()
          onTappedChanged: {
              if (tapped.length > 128) tapped = tapped.slice(konami.length*-1)
              if (tapped.indexOf(konami) != -1) { root.konamiCode(); effect.start(); tapped = "" }
              //console.debug("Konamicheck:", konami, tapped)
          }

          function reset() { tile_z = 0; tile_x = 0; tile_y = 0 }

          Image { id: occMapImage
             visible: false
             //anchors.fill: parent
             sourceSize.width: 512; sourceSize.height: width
             source: "https://tile.gbif.org/" + parent.srs + "/omt/" + parent.position + "@1x.png"
                   //+ "?style=gbif-" + (Theme.colorScheme === Theme.LightOnDark ? "light" : + "classic")
                   + "?style=gbif-" + (Theme.colorScheme === Theme.LightOnDark ? "geyser" : "tuatara")
          }

          Image { id: occImage
             visible: false
             //anchors.fill: occMapImage
             //anchors.centerIn: occMapImage
             sourceSize.width: 512; sourceSize.height: width
             source: "https://api.gbif.org/v2/map/occurrence/density/" + parent.position + "@1x.png"
                 + "?taxonKey=" + gbifId
                 + "&srs=EPSG:" + parent.srs
                 + "&style=green.poly"
                 //+ "&style=" + (Theme.colorScheme === Theme.LightOnDark ? "green.poly" : + "classic.poly")
                 + "&bin=hex&hexPerTile=85" // number of hexagons across a tile -> larger gives smaller hexes, default 51
          }
          Image { id: fallbackMap
             visible: false
             //anchors.fill: parent
             width: 512; height: width
             sourceSize.width: 74; sourceSize.height: 24
             source: Qt.resolvedUrl("./white.png")
          }
          Image { id: fallbackOverlay
             visible: false
             //anchors.fill: parent
             width: 512; height: width
             sourceSize.width: 16; sourceSize.height: 16
             source: Qt.resolvedUrl("./trans.png")
          }
          Blend { id: blendedImage1
             anchors.fill: parent
             source:           (occMapImage.status == Image.Error) ? fallbackMap : occMapImage
             foregroundSource: (occImage.status == Image.Error)    ? fallbackOverlay : occImage
             mode: "normal"
             opacity: source.status === Image.Ready ? 1.0 : 0.0
             Behavior on opacity { FadeAnimator{} }
          }
          Label {
             anchors.top: parent.bottom
             text: mapContainer.position + " (" + mapContainer.max_tiles + ") " + mapContainer.max_x + "/" + mapContainer.max_y
             style: Text.Raised
             color: mapContainer.uiColor
             styleColor: mapContainer.contrastColor
             font.pixelSize: units.gu(1)
          }
          IconButton {
             anchors.right: parent.right
             anchors.top: parent.top
             anchors.margins: units.gu(1)
             icon.source: "image://theme/icon-m-website?" + mapContainer.uiColor
             onClicked: { mapContainer.tile_z = 0; mapContainer.tile_x = 0; mapContainer.tile_y = 0 }
          }
          IconButton { id: gpsbutt
            enabled: allowLocation && pos.active
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: units.gu(1);
            icon.source: "image://theme/icon-m-location?" + mapContainer.uiColor
            onClicked: {
              const coord = pos.position.coordinate
              // check for NaN, which is unequal to itself
              if (coord.longitude !== coord.longitude) return
              if (coord.latitude !== coord.latitude) return
              const lon = coord.longitude.toFixed(settings.locationPrecision)
              const lat = coord.latitude.toFixed(settings.locationPrecision)
              const zoom = (settings.locationPrecision > 5) ? settings.locationPrecision+2 : 6
              // from the google docs:
              function project(la, lo, zoom) {
                 const TILE_SIZE=512
                 const siny = Math.sin((la * Math.PI) / 180);
                 // Truncating to 0.9999 effectively limits latitude to 89.189. This is
                 // about a third of a tile past the edge of the world tile.
                 siny = Math.min(Math.max(siny, -0.9999), 0.9999);
                 return {
                   "x": TILE_SIZE * (0.5 + lo / 360),
                   "y": TILE_SIZE * (0.5 - Math.log((1 + siny) / (1 - siny)) / (4 * Math.PI)),
                 };
              }

              var res = project(lat, lon, zoom)
              mapContainer.tile_z = zoom
              const scale = 1 << zoom
              mapContainer.tile_x = Math.floor(res.x*scale/512)
              mapContainer.tile_y = Math.floor(res.y*scale/512)
              //console.debug("New tile:", mapContainer.tile_z, mapContainer.tile_x, mapContainer.tile_y)
            }
          }
          Label {
             visible: gpsbutt.enabled
             anchors.verticalCenter: gpsbutt.bottom
             anchors.horizontalCenter: gpsbutt.horizontalCenter
             text: pos.position.coordinate.latitude.toFixed(Math.min(3, settings.locationPrecision))
                 + " "
                 + pos.position.coordinate.longitude.toFixed(Math.min(3, settings.locationPrecision))
             style: Text.Raised
             color: mapContainer.uiColor
             styleColor: mapContainer.contrastColor
             font.pixelSize: units.gu(1)
          }
          Image { id: tiles
             anchors.top: parent.top
             anchors.left: parent.left
             width: height; height: Theme.iconSizeLarge
             visible: (mapContainer.tile_z > 1) && (mapContainer.tile_z < 12)
             cache: true
             sourceSize.width: 256; sourceSize.height: width
             source: "https://tile.gbif.org/" + mapContainer.srs + "/omt/0/0/0@Hx.png??style=gbif-light"
             Grid { id: grid
               anchors.fill: parent
               visible: parent.visible
               rows: columns
               columns: visible ? mapContainer.max_x : 0
               Repeater {
                 model: Math.pow(grid.columns,2)
                 delegate: Rectangle {
                    width: height
                    height: grid.width / grid.columns
                    color: "transparent"
                    Rectangle { // show a dot even if squares are too small:
                       anchors.centerIn: parent
                       width: height
                       height: Math.max(parent.height,2)
                       visible: parent.isCurrent
                       color: brand.danger //"#b0ff0000"
                    }
                    property bool isCurrent: {
                      const x = ( index % mapContainer.max_x )
                      const y = Math.floor( index / mapContainer.max_x)
                      return ((x == mapContainer.tile_x) && (y == mapContainer.tile_y))
                    }
                 }
                 }
             }
          }

          function zoomIn()  {
             if (tile_z == max_z) return
             tile_x = tile_x*2; tile_y = tile_y*2
             tile_z += 1
             tapped += 'i'
          }
          function zoomOut() {
             tile_x = Math.ceil(tile_x/2); tile_y = Math.ceil(tile_y/2)
             if (tile_y > max_y) tile_y -= 1
             if (tile_x > max_y) tile_x -= 1
             tile_z = Math.abs(tile_z - 1)
             tapped += 'o'
          }
          function north()   { tile_y = Math.abs(tile_y - 1); tapped += 'n' }
          function south()   { tile_y += 1; tapped += 's' }
          function west()    { tile_x = Math.abs(tile_x - 1); tapped += 'w' }
          function east()    { tile_x += 1; tapped += 'e' }
          SequentialAnimation { id: effect
             running: false
             ParallelAnimation {
                RotationAnimator { target: blendedImage1
                  from: 0; to: 360*3
                  easing.type: Easing.OutBounce;
                  duration: 6000
                  onStopped: blendedImage.rotation = 0
                }
                ScaleAnimator { target: blendedImage1
                  from: 1.0; to: 1.6
                  easing.type: Easing.InOutElastic;
                  duration: 2000
                  onStopped: blendedImage.scale = 1.0
                }
             }
             ScaleAnimator { target: blendedImage1
               to: 1.0; from: 1.6
               easing.type: Easing.InElastic;
               duration: 2000
               onStopped: blendedImage.scale = 1.0
             }
          }
      }
      Row {
         //width: mapContainer.width
         height: Theme.iconSizeMedium
         anchors.horizontalCenter: mapContainer.horizontalCenter
         spacing: units.gu(1)
         IconButton { id: rembutt;  icon.source: "image://theme/icon-m-remove"
            onClicked: mapContainer.zoomOut(); enabled: mapContainer.tile_z>0 }
         IconButton { id: addbutt;  icon.source: "image://theme/icon-m-add"
           onClicked: mapContainer.zoomIn(); enabled: mapContainer.tile_z<mapContainer.max_z }
         Item { width: units.gu(2) }
         IconButton { id: lftbutt;  icon.source: "image://theme/icon-m-left"
            onClicked: mapContainer.west(); enabled: mapContainer.tile_x>0 }
         IconButton { id: dwnbutt;  rotation: -90; icon.source: "image://theme/icon-m-left"
            onClicked: mapContainer.south(); enabled: mapContainer.tile_y<mapContainer.max_y-1 }
         IconButton { id: upbutt;   rotation: 90; icon.source: "image://theme/icon-m-left"
            onClicked: mapContainer.north(); enabled: mapContainer.tile_y>0 }
         Item { width: units.gu(2) }
         IconButton { id: rgtbutt;  icon.source: "image://theme/icon-m-right"
            onClicked: mapContainer.east(); enabled: mapContainer.tile_x<mapContainer.max_x-1  }
      }
      //Button { text: "konami"; onClicked: mapContainer.tapped = mapContainer.konami }

      PositionSource { id: pos
          active: allowLocation && parent.visible
          //updateInterval: posmapView.positionSet ? 1000*60*5 : 5000 // 5s or 5min
          updateInterval: (position.horizontalAccuracy < 5000) ? 1000*60*5 : 10000 // 10s or 5min
      }
   }
}
