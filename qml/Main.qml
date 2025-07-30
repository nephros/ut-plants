import QtQuick 2.6
import Sailfish.Silica 1.0
import "./util"
import "./pages"
import "./compat"

MainView {
   id: root
   objectName: 'mainView'
   applicationName: 'plants.s710'
   automaticOrientation: false

   //width: units.gu(45)
   //height: units.gu(75)

   Settings {
      id: settings
      property bool keepDisplayOn: false
   }

   UbuUnits { id: units }
   MainPage { id: mainPage }
   initialPage: mainPage
   /*
   ScreenSaver {
      id: screen_saver
      screenSaverEnabled: !settings.keepDisplayOn
   }
   PageStack {
      id: pageStack
      anchors.fill: parent

      Component.onCompleted: {
         push(mainPage)
      }

      MainPage {
         id: mainPage
         visible: false
      }
   }
   */
}
