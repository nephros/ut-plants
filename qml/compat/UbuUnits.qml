/*
 * This file is part of FIXME
 * SPDX-FileCopyrightText: Copyright (c) 2025 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 */
import QtQuick 2.6
import Sailfish.Silica 1.0

/* compatability for Ubuntu Touch "unit.gu(X)" */
QtObject {
    // default: let gu(16) be as large as a small Item
    // default: let gu(8) be as large as a tiny Button
    property int reference: Theme.itemSizeSmall
    property int target: 16
    property double fact: reference/target

    function dp(inval) { return Theme.dp(inval) }
    /* https://docs.ubports.com/en/latest/humanguide/design-concepts/units.html

       Most laptops 1 gu = 8 px
       High DPI laptops 1 gu = 16 px
       Phone with 4 inch screen at HD resolution (around 720x1,280 pixels) 1 gu = 18 px
       Tablet with 10 inch screen at HD resolution (around 720x1,280 pixels) 1 gu = 10 px
    function gu(inval) {
        return inval * Theme.paddingMedium/2
        return Math.round(inval*fact)
        if (Screen.sizeCategory == Screen.Small)      return fact * 18  * inval
        if (Screen.sizeCategory == Screen.Medium)     return fact * 16 * inval
        if (Screen.sizeCategory == Screen.Large)      return fact * 8 * inval
        if (Screen.sizeCategory == Screen.ExtraLarge) return fact * 10 * inval
    }
    */
    // new reference: gu(2) == Theme.fontSizeMedium
    function gu(inval) {
        return inval/2 * Theme.fontSizeMedium
    }
    Component.onCompleted: {
        if (Screen.sizeCategory == Screen.Small)      console.info("Scaling for a Small screen: 1 gu is %1px".arg(gu(1)))
        if (Screen.sizeCategory == Screen.Medium)     console.info("Scaling for a Medium screen: 1 gu is %1px".arg(gu(1)))
        if (Screen.sizeCategory == Screen.Large)      console.info("Scaling for a Large screen: 1 gu is %1px".arg(gu(1)))
        if (Screen.sizeCategory == Screen.ExtraLarge) console.info("Scaling for a XLarge screen: 1 gu is %1px".arg(gu(1)))
        //console.info("Factor:", fact, "ref:", reference, "target:", target)
    }
}



// vim: filetype=javascript syntax=qml expandtab tabstop=4 shiftwidth=4

