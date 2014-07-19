// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
Item{
    width: parent.width
    height: off_on.height
    //color: night_mode?"#3c3c3c":"#e0e0e0"
    property string switch_text:""
    property alias checked: off_on.checked
    //anchors.topMargin: 10
    signal isPressed
    Rectangle {
        id:rect
        height: parent.height
        width: main.width
        anchors.horizontalCenter: parent.horizontalCenter
        color: night_mode? "#00ffee":"#00CCFF"
        opacity: 0
        radius: 10
        Behavior on  opacity{ SpringAnimation { spring: 3; damping: 0.2 } }
    }
    Text{
        id:switchText
        text:switch_text
        font.pixelSize: 16
        anchors.left: parent.left
        //anchors.leftMargin: 10
        height:off_on.height
        verticalAlignment: Text.AlignVCenter
        color: main.night_mode?"#f0f0f0":"#282828"
        opacity: night_mode?brilliance_control:1
    }
    Switch {
        id:off_on
        height: switchText.height
        //platformInverted: main.platformInverted
        anchors.top: switchText.top
        anchors.right: parent.right
        //anchors.rightMargin: 10
        opacity: night_mode?0.95:1
        onClicked:{
            isPressed()
        }
        Keys.onPressed: {
            if(event.key === Qt.Key_Select||event.key === Qt.Key_Enter||event.key === Qt.Key_Return){
                off_on.checked = !off_on.checked
                off_on.clicked()
                privateStyle.play(Symbian.CheckBox)
                event.accepted = true
            }
        }
        onFocusChanged: {
            if(focus)
            {
                rect.opacity=0.8
            }else{
                rect.opacity=0
            }
        }
    }
    onFocusChanged: {
        if(focus)
        {
            settingFlick.contentY=settingFlick.contentY=Math.max(y-setting.height/2,0)
            off_on.forceActiveFocus()
        }
    }
}
