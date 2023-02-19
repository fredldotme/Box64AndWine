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

    width: units.gu(45)
    height: units.gu(75)

    AdaptivePageLayout {
        id: rootLayout
        anchors.fill: parent
        primaryPage: mainPage

        property bool dialogIsOpen: false

        Component.onCompleted: {
            FeatureManager.commandRunner = CommandRunner;
            dialogIsOpen = true;
            PopupUtils.open(dialog);
        }

        // First start password entry
        Component {
            id: dialog

            Dialog {
                id: dialogue
                title: qsTr("Authentication required")
                text: qsTr("Please enter your user PIN or password to continue:")

                Connections {
                    target: CommandRunner
                    onPasswordRequested: {
                        CommandRunner.providePassword(entry.text)
                    }
                }

                Timer {
                    id: enterDelayTimer
                    interval: 1000
                    running: false
                    onTriggered: entry.text = ""
                }

                TextField {
                    id: entry
                    placeholderText: qsTr("PIN or password")
                    echoMode: TextInput.Password
                    focus: true
                    enabled: !enterDelayTimer.running
                }
                Button {
                    text: qsTr("Ok")
                    color: theme.palette.normal.positive

                    enabled: !enterDelayTimer.running
                    onClicked: {
                        if (CommandRunner.validatePassword()) {
                            PopupUtils.close(dialogue)
                            dialogIsOpen = false
                            FeatureManager.recheckSupport();
                        } else {
                            enterDelayTimer.start()
                        }
                    }
                }

                Button {
                    text: qsTr("Cancel")
                    enabled: !enterDelayTimer.running
                    onClicked: {
                        PopupUtils.close(dialogue)
                        dialogIsOpen = false
                        Qt.quit()
                    }
                }
            }
        }

        Page {
            id: mainPage
            header: PageHeader {
                id: header
                title: i18n.tr("Box64 + Wine")
                trailingActionBar {
                    actions: [
                        Action {
                            iconName: "view-refresh"
                            text: i18n.tr("Recheck support")
                            onTriggered: { FeatureManager.recheckSupport(); }
                        }
                    ]
                    numberOfSlots: 1
                }
            }

            Column {
                anchors.top: header.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Row {
                    CheckBox {
                        enabled: false
                        text: "Kernel support: " + checked ? "Not available" : "Available"
                        checked: FeatureManager.supported
                    }
                }
                Row {
                    Switch {
                        enabled: true
                        text: "Enable x86_64 and PE executable support"
                        onCheckedChanged: {
                            if (checked)
                                checked = FeatureManager.enable() ? true : false
                            else
                                checked = FeatureManager.disable() ? false : true
                        }
                    }
                }
            }
        }
    }
}
