/*
 * This file is part of FIXME
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 */
import QtQuick 2.6
import Sailfish.Silica 1.0

TouchBlocker { id: root
    property Item sensingArea
    property bool topmostItem
    signal pressed
    signal onPressed
    //onLongPress: pressed()
    Component.onCompleted: console.debug("InversMouseArea compat item instantiated")
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4

