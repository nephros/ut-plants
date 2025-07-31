/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-License-Identifier: MIT
 */
import QtQuick 2.6
import Nemo.Configuration 1.0

ConfigurationGroup {
    Component.onCompleted: {
        const orgName = Qt.application.organization ? Qt.application.organization : ("unknown-" + Qt.md5(Qt.application.arguments.join("")) )
        const appName = Qt.application.name         ? Qt.application.name         : ("unknown-" + Qt.md5(Qt.application.arguments[0]))
        path = "/apps/" + orgName + "/" + appName
    }
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
