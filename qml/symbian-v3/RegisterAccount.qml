// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
import "../general"
MyPage{
    id: register_account_main
    anchors.fill: parent
    onActiveFocusChanged: {
        utility.consoleLog("注册账号的焦点="+activeFocus)
        if( activeFocus ){
            input_email.forceActiveFocus()
        }
    }
    MyMenu {
        id: menu
        MenuLayout {
            MenuItem {
                enabled: input_email.text!=""&input_code.text!=""
                text: "注册"
                onClicked: {
                    utility.registerUserGeneral( "{email:\""+input_email.text+"\"}" )
                }
            }
            Keys.onPressed: {
                if(event.key == Qt.Key_Context1)
                    menu.close()
            }
        }
        onStatusChanged: {
            if(status===DialogStatus.Closed)
                input_email.forceActiveFocus()
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
        id:input_email
        placeholderText: "邮箱地址"
        anchors.top: ithome_image.bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_code
        KeyNavigation.up: input_code
        KeyNavigation.tab: input_code
    }
    TextField{
        id:input_code
        placeholderText: "验证码"
        font.pixelSize: 16
        height: 30
        anchors.top: input_email.bottom
        anchors.topMargin: 10
        anchors.left: input_email.left
        anchors.right: code_image.left
        anchors.rightMargin: 10
        KeyNavigation.down: input_email
        KeyNavigation.up:input_email
        KeyNavigation.tab: input_email
    }
    Connections{
        target: utility
        onGetCodeOk:{
            var re = new RegExp("CheckCode=(\\w+(?=;))")
            var cookie2 = replyData.match(re)

            input_code.text = cookie2[1].toLocaleLowerCase()//toLocaleLowerCase为转化为小写
            code_image.source = utility.cacheImagePrefix+"code.jpg"
            
            re = new RegExp("ASP.NET_SessionId=\\w+;")
            settings.setValue("CodeCookie", replyData.match(re)+cookie2[0])
        }
        
        onTestEmailOk:{
            var isExist = JSON.parse( replyData )
            if( isExist.d ){
                showBanner("邮箱不可用")
            }else{
                utility.registerUserGeneral( "{user:\""+input_email.text+"\",requestValidate:\""+input_code.text+"\"}",
                                            "http://i.ruanmei.com/reg.aspx/PostRegemail")
            }
        }
        
        onRegisterUserOk:{
            showBanner(JSON.parse(replyData).d)
        }
    }

    Image{
        id:code_image
        width: sourceSize.width
        anchors.right: input_email.right
        anchors.verticalCenter: input_code.verticalCenter
        MouseArea{
            anchors.fill: parent
            onClicked: {
                parent.source=""
                utility.getCode()//获取验证码
            }
        }
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
    onVisibleChanged: {
        if(visible)
            utility.getCode()//获取验证码
    }
}
