import QtQuick 1.0
import com.nokia.symbian 1.0
Rectangle {
    id: root


    Image{
        source: "qrc:/Image/01.png"
        anchors.left: parent.left
        anchors.top: parent.top
        z:3
    }
    Image{
        source: "qrc:/Image/02.png"
        anchors.right: parent.right
        anchors.top: parent.top
        z:3
    }

    // The status of the page. One of the following:
    //      PageStatus.Inactive - the page is not visible
    //      PageStatus.Activating - the page is transitioning into becoming the active page
    //      PageStatus.Active - the page is the current active page
    //      PageStatus.Deactivating - the page is transitioning into becoming inactive
    color: main.night_mode?"#000000":"#f1f1f1"
    property int status: PageStatus.Inactive

    property PageStack pageStack

    // Defines orientation lock for a page
    property int orientationLock : screenOrientation
    property Item tools: null

    visible: false

    width: visible && parent ? parent.width : internal.previousWidth
    height: visible && parent ? parent.height : internal.previousHeight

    onWidthChanged: internal.previousWidth = visible ? width : internal.previousWidth
    onHeightChanged: internal.previousHeight = visible ? height : internal.previousHeight

    onStatusChanged: {
        if (status == PageStatus.Activating)
            internal.orientationLockCheck();
        if(status == PageStatus.Active)
        {
            forceActiveFocus();//获得焦点
        }
    }

    onOrientationLockChanged: {
        if (status == PageStatus.Activating || status == PageStatus.Active)
            internal.orientationLockCheck();
    }



    QtObject {
        id: internal
        property int previousWidth: 0
        property int previousHeight: 0

        function isScreenInPortrait() {
            return screen.currentOrientation == Screen.Portrait || screen.currentOrientation == Screen.PortraitInverted;
        }

        function isScreenInLandscape() {
            return screen.currentOrientation == Screen.Landscape || screen.currentOrientation == Screen.LandscapeInverted;
        }

        function orientationLockCheck() {
            //utility.consoleLog("屏幕状态是："+PageOrientation.Manual)
            switch (orientationLock) {
            case PageOrientation.Automatic:
                screen.allowedOrientations = Screen.Default
                break
            case PageOrientation.LockPortrait:
                screen.allowedOrientations = Screen.Portrait
                break
            case PageOrientation.LockLandscape:
                screen.allowedOrientations = Screen.Landscape
                break
            case PageOrientation.LockPrevious:
                screen.allowedOrientations = screen.currentOrientation
                break
            case PageOrientation.Manual:
            default:
                // Do nothing
                // In manual mode it is expected that orientation is set
                // explicitly to "screen.allowedOrientations" by the user.
                break
            }
        }
    }

    Component.onCompleted: internal.orientationLockCheck()//改变屏幕状态。横屏 竖屏 自动旋转
}

