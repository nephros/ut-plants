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
    id: root
    allowedOrientations: defaultAllowedOrientations
    cover: coverPage
    initialPage: mainPage
    property alias mainPage: mainPage
    Component { id: mainPage
        MainPage{}
    }
    property alias units: units
    property alias i18n: i18n
    UbuUnits { id: units }
    QtObject { id: i18n; function tr(s) { return qsTr(s) } }
    Settings {
       id: settings
       property bool keepDisplayOn: false
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
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
