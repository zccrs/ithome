import QtQuick 1.0
import Qt.labs.components 1.0
import com.nokia.symbian 1.0

ImplicitSizeItem {
    id: root

    // Common Public API
    property alias checked: checkable.checked
    property bool pressed: stateGroup.state == "Pressed"
    signal clicked
    property alias text: label.text

    // Symbian specific API
    property alias platformExclusiveGroup: checkable.exclusiveGroup

    QtObject {
        id: internal
        objectName: "internal"

        function press() {
            privateStyle.play(Symbian.BasicItem)
        }

        function toggle() {
            privateStyle.play(Symbian.CheckBox)
            clickedEffect.restart()
            checkable.toggle()
            root.clicked()
        }

        function icon_postfix() {
            //if (pressed)
                //return "pressed"
            if (root.checked) {
                if (!root.enabled)
                    return privateStyle.imagePath("qtg_graf_radiobutton_disabled_selected")
                else
                    return privateStyle.imagePath("qtg_graf_radiobutton_pressed")
            } else {
                if (!root.enabled)
                    return privateStyle.imagePath("qtg_graf_radiobutton_disabled_unselected")
                else
                    return main.night_mode?privateStyle.imagePath("qtg_graf_radiobutton_normal_unselected"):"qrc:/Image/radioButton_white_symbian.png"
            }
        }
    }

    StateGroup {
        id: stateGroup

        states: [
            State { name: "Pressed" },
            State { name: "Canceled" }
        ]

        transitions: [
            Transition {
                to: "Pressed"
                ScriptAction { script: internal.press() }
            },
            Transition {
                from: "Pressed"
                to: ""
                ScriptAction { script: internal.toggle() }
            }
        ]
    }

    implicitWidth: privateStyle.textWidth(label.text, label.font) + platformStyle.paddingMedium + privateStyle.buttonSize
    implicitHeight: privateStyle.buttonSize

    Image {
        id: image
        source: internal.icon_postfix()
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        sourceSize.width: 30
        sourceSize.height: 30
    }
    Text {
        id: label
        elide: Text.ElideRight
        anchors.left: image.right
        anchors.leftMargin: platformStyle.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        color: main.night_mode?platformStyle.colorNormalLight:"black"
        opacity: main.night_mode?main.brilliance_control:1
        font { family: platformStyle.fontFamilyRegular; pixelSize: 14 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onPressed: stateGroup.state = "Pressed"
        onReleased: stateGroup.state = ""
        onClicked: stateGroup.state = ""
        onExited: stateGroup.state = "Canceled"
        onCanceled: {
            // Mark as canceled
            stateGroup.state = "Canceled"
            // Reset state. Can't expect a release since mouse was ungrabbed
            stateGroup.state = ""
        }
    }

    ParallelAnimation {
        id: clickedEffect
        SequentialAnimation {
            PropertyAnimation {
                target: image
                property: "scale"
                from: 1.0
                to: 0.8
                easing.type: Easing.Linear
                duration: 50
            }
            PropertyAnimation {
                target: image
                property: "scale"
                from: 0.8
                to: 1.0
                easing.type: Easing.OutQuad
                duration: 170
            }
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Select || event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
            checkable.toggle()
            clickedEffect.restart()
            root.clicked()
            event.accepted = true
        }
    }

    Checkable {
        id: checkable
        value: root.text
        enabled: true
    }
}
