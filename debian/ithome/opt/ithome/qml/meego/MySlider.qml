// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1
Item {
    width: parent.width
    height: sliderText.height
    property string slider_text:""
    property alias stepSize: sli.stepSize
    property alias minimumValue: sli.minimumValue
    property alias maximumValue: sli.maximumValue
    property alias value: sli.value
    property alias inverted: sli.inverted
    anchors.topMargin: 20
    opacity: night_mode?brilliance_control:1
    Text{
        id:sliderText
        text:slider_text
        font.pixelSize: 26
        anchors.left: parent.left
        //anchors.leftMargin: 10
        verticalAlignment: Text.AlignVCenter
        color: main.night_mode?"#f0f0f0":"#282828"

    }
    Slider {
        id:sli
        anchors.left: sliderText.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        //anchors.rightMargin: 10
        anchors.verticalCenter: sliderText.verticalCenter
        valueIndicatorVisible: true
     }
}
