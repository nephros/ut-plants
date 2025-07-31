/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-License-Identifier: MIT
 */
import QtQuick 2.6
import Sailfish.Silica 1.0
import "pages"
import "compat"

ApplicationWindow {
    id: root
    allowedOrientations: defaultAllowedOrientations
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

}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
