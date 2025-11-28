import QtQuick 2.6
import Sailfish.Silica 1.0

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

      //console.debug("Querying:", url)
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
}
