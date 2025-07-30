/*
 * This file is part of FIXME
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 */
import QtQuick 2.6
import Sailfish.Silica 1.0

Item { id: root
    property Item handler
    property int contentType
    signal peerSelected(var peer)
    signal cancelPressed
    onVisibleChanged: if(visible) pageStack.push(dlg)
    Component { id: dlg
        Dialog { }
    }
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
