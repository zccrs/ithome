// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    height: input.height
    width: parent.width
    property string title: ""
    property string content: ""
    property string mode:"show"
    property int fontSize: 16
    
    function modeSwitch()
    {
        if( mode=="show" )
            mode = "edit"
        else
            mode = "show"
    }
    
    Text{
        id:text
        text: mode == "show"? title!=""?title+"：":"":title
        anchors.left: parent.left
        anchors.leftMargin:10
        font.pixelSize: fontSize
        opacity: night_mode?brilliance_control:1
        color: main.night_mode?"#f0f0f0":"#282828"
        anchors.verticalCenter: input.verticalCenter
    }
    Text {
        id: text_show
        color: main.night_mode?"#f0f0f0":"#282828"
        opacity: night_mode?brilliance_control:1
        text: content
        visible: mode == "show"
        font.pixelSize: fontSize
        anchors.left: text.right
        anchors.leftMargin: 10
        anchors.top: text.top
    }
    TextField{
        id:input
        text: content
        height: 30
        visible: mode == "edit"
        font.pixelSize: fontSize
        anchors.left: text.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
    }
    
    onActiveFocusChanged: {
        if(activeFocus)
            input.forceActiveFocus()
    }
}
