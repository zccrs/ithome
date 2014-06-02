import QtQuick 1.0
import com.nokia.symbian 1.0

Window {
    id: root

    property bool showStatusBar: true
    property bool showToolBar: true
    property variant initialPage
    property alias pageStack: stack

    property bool platformSoftwareInputPanelEnabled: false

    Component.onCompleted: {
        contentArea.initialized = true
        if (initialPage && stack.depth == 0)
            stack.push(initialPage, null, true)
    }

    onInitialPageChanged: {
        if (initialPage && contentArea.initialized) {
            if (stack.depth == 0)
                stack.push(initialPage, null, true)
            else if (stack.depth == 1)
                stack.replace(initialPage, null, true)
        }
    }

    onOrientationChangeStarted: {
        //statusBar.orientation = screen.currentOrientation
    }

    Item {
        id: contentArea

        property bool initialized: false

        anchors {
            top: sbar.bottom; bottom: sip.top;
            left: parent.left; right: parent.right;
        }

        PageStack {
            id: stack
            anchors.fill: parent
            toolBar: tbar
        }
    }

    StatusBar {
        id: sbar

        width: parent.width
        state: root.showStatusBar ? "Visible" : "Hidden"

        states: [
            State {
                name: "Visible"
                PropertyChanges { target: sbar; y: 0; opacity: 1 }
            },
            State {
                name: "Hidden"
                PropertyChanges { target: sbar; y: -height; opacity: 0 }
            }
        ]

        transitions: [
            Transition {
                from: "Hidden"; to: "Visible"
                ParallelAnimation {
                    NumberAnimation { target: sbar; properties: "y"; duration: 200; easing.type: Easing.OutQuad }
                    NumberAnimation { target: sbar; properties: "opacity"; duration: 200; easing.type: Easing.Linear }
                }
            },
            Transition {
                from: "Visible"; to: "Hidden"
                ParallelAnimation {
                    NumberAnimation { target: sbar; properties: "y"; duration: 200; easing.type: Easing.Linear }
                    NumberAnimation { target: sbar; properties: "opacity"; duration: 200; easing.type: Easing.Linear }
                }
            }
        ]
    }

    Item {
        id: sip

        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        Behavior on height { PropertyAnimation { duration: 200 } }

        states: [
            State {
                name: "Hidden"; when: root.showToolBar
                PropertyChanges { target: sip; height: tbar.height }
            },
            State {
                name: "HiddenInFullScreen"; when: !root.showToolBar
                PropertyChanges { target: sip; height: 0 }
            }
        ]
    }

    ToolBar {
        id: tbar

        width: parent.width
        state: root.showToolBar ? "Visible" : "Hidden"

        states: [
            State {
                name: "Visible"
                PropertyChanges { target: tbar; y: parent.height - height; opacity: 1 }
            },
            State {
                name: "Hidden"
                PropertyChanges { target: tbar; y: parent.height; opacity: 0 }
            }
        ]

        transitions: [
            Transition {
                from: "Hidden"; to: "Visible"
                ParallelAnimation {
                    NumberAnimation { target: tbar; properties: "y"; duration: 200; easing.type: Easing.OutQuad }
                    NumberAnimation { target: tbar; properties: "opacity"; duration: 200; easing.type: Easing.Linear }
                }
            },
            Transition {
                from: "Visible"; to: "Hidden"
                ParallelAnimation {
                    NumberAnimation { target: tbar; properties: "y"; duration: 200; easing.type: Easing.Linear }
                    NumberAnimation { target: tbar; properties: "opacity"; duration: 200; easing.type: Easing.Linear }
                }
            }
        ]
    }

    // event preventer when page transition is active
    MouseArea {
        anchors.fill: parent
        enabled: pageStack.busy
    }
}
