import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle { id: root
   radius: 10
   color: brand.background
   height: contents.height
   anchors.margins: units.gu(2)
   anchors.horizontalCenter: parent.horizontalCenter

   Behavior on opacity { FadeAnimator{} }

   property string species
   property string gbifId: "-1"
   property string cardTitle
   property string cardDesc: ""

   onSpeciesChanged: if(species) {
      console.debug("WARN: should migrate this call to Worker Script!")
      root.gbifId = "-1"
      GBIFUtil.lookupSpeciesByName(species, function(res) { root.gbifId = res } )
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
}
