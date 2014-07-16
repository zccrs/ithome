// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
Item{
    id: login_mian
    width: parent.width
    signal loginOK
    state: "hide"

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
                target: login_mian
                y: header.height
                opacity: 1
            }
        },
        State {
            name: "hide"
            PropertyChanges {
                target: login_mian
                y:main.height
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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
        }
        
        TextField{
            id:input_email
            placeholderText: "邮箱地址"
            anchors.top: ithome_image.bottom
            anchors.topMargin: 20
            platformInverted: main.platformInverted
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width*0.8
            KeyNavigation.down: input_password
            KeyNavigation.up: input_password
            KeyNavigation.tab: input_password
        }
        TextField{
            id:input_password
            placeholderText: "密码"
            platformInverted: main.platformInverted
            anchors.top: input_email.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width*0.8
            KeyNavigation.down: input_email
            KeyNavigation.up:input_email
            KeyNavigation.tab: input_email
            echoMode: TextInput.Password
        }
        
        Row{
            id: radio_row
            anchors.top: input_password.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
        
            RadioButton{
                id: sava_password_radio
                platformInverted: main.platformInverted
                text: "记住密码"
                checked: settings.getValue( "SavePasswordChecked", false )
                onCheckedChanged: {
                    settings.setValue( "SavePasswordChecked", checked )
                }
            }
            RadioButton{
                platformInverted: main.platformInverted
                text: "显示密码"
                checked: settings.getValue( "ShowPasswordChecked", false )
                onCheckedChanged: {
                    settings.setValue( "ShowPasswordChecked", checked )
                    if( checked )
                        input_password.echoMode = TextInput.Normal 
                    else
                        input_password.echoMode = TextInput.Password
                }
            }
        }
    
        Button{
            id: login_button
            enabled: input_email.text!=""&input_password.text!=""
            text: "登        陆"
            font.pixelSize: 18
            anchors.top: radio_row.bottom
            anchors.topMargin: 20
            
            width: parent.width*0.6
            platformInverted: main.platformInverted
            anchors.horizontalCenter: parent.horizontalCenter
            
            onClicked: {
                if( sava_password_radio.checked )
                    settings.setValue( "UserPassword", input_password.text )
                else
                    settings.setValue( "UserPassword", "" )
                settings.setValue( "UserEmail", input_email.text )
                utility.login( input_email.text, input_password.text )
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
                    login_mian.state = "hide"
                    emit_signal.start()
                }else
                    showBanner("登陆失败")
            }
        }
        Column{
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            spacing: 10
            Text {
                text: "注册账号"
                font.underline: true
                color: "blue"
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        user_center_main.mode = parent.text
                    }
                    onPressed: parent.color = "red"
                    onReleased: parent.color = "blue"
                }
            }
            Text {
                text: "找回密码"
                font.underline: true
                color: "blue"
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        user_center_main.mode = parent.text
                    }
                    onPressed: parent.color = "red"
                    onReleased: parent.color = "blue"
                }
            }
        }
    }
    RegisterAccount{
        id: register_account_page
        visible: user_center_main.mode == "注册账号"
        onVisibleChanged: {
            if( visible ){
                flipable.back = register_account_page
                flipable.state = "back"
            }else{
                flipable.state = "front"
            }
        }
    }//注册账号
    RetrievePassword{
        id: retrieve_password_page
        visible: user_center_main.mode == "找回密码"
        onVisibleChanged: {
            if( visible ){
                flipable.back = retrieve_password_page
                flipable.state = "back"
            }else{
                flipable.state = "front"
            }
        }
    }//找回密码
    

    Flipable {
         id: flipable
         anchors.fill: parent
         property bool flipped: false
    
         front: login_page
         state:"front"

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
    
    Component.onCompleted: {
        input_email.text = settings.getValue("UserEmail","")
        input_password.text = settings.getValue("UserPassword","")
    }
}
