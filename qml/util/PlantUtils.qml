pragma Singleton

import QtQuick 2.4

Item {
   // we are a singleton!
   property alias i18n: i18n
   QtObject { id: i18n; function tr(s) { return qsTr(s) } }
   property var organs: ([{
                             "name": "auto",
                             "title": i18n.tr("Auto")
                          }, {
                             "name": "leaf",
                             "title": i18n.tr("Leaf")
                          }, {
                             "name": "flower",
                             "title": i18n.tr("Flower")
                          }, {
                             "name": "fruit",
                             "title": i18n.tr("Fruit")
                          }, {
                             "name": "bark",
                             "title": i18n.tr("Bark")
                          }])

   function toTitle(name) {
      for (var i = 0; i < organs.length; i++) {
         if (organs[i].name === name)
            return organs[i].title
      }

      return ""
   }
}
