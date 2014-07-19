// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
import Qt.labs.components 1.0 as QtComponents
Item {
    width: parent.width
    height: sliderText.height+20
    //color: night_mode?"#3c3c3c":"#e0e0e0"
    property string slider_text:""
    property alias stepSize: sli.stepSize
    property alias minimumValue: sli.minimumValue
    property alias maximumValue: sli.maximumValue
    property alias value: sli.value
    property alias inverted: sli.inverted
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
        id:sliderText
        text:slider_text
        font.pixelSize: 16
        anchors.left: parent.left
        //anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        color: main.night_mode?"#f0f0f0":"#282828"
        opacity: night_mode?brilliance_control:1
    }
    RewriteSlider {
        id:sli
        //platformInverted: main.platformInverted
        anchors.left: sliderText.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        //anchors.rightMargin: 10
        anchors.verticalCenter: sliderText.verticalCenter
        valueIndicatorVisible: true
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
            sli.forceActiveFocus()
            settingFlick.contentY=settingFlick.contentY=Math.max(y-setting.height/2,0)
        }
    }
}
