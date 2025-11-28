import QtQuick 2.6
import Sailfish.Silica 1.0
//import Sailfish.WebView 1.0

Rectangle {
   radius: 10
   color: brand.background
   height: contents.height
   anchors.margins: units.gu(2)
   anchors.horizontalCenter: parent.horizontalCenter

   Behavior on opacity { FadeAnimator{} }

   property string species
   property string cardTitle: "Wikipedia"
   property string cardDesc: ""

   property double elementSpacing: units.gu(2)

   QtObject { id: brand
      readonly property color background: "#fff"
      readonly property color foreground: "#202122"
      readonly property color warn:       "#ffe49c"
      readonly property color danger:     "#9f3526"
      readonly property color link:       "#36c"
   }

   readonly property string query: "&prop=extracts|description|info"
                        + "&exintro=false"      // Return only content before the first section -> false
                        //+ "&explaintext=true" // extract is HTML or plain text
                        + "&exchars=1200"       // extract length
                        + "&redirects=1"        // 
                        + "&inprop=url"         // also return URL to the page
                        + "&formatversion=2"    // return pages as array not object

   readonly property string agent: "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"
   property string language: "en"
   property string mainText
   property string wikiUrl

   Column {
      id: contents
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      padding: units.gu(2)

      spacing: parent.elementSpacing

      Item { id: nameRow
         width: parent.width - parent.padding*2
         height: Theme.iconSizeMedium
         anchors.horizontalCenter: parent.horizontalCenter
         Image { id: logo
            source: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Wp_logo_unified_horiz_rgb_on_white_background.svg/330px-Wp_logo_unified_horiz_rgb_on_white_background.svg.png"
            height: Theme.iconSizeMedium
            sourceSize.height: 330
            fillMode: Image.PreserveAspectFit
         }
         Column {
             anchors.right: parent.right
             anchors.verticalCenter: logo.verticalCenter
             IconButton { id: button
                 anchors.right: parent.right
                 anchors.verticalCenter: logo.verticalCenter
                 icon.source: "image://theme/icon-m-website?" + brand.foreground
                 onClicked: {
                   language = (language == "en") ? Qt.locale().name.substr(0,2) : "en"
                   getPage(species)
                 }
             }
             Label { text: language; anchors.horizontalCenter: button.horizontalCenter; font.pixelSize: Theme.fontSizeTiny; color: brand.foreground }
         }
      }

      Label {
         width: parent.width - parent.padding*2
         wrapMode: Text.WordWrap
         textFormat: Text.RichText
         linkColor: brand.link
         color: brand.foreground
         text: mainText
      }
      LinkedLabel {
         plainText: wikiUrl
         linkColor: brand.link
         shortenUrl: true
      }
   }

   onSpeciesChanged: if (species) getPage(species)

   function getPage(term) {
      if (!term) return
      var r = new XMLHttpRequest()
      const url ="https://" + language + ".wikipedia.org/w/api.php?action=query&format=json"
                    + query + "&titles=" + encodeURI(term)
      r.open("GET", url)
      r.setRequestHeader('User-Agent', agent);
      r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      r.setRequestHeader('Origin', '');

      console.debug("Querying:", url)
      r.onreadystatechange = function(event) {
         if (r.readyState == XMLHttpRequest.DONE) {
            if (r.status === 200 || r.status == 0) {
                const rdata = JSON.parse(r.responseText)
                const page = rdata.query.pages[0]
                mainText  = page.extract
                wikiUrl   = page.fullurl
                cardTitle = page.title
                cardDesc  = page.description
            } else {
                console.debug("error in processing request.", query, r.status, r.statusText);
            }
         }
      }
      r.send();
   }

/*
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

*/
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
