import QtQuick 1.0
import com.nokia.symbian 1.0
import "AppManager.js" as Utils

Item {
    id: root

    property Item visualParent
    property int status: DialogStatus.Closed
    property int animationDuration: 500
    property Item fader

    signal faderClicked

    function open() {
        fader = faderComponent.createObject(visualParent ? visualParent : Utils.rootObject())
        fader.animationDuration = root.animationDuration
        root.parent = fader
        status = DialogStatus.Opening
        fader.state = "Visible"
        platformPopupManager.privateNotifyPopupOpen()
    }

    function close() {
        if (status != DialogStatus.Closed) {
            status = DialogStatus.Closing
            if (fader)
                fader.state = "Hidden"
        }
    }

    onStatusChanged: {
        if (status == DialogStatus.Closed && fader) {
            // Temporarily setting root window as parent
            // otherwise transition animation jams
            root.parent = null
            fader.destroy()
            root.parent = parentCache.oldParent
            platformPopupManager.privateNotifyPopupClose()
        }
    }

    Component.onCompleted: {
        parentCache.oldParent = parent
    }

    //if this is not given, application may crash in some cases
    Component.onDestruction: {
        if (parentCache.oldParent != null) {
            parent = parentCache.oldParent
        }
    }

    QtObject {
        id: parentCache
        property QtObject oldParent: null
    }

    //This eats mouse events when popup area is clicked
    MouseArea {
        anchors.fill: parent
    }

    Component {
        id: faderComponent

        Fader {
            onClicked: root.faderClicked()
        }
    }
}
