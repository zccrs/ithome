// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
Page{
    orientationLock : screenOrientation
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
    onStatusChanged: {
        if(status===PageStatus.Active)
        {
            forceActiveFocus();//获得焦点
        }
    }
}
