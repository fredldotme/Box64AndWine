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

    Component.onCompleted: {
        FeatureManager.commandRunner = CommandRunner;
        PopupUtils.open(dialog);
    }

    property bool checked : false
    property bool supported : false
    property bool featureEnabled : false

    function recheckSupport() {
        supported = FeatureManager.recheckSupport();
        featureEnabled = FeatureManager.enabled();
        checked = true;
    }

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
                        recheckSupport();
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
        }

        Column {
            visible: root.checked
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: units.gu(1)

            Icon {
                width: Math.min(root.width, root.height) / 2
                anchors.horizontalCenter: parent.horizontalCenter
                height: width
                name: root.supported ? "tick" : "close"
            }
            Label {
                width: Math.min(root.width, root.height) / 2
                text: "Kernel support: " + (root.supported ?
                                                "Available" :
                                                "Not available. Please contact your device port "+
                                                "maintainer to enable binfmt_misc functionality "+
                                                "for this device.")
                wrapMode: Text.WordWrap
            }
            Item {
                height: units.gu(4)
            }
            Row {
                spacing: units.gu(1)
                Switch {
                    id: enablementSwitch
                    enabled: supported
                    onCheckedChanged: {
                        if (checked)
                            featureEnabled = FeatureManager.enable() ? true : false
                        else
                            featureEnabled = FeatureManager.disable() ? false : true
                    }
                }
                Label {
                    text: "Enable x86_64 and PE executable support"
                }
            }
        }
    }
}
