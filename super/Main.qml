/***************************************************************************
* Copyright (c) 2013 "Super" Nathan Weber <supernathansunshine@gmail.com
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 1.1
import SddmComponents 1.1

Rectangle {
    id: container
    width: 1024
    height: 768

    property int sessionIndex: session.index

    Connections {
        target: sddm
        onLoginSucceeded: {
        }

        onLoginFailed: {
            txtMessage.text = qsTr("Login failed. Please try again.")
            listView.currentItem.password.text = ""
        }
    }

    FontLoader { id: clockFont; source: "GeosansLight.ttf" }

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            source: config.background
            fillMode: Image.PreserveAspectCrop
        }
    }

    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        color: "transparent"

        Component {
            id: userDelegate

            PictureBox {
                anchors.verticalCenter: parent.verticalCenter
                name: (model.realName === "") ? model.name : model.realName
                icon: model.icon

                focus: (listView.currentIndex === index) ? true : false
                state: (listView.currentIndex === index) ? "active" : ""

                onLogin: sddm.login(model.name, password, sessionIndex);

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: listView.currentIndex = index
                    onClicked: listView.focus = true
                }
            }
        }

        Row {
            anchors.fill: parent

            Rectangle {
                width: parent.width / 2; height: parent.height
                color: "#333333"

                Clock {
                    id: clock
                    anchors.centerIn: parent
                    color: "#9B9B9B"
                    timeFont.family: clockFont.name
                }
            }

            Rectangle {
                width: parent.width / 2; height: parent.height
                color: "#333333"
                clip: true

                Item {
                    id: usersContainer
                    width: parent.width; height: 300
                    anchors.verticalCenter: parent.verticalCenter

                    ImageButton {
                        id: prevUser
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 10
                        source: "angle-left.png"
                        onClicked: listView.decrementCurrentIndex()

                        KeyNavigation.backtab: btnShutdown; KeyNavigation.tab: listView
                    }

                    ListView {
                        id: listView
                        height: parent.height
                        anchors.left: prevUser.right; anchors.right: nextUser.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 10

                        clip: true
                        focus: true

                        spacing: 5

                        model: userModel
                        delegate: userDelegate
                        orientation: ListView.Horizontal
                        currentIndex: userModel.lastIndex

                        KeyNavigation.backtab: prevUser; KeyNavigation.tab: nextUser
                    }

                    ImageButton {
                        id: nextUser
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 10
                        source: "angle-right.png"
                        onClicked: listView.incrementCurrentIndex()
                        KeyNavigation.backtab: listView; KeyNavigation.tab: session
                    }
                }

                Text {
                    id: txtMessage
                    anchors.top: usersContainer.bottom;
                    anchors.margins: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#9B9B9B"
                    text: qsTr("Enter Username and Password")

                    font.pixelSize: 20
                }
            }
        }

        Rectangle {
            id: actionBar
            anchors.top: parent.top;
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#555555"
            width: parent.width; height: 38

            Row {
                anchors.left: parent.left
                anchors.margins: 5
                height: parent.height
                spacing: 5

                Text {
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Session:")
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox {
                    id: session
                    color: "#666666"
                    width: 245
                    anchors.verticalCenter: parent.verticalCenter

                    arrowIcon: "angle-down.png"

                    model: sessionModel
                    index: sessionModel.lastIndex

                    font.pixelSize: 14

                    KeyNavigation.backtab: nextUser; KeyNavigation.tab: btnReboot
                }
            }

            Row {
                height: parent.height
                anchors.right: parent.right
                anchors.margins: 5
                spacing: 5

                ImageButton {
                    id: btnReboot
                    height: parent.height
                    source: "reboot.png"

                    visible: sddm.canReboot

                    onClicked: sddm.reboot()

                    KeyNavigation.backtab: session; KeyNavigation.tab: btnShutdown
                }

                ImageButton {
                    id: btnShutdown
                    height: parent.height
                    source: "shutdown.png"

                    visible: sddm.canPowerOff

                    onClicked: sddm.powerOff()

                    KeyNavigation.backtab: btnReboot; KeyNavigation.tab: prevUser
                }
            }
        }
    }
}
