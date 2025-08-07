/*
 * This file is part of FIXME
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 */
import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Share 1.0

ShareProvider {
    method: "images"
    capabilities: ["image/png", "image/jpeg"]

    onTriggered: {
        console.info("Share: received", resources.length, "images")
        console.debug("Share: received", JSON.stringify(resources, null, 2))
        app.activate() // Show window
        var urls = []
        const max = Math.min(resources.length, 5)
        for (var i = 0; i<max; ++i) {
            var res = resources[i]
            if (res.type ===  ShareResource.FilePathType) {
                urls.push("file://" + res.filePath)
            }
        }
        pageStack.push("../pages/RequestPage.qml", { "sharedImages": urls })
    }
}

// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4
