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
    onLoadingScreenShownChanged: {
        console.debug("loading:", loadingScreenShown)
        loadingScreen.open = loadingScreenShown
    }

    // UT compat helpers:
    property alias units: units
    property alias i18n: i18n
    UbuUnits { id: units }
    QtObject { id: i18n; function tr(s) { return qsTr(s) } }

    QtObject { id: brand
       // PlantNet web page CSS: "brand-solid": #8eb533
       // PlantNet web page CSS: "brand-background-subtle": #f6f8ed
       // PlantNet web page CSS: "brand-text": #394611
       readonly property color background: Theme.colorScheme == Theme.LightOnDark ? "#8eb533" : "#f6f8ed"
       readonly property color foreground: Theme.colorScheme == Theme.LightOnDark ? "#f6f8ed" : "#394611"
       readonly property color warn:       Theme.highlightFromColor("#ffe629", Theme.colorScheme)
       readonly property color danger:     Theme.highlightFromColor("#d13415", Theme.colorScheme)
    }

    Settings {
       id: settings
       property bool preventSleep: false
       property bool apiKey: false
       property bool disclaimerAccepted: false
    }

    KeepAlive { id: keepAlive
       enabled: settings.preventSleep && app.loadingScreenShown
    }

    Component { id: coverPage
        CoverBackground {
            Image {
                source: "./cover-background.svg"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                //height: parent.height
                width: parent.width
                sourceSize.width: width
                fillMode: Image.PreserveAspectFit
                opacity: 0.2
            }
            CoverPlaceholder {
                text: "Plants"
                textColor: Theme.highlightColor
                //icon.source: "image://theme/harbour-plants"
            }
        }
    }
    //apparently, a DockedPanel can be in an ApplicationWindow, but we must bind bottomMargin: panel.visibleSize
    bottomMargin: loadingScreen.expanded ? loadingScreen.visibleSize : 0
    DockedPanel{ id: loadingScreen
        dock: Dock.Bottom
        modal: false
        animationDuration: 200
        onOpenChanged: console.debug("Panel open:", open)
        Rectangle {
            anchors.fill: parent
            opacity: Theme.opacityOverlay
            color: Theme.highlightBackgroundFromColor(brand.background, Theme.colorScheme)
        }
        Row { id: dockCol
            width: loadingScreen.width
            height: Math.max(bind.height, plabel.height)
            //background.color: Theme.overlayBackgroundColor
            BusyIndicator { id: bind
                anchors.verticalCenter: parent.verticalCenter
                size: BusyIndicatorSize.Medium
                running: loadingScreen.expanded
            }
            Label { id: plabel
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - bind.width
                text: i18n.tr("Plant is being identified, please wait.")
                wrapMode: Text.WordWrap
            }
        }
    }
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
