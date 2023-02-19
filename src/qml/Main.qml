/*
 * Copyright (C) 2023  Alfred Neumayer
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * Box64AndWine is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Components.Themes 1.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.12
import Box64AndWine 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'box64andwine.fredldotme'
    automaticOrientation: true
    anchorToKeyboard: true
    theme.name: "Lomiri.Components.Themes.SuruDark"

    width: units.gu(45)
    height: units.gu(75)

    Component.onCompleted: {
        VMManager.refreshVMs();
    }

    AdaptivePageLayout {
        id: rootLayout
        anchors.fill: parent
        primaryPage: mainPage
        Page {
            id: mainPage
            header: PageHeader {
                id: header
                title: i18n.tr("Virtual machines")
                trailingActionBar {
                    actions: [
                        Action {
                            iconName: "info"
                            text: i18n.tr("Info")
                            onTriggered: {
                                mainPage.pageStack.addPageToNextColumn(mainPage, about)
                            }
                        },
                        Action {
                            iconName: "add"
                            text: i18n.tr("Add VM")
                            onTriggered: {
                                mainPage.pageStack.addPageToNextColumn(mainPage,
                                                                       addVmComponent.createObject(mainPage))
                            }
                        }
                    ]
                    numberOfSlots: 2
                }
            }
        }
    }
}
