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
    //anchors.topMargin: 10
    Text{
        id:sliderText
        text:slider_text
        font.pixelSize: 22
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
     }
}
