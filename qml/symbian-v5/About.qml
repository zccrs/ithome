// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
import QtWebKit 1.0
MyPage{
    property color text_color: night_mode?"#f0f0f0":"#282828"
    property real text_opacity: night_mode?brilliance_control:1
    tools: CustomToolBarLayout{
        id:settingTool
        ToolButton{
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            onClicked: {
                current_page="setting"
                pageStack.pop()
            }
        }
    }
    Image{
        id:header
        opacity: text_opacity
        width: parent.width
        source: "qrc:/Image/PageHeader.svg"
        Text{
            text:"关于"
            font.pixelSize: 22
            color: "white"
            x:10
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    Flickable{
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        clip: true
        width: parent.width

        maximumFlickVelocity: 3000
        pressDelay:200
        flickableDirection:Flickable.VerticalFlick
        contentHeight: myhtml.height
        opacity: text_opacity
        WebView{
            id:myhtml
            width: parent.width
            onWidthChanged: {
                var temp=myhtml.url
                myhtml.url=""
                myhtml.url=temp
            }
            settings.minimumFontSize: content_font_size
            anchors.verticalCenter: parent.verticalCenter
            url:"../general/about.html"
            javaScriptWindowObjects: QtObject {
                WebView.windowObjectName: "qml"
                function openUrl(src){
                    Qt.openUrlExternally(src)
                }
            }
        }
    }
}
