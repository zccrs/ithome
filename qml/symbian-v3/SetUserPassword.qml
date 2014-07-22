// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0

Item{
    id: setpassword_main
    anchors.fill: parent
    onActiveFocusChanged: {
        if( activeFocus ){
            input_oldpassword.forceActiveFocus()
        }
    }
    MyMenu {
        id: menu
        MenuLayout {
            MenuItem {
                enabled: input_oldpassword.text!=""&input_newpassword.text!=""&input_re_newpassword.text!=""
                text: "确认"
                onClicked: {
                    var url = "http://i.ruanmei.com/PostModifyUserInfo.aspx"
                    var data = 
                            "nickName="+settings.getValue("UserNick","")+
                            "&oldpwd="+input_oldpassword.text+
                            "&newpwd="+input_newpassword.text+
                            "&newpwd2="+input_re_newpassword.text+
                            "&type=modify";
                    if( input_newpassword.text==input_re_newpassword.text )
                        utility.setUserData( data,url )
                    else
                        showBanner("两次输入新密码不一致")
                }
            }
            Keys.onPressed: {
                if(event.key == Qt.Key_Context1)
                    menu.close()
            }
        }

        onStatusChanged: {
            utility.consoleLog("修改密码的菜单的状态="+status+","+DialogStatus.Open)
            if(status==DialogStatus.Closed)
                input_oldpassword.forceActiveFocus()
        }
    }
    Image{
        id: ithome_image
        source: "qrc:/Image/ithome.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        sourceSize.width:60
    }
    TextField{
        id:input_oldpassword
        placeholderText: "旧密码"
        anchors.top: ithome_image.bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_newpassword
        KeyNavigation.up: input_re_newpassword
        KeyNavigation.tab: input_newpassword
    }
    TextField{
        id:input_newpassword
        placeholderText: "新密码"
        anchors.top: input_oldpassword.bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_re_newpassword
        KeyNavigation.up: input_oldpassword
        KeyNavigation.tab: input_re_newpassword
    }
    TextField{
        id:input_re_newpassword
        placeholderText: "重复新密码"
        anchors.top: input_newpassword.bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_oldpassword
        KeyNavigation.up: input_newpassword
        KeyNavigation.tab: input_oldpassword
    }
    Keys.onPressed: {
        switch(event.key)
        {
        case Qt.Key_Context1:
            if( menu.status==DialogStatus.Open )
                menu.close()
            else
                userCenter_backButton.clicked()
            break
        case Qt.Key_Context2:
            menu.open()
            break
        default:break;
        }
        event.accepted = true;
    }
}
