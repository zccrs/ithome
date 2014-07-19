// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
Item{
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
                enabled: input_email.text!=""&input_code.text!=""&input_email_code.text!=""&input_newPassword.text!=""&input_rePassword.text!=""
                text: "确认"
                onClicked: {
                    if( input_newPassword.text === input_rePassword.text )
                        utility.registerUserGeneral("{'strCheckcode':  '"+input_email_code.text+"' , 'password':'"+input_newPassword.text+"'  , 'rpassword':'"+input_rePassword.text+"' }","http://i.ruanmei.com/m/forgetPassword1.aspx/ModifyPassword")
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
        KeyNavigation.up: input_rePassword
        KeyNavigation.tab: input_code
        onActiveFocusChanged: {
            if( !activeFocus&text!="" ){
                utility.registerUserGeneral("{'validate':  '"+input_code.text+"' , 'tbMail':'"+text+"'}", "http://i.ruanmei.com/m/forgetPassword.aspx/btnSubmit_Click" )
            }
        }
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
        KeyNavigation.down: input_email_code
        KeyNavigation.up:input_email
        KeyNavigation.tab: input_email_code
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
    TextField{
        id:input_email_code
        placeholderText: "邮箱验证码"
        anchors.top: input_code.bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_newPassword
        KeyNavigation.up: input_code
        KeyNavigation.tab: input_newPassword
    }
    TextField{
        id:input_newPassword
        placeholderText: "新密码"
        anchors.top: input_email_code.bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_rePassword
        KeyNavigation.up: input_email_code
        KeyNavigation.tab: input_rePassword
    }
    TextField{
        id:input_rePassword
        placeholderText: "确认密码"
        anchors.top: input_newPassword.bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_email
        KeyNavigation.up: input_newPassword
        KeyNavigation.tab: input_email
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
    Connections{
        target: utility
        onGetCodeOk:{
            var re = new RegExp("CheckCode=(\\w+(?=;))")
            var cookie2 = replyData.match(re)

            input_code.text = cookie2[1].toLocaleLowerCase()//toLocaleLowerCase为转化为小写
            code_image.source = utility.cacheImagePrefix+"code.jpg"
        }
        onPasswordEditOk:{
            showBanner(JSON.parse(replyData).d)
        }
    }
}
