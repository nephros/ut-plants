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
    Component.onCompleted: {
        console.info("%1.%2 v%3 is starting.".arg(Qt.organization.name).arg(Qt.application.name).arg(Qt.application.version))
    }

    cover: coverPage
    initialPage: mainPage
    property alias mainPage: mainPage
    Component { id: mainPage
        MainPage{}
    }

    property bool loadingScreenShown: false
    onLoadingScreenShownChanged: {
        console.debug("loading:", loadingScreenShown)
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
       readonly property color background: Theme.colorScheme === Theme.LightOnDark ? "#8eb533" : "#f6f8ed"
       readonly property color foreground: Theme.colorScheme === Theme.LightOnDark ? "#f6f8ed" : "#394611"
       //readonly property color warn:       Theme.highlightFromColor("#ffe629", Theme.colorScheme)
       //readonly property color danger:     Theme.highlightFromColor("#d13415", Theme.colorScheme)
       readonly property color warn:       Theme.colorScheme === Theme.LightOnDark ? "#ffe629" : Theme.highlightFromColor("#ffe629", Theme.colorScheme)
       readonly property color danger:     Theme.colorScheme === Theme.LightOnDark ? "#d13415" : Theme.highlightFromColor("#d13415", Theme.colorScheme)
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
            /* TODO:
            ProgressBar {
                width: parent.width
                y: parent.height *1/5
                anchors.horizontalCenter: parent.horizontalCenter
                visible: app.loadingScreenShown
                indeterminate : true
            }
            CoverActionList {
                enabled: pageStack.currentPage.objectName == "mainPage"
                CoverAction {
                    iconSource:  "image://theme/icon-cover-new"
                    onTriggered: { mainPage.openIdentify(); appWindow.activate() }
                }
            }
            */
        }
    }
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
