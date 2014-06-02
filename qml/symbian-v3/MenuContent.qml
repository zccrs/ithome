

import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    id: root

    property alias content: contentArea.children
    property Popup containingPopup: null

    signal itemClicked()

    height: flickableArea.height

    QtObject {
        id: internal
        // Add padding in context menu case to align content area bottom with rounded background graphics.
        property int clipMargin: containingPopup.objectName != "OptionsMenu" ? platformStyle.paddingSmall : 0
        property int preferredHeight: privateStyle.menuItemHeight * ((screen.width < screen.height) ? 5 : 3)
    }

    BorderImage {
        source: containingPopup.objectName == "OptionsMenu"
            ? privateStyle.imagePath("qtg_fr_popup_options") : privateStyle.imagePath("qtg_fr_popup")
        border { left: 20; top: 20; right: 20; bottom: 20 }
        anchors.fill: parent
    }

    Item {
        height: flickableArea.height - internal.clipMargin
        width: root.width
        clip: true
        Flickable {
            id: flickableArea

            property int index: 0
            property bool itemAvailable: (contentArea.children[0] != undefined) && (contentArea.children[0].children[0] != undefined)
            property int itemHeight: itemAvailable ? Math.max(1, contentArea.children[0].children[0].height) : 1
            property int interactionMode: symbian.listInteractionMode

            height: contentArea.height; width: root.width
            clip: true
            contentHeight: contentArea.childrenRect.height
            contentWidth: width

            Item {
                id: contentArea

                property int itemsHidden: Math.floor(flickableArea.contentY / flickableArea.itemHeight)

                width: flickableArea.width
                height: childrenRect.height > internal.preferredHeight
                    ? internal.preferredHeight - (internal.preferredHeight % flickableArea.itemHeight)
                    : childrenRect.height

                onWidthChanged: {
                    for (var i = 0; i < children.length; ++i)
                        children[i].width = width
                }

                onItemsHiddenChanged: {
                    // Check that popup is really open in order to prevent unnecessary feedback
                    if (containingPopup.status == DialogStatus.Open
                        && symbian.listInteractionMode == Symbian.TouchInteraction)
                        privateStyle.play(Symbian.ItemScroll)
                }

                Component.onCompleted: {
                    for (var i = 0; i < children.length; ++i) {
                        if (children[i].clicked != undefined)
                            children[i].clicked.connect(root.itemClicked)
                    }
                }
            }

            onVisibleChanged: {
                enabled = visible
                if (itemAvailable)
                    contentArea.children[0].children[0].focus = visible
                contentY = 0
                index = 0
            }

            onInteractionModeChanged: {
                if (symbian.listInteractionMode == Symbian.KeyNavigation) {
                    contentY = 0
                    if (itemAvailable)
                        contentArea.children[0].children[index].focus = true
                } else if (symbian.listInteractionMode == Symbian.TouchInteraction) {
                    index = 0
                }
            }

            Keys.onPressed: {
                if (itemAvailable && (event.key == Qt.Key_Down || event.key == Qt.Key_Up)) {
                    if (event.key == Qt.Key_Down && index < contentArea.children[0].children.length - 1) {
                        index++
                        if (index * itemHeight > contentY + height - itemHeight) {
                            contentY = index * itemHeight - height + itemHeight
                            scrollBar.flash(Symbian.FadeOut)
                        }
                    } else if (event.key == Qt.Key_Up && index > 0) {
                        index--
                        if (index * itemHeight < contentY) {
                            contentY = index * itemHeight
                            scrollBar.flash(Symbian.FadeOut)
                        }
                    }
                    contentArea.children[0].children[index].focus = true
                    event.accepted = true
                }
            }
        }

        ScrollBar {
            id: scrollBar
            flickableItem: flickableArea
            interactive: false
            visible: flickableArea.height < flickableArea.contentHeight
            anchors {
                top: flickableArea.top
                right: flickableArea.right
            }
        }
    }

    Connections {
        target: containingPopup
        onStatusChanged: {
            if (containingPopup.status == DialogStatus.Open)
                scrollBar.flash(Symbian.FadeInFadeOut)
        }
    }
}
