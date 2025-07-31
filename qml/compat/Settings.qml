/*
 * This file is part of FIXME
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 */
import QtQuick 2.6
//import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

ConfigurationGroup {
    Component.onCompleted: {
    path = "/apps/"
         + (Qt.application.organization ? Qt.application.organization : "unknown") + "/"
         + (Qt.application.name ? Qt.application.name : "unknown")
        console.debug("Settings path set to:", path)
    }
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4

