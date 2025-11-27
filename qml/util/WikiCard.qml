import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0

import "../util"

WebViewFlickable { id: wikiCard
   //anchors.left: parent.left
   //anchors.right: parent.right
   anchors.horizontalCenter: parent.horizontalCenter
   height: width*3/5

   property string cardTitle: "Wikispecies"
   property bool loaded: webView.loaded
   onLoadedChanged: cardTitle = webView.title

   property string species
   readonly property string agent: "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"

   webView.httpUserAgent: wikiCard.agent
   webView.url: "https://species.wikimedia.org/w/index.php?title=" + encodeURI(species)
                                                            //+ "&useskin=minerva"
                                                            + "&useskin=timeless"
                                                            + "&vectornightmode=%1".arg((Theme.colorTheme == Theme.LightOnDark) ? "1" : "0")

   /*
   header: Component { Row {
      width: parent.width
      spacing: units.gu(2)
      Image { id: logo
         anchors.verticalCenter: marks.verticalCenter
         source: "https://species.wikimedia.org/static/images/icons/specieswiki.svg"
         height: Theme.iconSizeMedium
         sourceSize.height: Theme.iconSizeMedium
         fillMode: Image.PreserveAspectFit
      }
      Column { id: marks
         anchors.verticalCenter: parent.verticalCenter
         Image { id: wordmark
            source: "https://species.wikimedia.org/static/images/mobile/copyright/specieswiki-wordmark.svg"
            fillMode: Image.PreserveAspectFit
         }
         Image { id: tagline
            source: "https://species.wikimedia.org/static/images/mobile/copyright/specieswiki-tagline.svg"
            fillMode: Image.PreserveAspectFit
         }
      }
   }}
   */

}
