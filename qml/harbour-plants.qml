/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-License-Identifier: MIT
 */
import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.KeepAlive 1.2
import "pages"
import "compat"

ApplicationWindow {
    id: app
    allowedOrientations: defaultAllowedOrientations
    cover: coverPage
    initialPage: mainPage
    property alias mainPage: mainPage
    Component { id: mainPage
        MainPage{}
    }
    property bool loadingScreenShown: false
    property alias units: units
    property alias i18n: i18n
    UbuUnits { id: units }
    QtObject { id: i18n; function tr(s) { return qsTr(s) } }
    Settings {
       id: settings
       property bool keepDisplayOn: false
       property bool apiKey: false
       property bool disclaimerAccepted: false
    }
    DisplayBlanking { id: blanking
       preventBlanking: settings.keepDisplayOn
    }
    Component { id: coverPage
        CoverBackground {
            CoverPlaceholder {
                text: "Plants"
                textColor: Theme.highlightColor
                icon.source: "image://theme/harbour-plants"
            }
        }
    }
    //apparently, a DockedPanel can be in an ApplicationWindow, but we must bind bottomMargin: panel.visibleSize
    bottomMargin: loadingScreen.visibleSize
    DockedPanel{ id: loadingScreen
        open: app.loadingScreenShown
        dock: Dock.Bottom
        SilicaItem {
            width: loadingScreen.width
            height: dockCol.height
            //background.color: Theme.overlayBackgroundColor
            opacity: Theme.opacityOverlay
            Column { id: dockCol
                width: parent.width
                ProgressBar {
                    width: parent.width
                    indeterminate: true
                }
                Label {
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("Plant is being identified, please wait.")
                    wrapMode: Text.WordWrap
                }
             }
        }
    }
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
