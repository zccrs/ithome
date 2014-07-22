// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
import QtWebKit 1.0
import "../general"
MyPage{
    id: user_center_main
    property real text_opacity: night_mode?brilliance_control:1
    property string mode: "个人中心"
    onModeChanged:{
        flick.contentY=0
    }
    tools: CustomToolBarLayout{
        id:userCenterTool
        ToolButton{
            id:backButton
            iconSource: main.night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            opacity: main.night_mode?main.brilliance_control:1
            
            onClicked: {
                if( user_center_main.mode=="修改密码" ){
                    user_center_main.mode="个人中心"
                    flipable_user_center.state = "front"
                }else if( user_center_main.mode=="注册账号"|user_center_main.mode == "找回密码" ){
                    user_center_main.mode = "登陆"
                }else{
                    if( user_true_name.mode == "edit" ){
                        user_nick.modeSwitch()
                        user_true_name.modeSwitch()
                        user_qq.modeSwitch()
                        user_phone.modeSwitch()
                        user_address.modeSwitch()
                    }else{
                        main.current_page="setting"
                        pageStack.pop()
                    }
                }
            }
        }
        ToolButton{
            id:editInfo
            visible: user_center_main.mode == "个人中心"
            iconSource: {
                if( user_true_name.mode == "show" ){
                    return main.night_mode?"qrc:/Image/edit2.svg":"qrc:/Image/edit.svg"
                }else{
                    return main.night_mode?"qrc:/Image/save_symbian.svg":"qrc:/Image/save_inverse_symbian.svg"
                }
            }

            opacity: main.night_mode?main.brilliance_control:1
            
            onClicked: {
                if( user_true_name.mode == "edit" ){
                    var data = "__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=%2FwEPDwUKMTQ1Mzg5Nzc2MQ9kFgJmD2QWAgIBD2QWAgICD2QWAgIIDxYCHglpbm5lcmh0bWxlZGReoQH7UiHT2P2nqMisiej3f96AuKLPfz9EBEKE%2B2QqLw%3D%3D&__EVENTVALIDATION=%2FwEdAAhT5F4vm7P3tNcHedxJSjaMetmnXCW78O8MOJUYt92SyUcghoZlg4McPsTc5dJh%2Ff%2BBeqgcP63cVNe6lUeEH7C5fbO357WlOQ3%2B%2BBTljekIycm4Dg4her8nMjNi%2FZ4apy1Dal2hKqI4Cqrg8JhZwKxbvTZ68U7SSOrbXpD7C2zYuiSMw80XjnKN3CenaR5UWip1az5NpYFyCEQvUqqmVU9H&"+
                            "ctl00$MainContent$txtUserNick="+user_nick_input.text+
                            "&ctl00$MainContent$txtTruename="+user_true_name.content+
                            "&ctl00$MainContent$txtQQ="+user_qq.content+
                            "&ctl00$MainContent$txtPhone="+user_phone.content+
                            "&ctl00$MainContent$txtAddress="+user_address.content+
                            "&ctl00$MainContent$btnSave1=保存修改";
                    utility.setUserData( data )//设置用户资料
                }
                user_nick.modeSwitch()
                user_true_name.modeSwitch()
                user_qq.modeSwitch()
                user_phone.modeSwitch()
                user_address.modeSwitch()
            }
        }
        
        ToolButton{
            id:quitLoginButton
            visible: user_center_main.mode == "个人中心"
            iconSource: main.night_mode?"qrc:/Image/quitLogin_symbian.svg":"qrc:/Image/quitLogin_inverse_symbian.svg"
            opacity: main.night_mode?main.brilliance_control:1
            
            onClicked: {
                quitLogin()
            }
        }
    }
    
    function quitLogin()
    {
        utility.consoleLog("调用了退出登陆")
        settings.setValue("userCookie","")
        user_center_main.mode = "登陆"
    }
    
    Image{
        id:header
        z:1
        opacity: text_opacity
        width: parent.width
        source: "qrc:/Image/PageHeader.svg"
        Text{
            text:user_center_main.mode
            font.pixelSize: 22
            color: "white"
            x:10
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    
    WebView{
        id:webview
        visible: false
        javaScriptWindowObjects: QtObject {
            WebView.windowObjectName: "qml"
            function setAvatarSrc(src)
            {
                cacheContent.imageDownload("avatar",src,"avatar",".jpg")
            }
            function setLevelState(string)
            {
                var temp = string.split( "<br>" )
                string = temp[0]+"  "+temp[1]
                utility.consoleLog("升级状态是："+string)
                settings.setValue("LevelState",string)
                level_state.text=string
            }
            function setDayState(string)
            {
                utility.consoleLog("今日加速状态是："+string)
                settings.setValue("DayState",string)
            }
            function setAccountInfo(string)
            {
                var re = new RegExp("\\w+@\\S+")
                var temp1 = string.match(re)
                
                re = new RegExp("数字ID：(\\d+)")
                re = string.match(re)[1]
                settings.setValue("UserID", re)//记录用户数字ID
                var temp2 = "数字ID："+re
                
                string = temp1+"\n"+temp2
                settings.setValue("AccountInfo",string)
                account_info.text = "账    号："+string
            }
            function setUserNick(string)
            {
                utility.consoleLog("用户昵称是："+string)
                settings.setValue("UserNick",string)
                user_nick.text = string
            }
            function setTrueName(string)
            {
                utility.consoleLog("真实姓名是："+string)
                settings.setValue("TrueName",string)
                user_true_name.content = string
            }
            function setUserQQ(string)
            {
                utility.consoleLog("QQ是："+string)
                settings.setValue("UserQQ",string)
                user_qq.content = string
            }
            function setUserPhone(string)
            {
                utility.consoleLog("联系电话是："+string)
                settings.setValue("UserPhone",string)
                user_phone.content = string
            }
            function setUserAddress(string)
            {
                utility.consoleLog("收件地址是："+string)
                settings.setValue("UserAddress",string)
                user_address.content = string
            }
            function setUserLevel(number)
            {
                utility.consoleLog("用户等级是："+number)
                settings.setValue("UserLevel",number)
                level_text.text = "LV"+number
            }
        }
        
        onLoadFinished: {
            evaluateJavaScript(
                        'window.qml.setAvatarSrc($(".face img:first").attr("src"));'+
                        'window.qml.setLevelState($(".level_state").html());'+
                        'window.qml.setDayState($(".oth_info").text());'+
                        'window.qml.setAccountInfo($(".t_name:eq(0)").text()+$(".t_con:eq(0)").text());'+
                        'window.qml.setUserNick($("#MainContent_txtUserNick").val());'+
                        'window.qml.setTrueName($("#MainContent_txtTruename").val());'+
                        'window.qml.setUserQQ($("#MainContent_txtQQ").val());'+
                        'window.qml.setUserPhone($("#MainContent_txtPhone").val());'+
                        'window.qml.setUserAddress($("#MainContent_txtAddress").val());'+
                        'window.qml.setUserLevel($(".lv_numb").text());'
                        )
        }
        onAlert: {
            utility.consoleLog(message)
        }
    }
    
    Connections{
        target: utility
        onGetUserDataOk:{
            if(replyData.indexOf("<head><title>Object moved</title></head>")>=0){
                user_center_main.mode = "登陆"
            }
            
            else
                webview.html = replyData
        }
        onSetUserDataOk:{
            showBanner(replyData)
        }
    }
    
    Item{
        id: user_center_page
        anchors.fill: parent
        
        Image{
            id:user_avatar
            source: "../general/avatar.jpg"
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            sourceSize.width:80
            Image {
                source: main.night_mode?"qrc:/Image/shade_inverse_symbian.svg":"qrc:/Image/shade_symbian.svg"
                anchors.fill: parent
                smooth: true
            }
        }
        Item{
            id: user_nick
            anchors.top: user_avatar.top
            anchors.left: user_avatar.right
            anchors.leftMargin: 10
            width: user_nick_show.width
            height: user_nick_show.height
            property string mode:"show"
            property alias text: user_nick_show.text
            function modeSwitch()
            {
                if( mode=="show" )
                    mode = "edit"
                else
                    mode = "show"
            }
            Text {
                id:user_nick_show
                visible: user_nick.mode == "show"
                color: main.night_mode?"#f0f0f0":"#282828"
                opacity: night_mode?brilliance_control:1
                text: settings.getValue("UserNick","")
                font.pixelSize: 26
            }
            TextField{
                id:user_nick_input
                visible: user_nick.mode == "edit"
                font.pixelSize: 18
                
                anchors.fill: parent
                text: user_nick_show.text
            }
        }
    
        Text {
            id: level_text
            color: main.night_mode?"#f0f0f0":"#000000"
            opacity: night_mode?brilliance_control:1
            text: "LV"+settings.getValue("UserLevel",0)
            font.pixelSize: 20
            anchors.left: user_nick.right
            anchors.leftMargin: 10
            anchors.bottom: user_nick.bottom
        }
        Text {
            id: level_state
            color: main.night_mode?"#f0f0f0":"#282828"
            opacity: night_mode?brilliance_control:0.6
            text: settings.getValue("LevelState","")
            font.pointSize: 5
            anchors.left: user_nick.left
            anchors.bottom: user_avatar.bottom
        }
        
        Connections{
            target: cacheContent
            onImageDownloadFinish:{
                user_avatar.source=""
                user_avatar.source = "../general/avatar.jpg"
            }
        }
        Text {
            id: account_info
            color: main.night_mode?"#f0f0f0":"#282828"
            opacity: night_mode?brilliance_control:0.6
            anchors.left: user_avatar.left
            anchors.top: user_avatar.bottom
            anchors.topMargin: 10
            font.pixelSize: 18
            text: "账    号："+settings.getValue("AccountInfo","")
        }
        
        CuttingLine{
            id:cut_off
            anchors.top: account_info.bottom
        }
        TitleAndTextField{
            id: user_true_name
            anchors.top: cut_off.bottom
            anchors.topMargin: 10
            title: "真实姓名"
            content: settings.getValue("TrueName","")
        }
        TitleAndTextField{
            id: user_qq
            anchors.top: user_true_name.bottom
            anchors.topMargin: 10
            title: "腾讯企鹅"
            content: settings.getValue("UserQQ","")
        }
        TitleAndTextField{
            id: user_phone
            anchors.top: user_qq.bottom
            anchors.topMargin: 10
            title: "联系方式"
            content: settings.getValue("UserPhone","")
        }
        TitleAndTextField{
            id: user_address
            anchors.top: user_phone.bottom
            anchors.topMargin: 10
            title: "联系地址"
            content: settings.getValue("UserAddress","")
        }
        Text {
            text: "修改密码"
            font.underline: true
            color: "blue"
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    flipable_user_center.state = "back"
                    user_center_main.mode = "修改密码"
                }
                onPressed: parent.color = "red"
                onReleased: parent.color = "blue"
            }
        }
    }
    
    Flickable{
        id:flick
        anchors.top: header.bottom
        width: parent.width
        height: parent.height-header.height-tools.height
        contentHeight: 494
        Flipable {
             id: flipable_user_center
             anchors.fill: parent
             property bool flipped: false
             visible: user_center_main.mode == "个人中心"|user_center_main.mode == "修改密码"
             front: user_center_page

             state:"front"
             back: SetUserPassword{}

             transform: Rotation {
                 id: rotation
                 origin.x: flipable_user_center.width/2
                 origin.y: flipable_user_center.height/2
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

        LoginPage{
            id: user_login
            onLoginOK: {
                utility.getUserData()
                user_center_main.mode = "个人中心"
            }
        }
    }
    
    Component.onCompleted: {
        var cookie = settings.getValue("userCookie","")
        if( cookie!="" ){
            utility.getUserData()
        }else{
            utility.consoleLog("需要登陆")
            user_center_main.mode = "登陆"
        }
    }
}
