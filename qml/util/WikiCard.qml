import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0

import "../util"

WebViewFlickable { id: wikiCard
   height: contents.height
   anchors.margins: units.gu(2)
   anchors.horizontalCenter: parent.horizontalCenter

   property string species
   readonly property string agent: "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"

   Column {
      id: contents
      width: parent.width

      WebView { id: webView
         width: parent.width
         height: width*4/3
         anchors.horizontalCenter: parent.horizontalCenter
         httpUserAgent: wikiCard.agent
         url: "https://wikipedia.org/" + encodeURI(species)
      }
  }
}
