import QtQuick 1.1
import com.nokia.meego 1.1
MyPage{
    property bool inputFocus: true
    function close()
    {
        if(online){
            if(textfield.text!=""){
                Qt.openUrlExternally("https://www.google.com.hk/search?q=www.ithome.com"+textfield.text)
                textfield.focus=false
                textfield.text=""
                textfield.platformCloseSoftwareInputPanel()
            }
        }else{
            showBanner("亲，还没联网呢")
        }
    }

    TextField{
        id:textfield
        platformStyle: TextFieldStyle{
            paddingLeft: searchIcon.width
            paddingRight: clearButton.width
        }

        placeholderText: "请输入搜索内容"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20


        Image {
            id: searchIcon;
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; }
            source: "image://theme/icon-m-common-search";
        }

        Item {
            id: clearButton;
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
            height: clearButtonImage.height;
            width: clearButtonImage.width;
            opacity: textfield.activeFocus ? 1 : 0;
            Behavior on opacity {
                NumberAnimation { duration: 100; }
            }
            Image {
                id: clearButtonImage;
                source: "image://theme/icon-m-input-clear";
            }
            MouseArea {
                id: clearMouseArea;
                anchors.fill: parent;
                onClicked: {
                    textfield.focus=false
                    textfield.text=""
                    textfield.platformCloseSoftwareInputPanel();
                }
            }
        }
    }

    ToolButton{
        id:button1
        text:"返回"
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        onClicked: {
            current_page="page"
            textfield.focus=false
            textfield.platformCloseSoftwareInputPanel()
            textfield.text=""
            pageStack.pop()
            if(loading)
                main.busyIndicatorShow()//显示缓冲圈圈
        }
    }
    ToolButton{
        text:"搜索"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        onClicked: {
            close()
        }
    }
    Keys.onEnterPressed: {
        close()
    }
    Keys.onPressed: {
        if(event.key===16777220)
        {
            if(textfield.activeFocus){
                close()
            }else textfield.forceActiveFocus()
        }
        //console.log(event.key)
    }
}
//
