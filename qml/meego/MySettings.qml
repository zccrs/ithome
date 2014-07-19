// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.systeminfo 1.2
import com.nokia.extras 1.1
import "../general"
MyPage{
    id:set_page
    clip:true
    tools: ToolBarLayout{
        id:settingTool

        ToolIcon{
            iconId: "toolbar-back"
            opacity: night_mode?brilliance_control:1
            onClicked: {
                current_page="page"
                if(signature_input.text!="")
                {
                    settings.setValue("signature",signature_input.text)
                    signature_input.placeholderText=signature_input.text
                    signature_input.text=""
                }
                pageStack.pop()
                if(loading)
                    main.busyIndicatorShow()//显示缓冲圈圈
            }
        }
        ToolIcon{
            id: userCenter
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/userCenter_meego.png" : "qrc:/Image/userCenter_symbian_inverse.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("UserCenter.qml"))
            }
        }
        ToolIcon{
            id:deleteButton
            iconId: "toolbar-delete"
            opacity: night_mode?brilliance_control:1
            Connections{
                target: cacheContent
                onRemoveResult:{
                    if(result)
                    {
                        cache.text="0M"
                        settings.setValue("cache_size",0)
                        showBanner("呼~~~~~终于清理完了")
                    }else{
                        showBanner("清理失败了，一会再试吧")
                    }
                }
            }
            onClicked: {
                showBanner("请稍后，正在清理")
                cacheContent.clearCache()
            }
        }
        ToolIcon{
            id:aboutButton
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/about_meego.png":"qrc:/Image/about_inverse_meego.png"
            onClicked: {
                current_page="about"
                pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }
    }

    Image{
        id:header
        opacity: night_mode?brilliance_control:1
        width: parent.width
        source: "qrc:/Image/PageHeader.svg"
        Text{
            text:"设置"
            font.pixelSize: 30
            color: "white"
            x:10
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    Flickable{
        id:settingFlick
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        clip: true
        focus:true
        contentHeight: logo.height+text1.height+750
        Image{
            id:logo
            opacity: night_mode?brilliance_control:1
            source: "qrc:/Image/ithome_logo.png"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text{
            id:text1
            text: "版本："+utility.ithomeVersion
            opacity: night_mode?brilliance_control:1
            color: main.night_mode?"#f0f0f0":"#282828"
            font.pixelSize: main.sysIsSymbian?20:22
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.right: parent.right
            anchors.rightMargin: main.sysIsSymbian?10:20
            anchors.top: logo.bottom
            anchors.topMargin: 10
        }

        CuttingLine{
            id:divide1
            anchors.top: text1.bottom
        }
        MySwitch{
            id:night_mode_off_on
            anchors.top: divide1.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            switch_text: "夜间模式"
            checked: settings.getValue("night_mode",false)
            onIsPressed: {
                night_mode=checked
                settings.setValue("night_mode",checked)
            }
            Connections{
                target: main
                onNight_modeChanged:{
                    if(night_mode_off_on.checked!=main.night_mode)
                    {
                        night_mode_off_on.checked=main.night_mode
                    }
                }
            }
        }
        MySwitch{
            id:show_image_off_on
            checked: settings.getValue("show_image_off_on",false)
            anchors.top: night_mode_off_on.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            switch_text: "无图模式"
            onIsPressed: {
                no_show_image=checked
                settings.setValue("show_image_off_on",checked)
            }
        }
        MySwitch{
            id:wifi_load_image
            checked: settings.getValue("wifi_load_image",true)
            anchors.top: show_image_off_on.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            switch_text: "仅WiFi下加载图片"
            onIsPressed: {
                isWifi=checked
                settings.setValue("wifi_load_image",checked)
            }
        }
        MySwitch{
            id:full_screen
            checked: settings.getValue("full_screen",false)
            anchors.top: wifi_load_image.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            switch_text: "滑动时全屏"
            onIsPressed: {
                full=checked
                settings.setValue("full_screen",checked)
            }
        }
        MySwitch{
            id:auto_updata_app
            checked: settings.getValue("auto_updata_app",false)
            anchors.top: full_screen.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            switch_text: "自动检测更新"
            onIsPressed: {
                settings.setValue("auto_updata_app",checked)
            }
            KeyNavigation.up: full_screen
            KeyNavigation.down: screen_orientation
        }
        MySwitch{
            id:screen_orientation
            checked: settings.getValue("screenOrientation",PageOrientation.LockPortrait)==0?true:false
            anchors.top: auto_updata_app.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            switch_text: "自动旋转屏幕"
            onIsPressed: {
                if(checked)
                {
                    screenOrientation=PageOrientation.Automatic
                    settings.setValue("screenOrientation",PageOrientation.Automatic)
                }else{
                    var temp=screen.currentOrientation==Screen.Portrait?PageOrientation.LockPortrait:PageOrientation.LockLandscape
                    screenOrientation=temp
                    settings.setValue("screenOrientation",temp)
                }
            }
        }

        CuttingLine{
            id:cut_off
            anchors.top: screen_orientation.bottom
        }
        MySlider {
            id:fontSize
            anchors.top: cut_off.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            slider_text:"文字大小"
            maximumValue: 32
            minimumValue: 20
            value: settings.getValue("fontSize",22)
            stepSize: 1
            onValueChanged: {
                content_font_size=parseInt(value)
                settings.setValue("fontSize",value)
            }
         }
        MySlider {
            id:intensity_control
            anchors.top: fontSize.bottom
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            slider_text:"夜间亮度"
            maximumValue: 1
            minimumValue: 0.3
            value: settings.getValue("intensity_control",0.60)
            stepSize:0.01
            onValueChanged: {
                brilliance_control=parseFloat(value)
                settings.setValue("intensity_control",value)
            }
        }
        CuttingLine{
            id:cut_off2
            anchors.top: intensity_control.bottom
        }
        /*Text{
            id:my_phone
            text:"我的设备"
            anchors.left: parent.left
            anchors.leftMargin:10
            anchors.top: cut_off2.bottom
            anchors.topMargin:20
            font.pixelSize: 26
            opacity: night_mode?brilliance_control:1
            color: main.night_mode?"#f0f0f0":"#282828"
        }
        Text{
            id:current_phone
            text:settings.getValue("myphone","Lumia 920")
            anchors.right: parent.right
            anchors.rightMargin: 10
            font.pixelSize: 26
            anchors.top: my_phone.top
            opacity: night_mode?brilliance_control:1
            color: main.night_mode?"#f0f0f0":"#282828"
            MouseArea{
                anchors.fill: parent
                onClicked: phone_list.open()
            }

            SelectionDialog {
                id: phone_list
                titleText: "选择要显示的设备称号"
                model: ListModel {
                    ListElement { name: "Nokia N9"}
                    ListElement { name: "Lumia 920" }
                    ListElement { name: "Lumia 1020" }
                    ListElement { name: "Lumia 1520" }
                    ListElement { name: "WP客户端" }
                    ListElement { name: "IOS客户端" }
                    ListElement { name: "Android客户端" }
                }
                function setPhone(phoneModel,osMode,phoneName)
                {
                    current_phone.text=phoneModel
                    settings.setValue("myphone",phoneModel)
                    settings.setValue("client",osMode)
                    settings.setValue("device",phoneName)
                }

                onAccepted: {
                    switch(selectedIndex){
                    case 0:
                        setPhone("Nokia N9","android","Nokia+N9+unknown")
                        break
                    case 1:
                        setPhone("Lumia 920","1","RM-821")
                        break
                    case 2:
                        setPhone("Lumia 1020","1","RM-875")
                        break;
                    case 3:
                        setPhone("Lumia 1520","1","RM-937")
                        break
                    case 4:
                        setPhone("WP客户端","1","")
                        break
                    case 5:
                        setPhone("IOS客户端","3","")
                        break
                    case 6:
                        setPhone("Android客户端","android","")
                        break
                    default:break
                    }
                }
            }
        }*/

        Text{
            id:my_signature
            text:"我的签名"
            font.pixelSize: 26
            anchors.left: parent.left
            anchors.leftMargin:10
            opacity: night_mode?brilliance_control:1
            color: main.night_mode?"#f0f0f0":"#282828"
            //anchors.horizontalCenter: signature_input.horizontalCenter
            anchors.verticalCenter: signature_input.verticalCenter
        }
        TextField{
            id:signature_input
            placeholderText: settings.getValue("signature","点击输入签名")
            anchors.left: my_signature.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: cut_off2.bottom
            anchors.topMargin:20
        }
        /*Text{
            id:my_nickname
            text:"我的昵称"
            anchors.left: parent.left
            anchors.leftMargin:10
            font.pixelSize: 26
            opacity: night_mode?brilliance_control:1
            color: main.night_mode?"#f0f0f0":"#282828"
            anchors.verticalCenter: nickname_input.verticalCenter
        }
        TextField{
            id:nickname_input
            placeholderText: settings.getValue("name","点击输入昵称")
            anchors.left: my_nickname.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: signature_input.bottom
            anchors.topMargin:20
            KeyNavigation.up: signature_input
            KeyNavigation.down: signature_input
        }*/

        //onContentYChanged: console.log("setting page flick ContentY:"+settingFlick.contentY)
        CuttingLine{
            id:cut_off3
            anchors.top: signature_input.bottom
        }
        Text{
            id:remove_cache
            opacity: night_mode?brilliance_control:1
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: cut_off3.bottom
            anchors.topMargin: 10
            text:"缓存大小"
            font.pixelSize: 26
            color: night_mode?"#f0f0f0":"#282828"
        }
        Text{
            id:cache
            opacity: night_mode?brilliance_control:1
            anchors.top: remove_cache.top
            anchors.right: parent.right
            anchors.rightMargin: 10
            text:Math.round(100*settings.getValue("cache_size",0)/(1024*1024))/100+"M"
            font.pixelSize: 26
            color: main.night_mode?"#f0f0f0":"#282828"
        }
        
        HttpRequest{
            id: checkForUpdates_http
            onPostFinish: {
                var ver = JSON.parse( reData )
                if( ver.error == 0 ){
                    if( ver.version != utility.ithomeVersion){
                        utility.setClipboard( ver.url )
                        showBanner("最新版本："+ver.version+"\n下载地址已经复制到剪切板")
                    }else if(!settings.getValue( "auto_updata_app", false )){
                        showBanner("已经是最新版本")
                    }
                }
            }
        }

        Button{
            id: checkForUpdates_button
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: cache.bottom
            anchors.topMargin: 10
            text: "检查更新"
            width: parent.width*0.6
            //height: width
            Component.onCompleted: {
                if( settings.getValue( "auto_updata_app", false ) )
                    checkForUpdates_http.post("GET","http://www.9smart.cn/app/checkversion?appid=5")
            }

            onClicked: {
                checkForUpdates_http.post("GET","http://www.9smart.cn/app/checkversion?appid=5")
            }
        }
    }
    onStatusChanged: {
        if(status===PageStatus.Active)
        {
            cache.text=Math.round(100*settings.getValue("cache_size",0)/(1024*1024))/100+"M"
            utility.consoleLog("缓存大小是："+cache.text)
        }
    }
}
