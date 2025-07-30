/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-License-Identifier: MIT
 */
import QtQuick 2.6
import Sailfish.Silica 1.0

ApplicationWindow {
    property string applicationName
    property bool automaticOrientation: true
    allowedOrientations: automaticOrientation ? Orientation.All : defaultOrientations
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
