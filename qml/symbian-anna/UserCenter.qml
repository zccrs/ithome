// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import QtWebKit 1.0
import "../general"
MyPage{
    id: user_center_main
    property real text_opacity: night_mode?brilliance_control:1
    property string mode: "个人中心"
    
    tools: CustomToolBarLayout{
        id:userCenterTool
        ToolButton{
            id:backButton
            iconSource: main.night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            opacity: main.night_mode?main.brilliance_control:1
            platformInverted: main.platformInverted
            onClicked: {
                main.current_page="setting"
                pageStack.pop()
            }
        }
        ToolButton{
            id:editInfo
            visible: user_center_main.mode == "个人中心"
            iconSource: {
                if( true_name.mode == "show" ){
                    return main.night_mode?"qrc:/Image/edit2.svg":"qrc:/Image/edit.svg"
                }else{
                    return "toolbar-mediacontrol-play"//main.night_mode?"qrc:/Image/edit2.svg":"qrc:/Image/edit.svg"
                }
            }

            opacity: main.night_mode?main.brilliance_control:1
            platformInverted: main.platformInverted
            onClicked: {
                user_nick.modeSwitch()
                true_name.modeSwitch()
                user_qq.modeSwitch()
                user_phone.modeSwitch()
                user_address.modeSwitch()
            }
        }
        
        ToolButton{
            id:quitLoginButton
            visible: user_center_main.mode == "个人中心"
            iconSource: "toolbar-mediacontrol-stop"
            opacity: main.night_mode?main.brilliance_control:1
            platformInverted: main.platformInverted
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
        user_login.state = "show"
    }
    
    Image{
        id:header
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
    Image{
        id:user_avatar
        cache: false
        visible: user_center_main.mode == "个人中心"
        source: "../general/avatar.jpg"
        anchors.top: header.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        sourceSize.width:80
        Image {
            source: main.night_mode?"qrc:/Image/shade_symbian_inverse.svg":"qrc:/Image/shade_symbian.svg"
            anchors.fill: parent
            smooth: true
        }
    }
    Item{
        id: user_nick
        visible: user_center_main.mode == "个人中心"
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
            platformInverted: main.platformInverted
            anchors.fill: parent
            text: user_nick_show.text
        }
    }

    Text {
        id: level_text
        visible: user_center_main.mode == "个人中心"
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
        visible: user_center_main.mode == "个人中心"
        color: main.night_mode?"#f0f0f0":"#282828"
        opacity: night_mode?brilliance_control:0.6
        text: settings.getValue("LevelState","")
        font.pixelSize: 18
        anchors.left: user_nick.left
        anchors.bottom: user_avatar.bottom
    }
    
    Connections{
        target: cacheContent
        onImageDownloadFinish:{
            user_avatar.source = "../general/avatar.jpg"
        }
    }
    Text {
        id: account_info
        visible: user_center_main.mode == "个人中心"
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
        visible: user_center_main.mode == "个人中心"
        anchors.top: account_info.bottom
    }
    TitleAndTextField{
        id: true_name
        visible: user_center_main.mode == "个人中心"
        anchors.top: cut_off.bottom
        anchors.topMargin: 10
        title: "真实姓名"
        content: settings.getValue("TrueName","")
    }
    TitleAndTextField{
        id: user_qq
        visible: user_center_main.mode == "个人中心"
        anchors.top: true_name.bottom
        anchors.topMargin: 10
        title: "腾讯企鹅"
        content: settings.getValue("UserQQ","")
    }
    TitleAndTextField{
        id: user_phone
        visible: user_center_main.mode == "个人中心"
        anchors.top: user_qq.bottom
        anchors.topMargin: 10
        title: "联系方式"
        content: settings.getValue("UserPhone","")
    }
    TitleAndTextField{
        id: user_address
        visible: user_center_main.mode == "个人中心"
        anchors.top: user_phone.bottom
        anchors.topMargin: 10
        title: "联系地址"
        content: settings.getValue("UserAddress","")
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
                string = temp[0]+"\n"+temp[1]
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
                
                re = new RegExp("数字ID：\\d+")
                var temp2 = string.match(re)
                
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
                true_name.content = string
            }
            function setUserQQ(string)
            {
                utility.consoleLog("QQ是："+string)
                settings.setValue("UserQQ",string)
            }
            function setUserPhone(string)
            {
                utility.consoleLog("联系电话是："+string)
                settings.setValue("UserPhone",string)
            }
            function setUserAddress(string)
            {
                utility.consoleLog("收件地址是："+string)
                settings.setValue("UserAddress",string)
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
                user_login.state = "show"
            }
            
            else
                webview.html = replyData
        }
    }

    LoginPage{
        id: user_login
        height: 494
        onLoginOK: {
            utility.getUserData()
            user_center_main.mode = "个人中心"
        }
    }
    
    Component.onCompleted: {
        var cookie = settings.getValue("userCookie","")
        if( cookie!="" ){
            utility.getUserData()
        }else{
            utility.consoleLog("需要登陆")
            user_center_main.mode = "登陆"
            user_login.state = "show"
        }
    }
}
