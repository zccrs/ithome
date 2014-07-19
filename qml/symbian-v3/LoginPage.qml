// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
Item{
    id: login_main
    signal loginOK
    state: "hide"
    property alias menu: menu
    width: parent.width
    height: parent.height
    
    onStateChanged: {
        if( state=="show" ){
            input_email.forceActiveFocus()
        }
    }
    onActiveFocusChanged: {
        utility.consoleLog("登陆界面的焦点="+activeFocus)
        if( activeFocus )
            input_email.forceActiveFocus()
    }
    
    MyMenu {
        id: menu
        MenuLayout {
            MenuItem {
                text: "登陆"
                enabled: input_email.text!=""&input_password.text!=""
                onClicked: {
                    if( sava_password_radio.checked )
                        settings.setValue( "UserPassword", input_password.text )
                    else
                        settings.setValue( "UserPassword", "" )
                    settings.setValue( "UserEmail", input_email.text )
                    utility.login( input_email.text, input_password.text )
                }
            }

            MenuItem {
                text: "注册账号"
                onClicked: {
                    user_center_main.mode = "注册账号"
                    flipable.state = "back"
                    register_account_page.forceActiveFocus()
                }
            }
            MenuItem {
                text: "找回密码"
                onClicked: {
                    user_center_main.mode = "找回密码"
                    flipable.state = "back"
                    retrieve_password_page.forceActiveFocus()
                }
            }
            Keys.onPressed: {
                if(event.key == Qt.Key_Context1)
                    menu.close()
            }
        }
        onStatusChanged: {
            if(status===DialogStatus.Closed)
                if(user_center_main.mode=="登陆")
                    input_email.forceActiveFocus()
        }
    }
    
    Connections{
        target: user_center_main
        onModeChanged:{
            if( user_center_main.mode=="登陆" ){
                login_main.state = "show"
                flipable.state = "front"
            }
        }
    }
    
    transitions: [
        Transition {
            from: "show"
            to: "hide"
            reversible: true
            PropertyAnimation{
                duration: 300
                properties: "y"
                
            }
            PropertyAnimation{
                duration: 300
                properties: "opacity"
            }
        }
    ]
    states: [
        
        State {
            name: "show"
            PropertyChanges {
                target: login_main
                y: 0
                opacity: 1
            }
        },
        State {
            name: "hide"
            PropertyChanges {
                target: login_main
                y:360
                opacity: 0
            }
        }
    ]
    
    Item{
        id: login_page
        anchors.fill: parent
        visible: user_center_main.mode == "登陆"
        Image{
            id: ithome_image
            source: "qrc:/Image/ithome.svg"
            sourceSize.width: 60
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
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
            KeyNavigation.down: input_password
            KeyNavigation.up: input_password
            KeyNavigation.tab: input_password
        }
        TextField{
            id:input_password
            placeholderText: "密码"
            font.pixelSize: 16
            height: 30
            anchors.top: input_email.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width*0.8
            KeyNavigation.down: sava_password_radio
            KeyNavigation.up:input_email
            KeyNavigation.tab: sava_password_radio
            echoMode: TextInput.Password
        }
        
        Row{
            id: radio_row
            anchors.top: input_password.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
        
            MyRadioButton{
                id: sava_password_radio
                
                text: "记住密码"
                checked: settings.getValue( "SavePasswordChecked", false )
                onCheckedChanged: {
                    settings.setValue( "SavePasswordChecked", checked )
                }
                KeyNavigation.down: show_password_radio
                KeyNavigation.up:input_password
                KeyNavigation.tab: show_password_radio
            }
            MyRadioButton{
                id: show_password_radio
                text: "显示密码"
                
                checked: settings.getValue( "ShowPasswordChecked", false )
                onCheckedChanged: {
                    settings.setValue( "ShowPasswordChecked", checked )
                    if( checked )
                        input_password.echoMode = TextInput.Normal 
                    else
                        input_password.echoMode = TextInput.Password
                }
                KeyNavigation.down: input_email
                KeyNavigation.up:sava_password_radio
                KeyNavigation.tab: input_email
            }
        }
    
        Timer{
            id: emit_signal
            interval: 300
            onTriggered: loginOK()//发送登陆成功的信号
        }
    
        Connections{
            target: utility
            onLoginOk:{
                var d=JSON.parse(replyData)
                d = d.d.split(":")
                if(d[0]==="ok"){
                    var re = new RegExp("ASP.NET_SessionId=\\w+;")
                    var userCookie = replyCookie.match(re)
                    re = new RegExp("user=username=\\S+(?=;)")
                    userCookie += replyCookie.match(re)
                    console.log( "userCookie:"+userCookie )
                    settings.setValue("userCookie", userCookie)
                    showBanner("登陆成功")
                    login_main.state = "hide"
                    emit_signal.start()
                }else
                    showBanner("登陆失败")
            }
        }
    }

    Flipable {
         id: flipable
         anchors.fill: parent
         
         front: login_page
         state:"front"
         
         back:Item {
             anchors.fill: parent
             RegisterAccount{
                 id: register_account_page
                 visible: user_center_main.mode == "注册账号"
             }
             RetrievePassword{
                 id: retrieve_password_page
                 visible: user_center_main.mode == "找回密码"
             }//找回密码
         }
         
         transform: Rotation {
             id: rotation
             origin.x: flipable.width/2
             origin.y: flipable.height/2
             axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
             angle: 0    // the default angle
         }
    
         states: [
             State {
                 name: "back"
                 PropertyChanges { target: rotation; angle: 180 }
             },
             State {
                 name: "front"
                 PropertyChanges { target: rotation; angle: 0 }
             }
         ]    
         transitions: Transition {
             NumberAnimation { target: rotation; property: "angle"; duration: 300 }
         }
    }
    Keys.onPressed: {
        utility.consoleLog("登陆中按下了按键")
        switch(event.key)
        {
        case Qt.Key_Context1:
            userCenter_backButton.clicked()
            break
        case Qt.Key_Context2:
            menu.open()
            break
        default:break;
        }
        event.accepted = true;
    }
    Component.onCompleted: {
        input_email.text = settings.getValue("UserEmail","")
        if( settings.getValue( "SavePasswordChecked", false ) )
            input_password.text = settings.getValue("UserPassword","")
    }
}
