// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1
Item{
    width: parent.width
    height: off_on.height
    property string switch_text:""
    anchors.topMargin: 20
    property alias checked: off_on.checked
    signal isPressed
    opacity: night_mode?brilliance_control:1
    Text{
        id:switchText
        text:switch_text
        font.pixelSize: 26
        anchors.left: parent.left
        //anchors.leftMargin: 10
        height:off_on.height
        verticalAlignment: Text.AlignVCenter
        color: main.night_mode?"#f0f0f0":"#282828"

    }
    Switch {
        id:off_on
        anchors.top: switchText.top
        anchors.right: parent.right
        //anchors.rightMargin: 10
        onCheckedChanged: {
            isPressed()
        }
    }
}
