import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    id: root

    default property alias content: menu.content
    property Item visualParent: null
    property alias status: popup.status

    function open() {
        popup.open()
    }

    function close() {
        popup.close()
    }

    visible: false

    Popup {
        id: popup
        objectName: "OptionsMenu"

        y: screen.height - popup.height

        function toolBarHeight() {
            return (screen.width < screen.height)
                ? privateStyle.toolBarHeightPortrait
                : privateStyle.toolBarHeightLandscape
        }

        animationDuration: 200
        state: "Hidden"
        visible: status != DialogStatus.Closed
        enabled: status == DialogStatus.Open
        width: screen.width
        height: menu.height
        clip: true

        onFaderClicked: {
            privateStyle.play(Symbian.PopupClose)
            close()
        }

        MenuContent {
            id: menu
            containingPopup: popup
            width: parent.width
            onItemClicked: popup.close()
        }

        states: [
            State {
                name: "Hidden"
                when: status == DialogStatus.Closing || status == DialogStatus.Closed
                PropertyChanges { target: menu; y: menu.height + 5; opacity: 0 }
            },
            State {
                name: "Visible"
                when: status == DialogStatus.Opening || status == DialogStatus.Open
                PropertyChanges { target: menu; y: 0; opacity: 1 }
            }
        ]

        transitions: [
            Transition {
                from: "Visible"; to: "Hidden"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            target: menu
                            property: "y"
                            duration: popup.animationDuration
                            easing.type: Easing.Linear
                        }
                        NumberAnimation {
                            target: menu
                            property: "opacity"
                            duration: popup.animationDuration
                            easing.type: Easing.Linear
                        }
                    }
                    PropertyAction { target: popup; property: "status"; value: DialogStatus.Closed }
                }
            },
            Transition {
                from: "Hidden"; to: "Visible"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            target: menu
                            property: "y"
                            duration: popup.animationDuration
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: menu
                            property: "opacity"
                            duration: popup.animationDuration
                            easing.type: Easing.Linear
                        }
                    }
                    PropertyAction { target: popup; property: "status"; value: DialogStatus.Open }
                }
            }
        ]
    }
}
