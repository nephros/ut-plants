import QtQuick 2.6
//import Lomiri.Components 1.3
//import QtQuick.Layouts 1.3
//import Qt.labs.platform 1.1
//import Lomiri.Content 1.1
//import Lomiri.Components.Popups 1.3
//import Qt.labs.settings 1.0
//import QtSystemInfo 5.0
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
