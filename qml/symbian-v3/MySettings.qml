// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
import "../general"
MyPage{
    id:setting

    MyMenu {
        id: mymenu
        MenuLayout {
            MenuItem {
                text: "清理垃圾"
                onClicked: deleteButton.clicked()
            }
            MenuItem {
                text: "关于"
                onClicked: aboutButton.clicked()
            }
            Keys.onPressed: {
                if(event.key == Qt.Key_Context1)
                    mymenu.close()
            }
        }
        onStatusChanged: {
            //utility.consoleLog("SelectionDialog现在的状态是："+status+" "+DialogStatus.Closed)
            if(status===DialogStatus.Closed&setting.status == PageStatus.Actives)
                setting.forceActiveFocus()
        }
    }

    tools: CustomToolBarLayout{
        id:settingTool

        ToolButton{
            id:backButton
            iconSource: night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            opacity: night_mode?brilliance_control:1
            //platformInverted: main.platformInverted
            onClicked: {
                current_page="about"
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
        ToolButton{
            id:deleteButton
            iconSource: night_mode?"toolbar-delete":"qrc:/Image/toolbar-delete_inverse.svg"
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
        ToolButton{
            id:aboutButton

            iconSource: night_mode?"qrc:/Image/about_symbian.svg":"qrc:/Image/about_inverse_symbian.svg"
            onClicked: {
                current_page="about"
                pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }
    }
    Flickable{
        id:settingFlick
        anchors.fill: parent
        contentHeight: 600
        Text{
            id:text1
            text:"版本：1.1.5"
            opacity: night_mode?brilliance_control:1
            color: main.night_mode?"#f0f0f0":"#282828"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 20
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
                //console.log("night_mode:"+checked)
                night_mode=checked
                settings.setValue("night_mode",checked)
            }
            KeyNavigation.up: signature_input
            KeyNavigation.down: show_image_off_on
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
            KeyNavigation.up: night_mode_off_on
            KeyNavigation.down: wifi_load_image
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
            KeyNavigation.up: show_image_off_on
            KeyNavigation.down: fontSize
        }
        CuttingLine{
            id:cut_off
            anchors.top: wifi_load_image.bottom
        }
        MySlider {
            id:fontSize
            anchors.top: cut_off.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            slider_text:"文字大小"
            maximumValue: 22
            minimumValue: 10
            value: settings.getValue("fontSize",18)
            stepSize: 1
            onValueChanged: {
                content_font_size=parseInt(value)
                settings.setValue("fontSize",value)
            }
            KeyNavigation.up: wifi_load_image
            KeyNavigation.down: intensity_control
         }
        MySlider {
            id:intensity_control
            anchors.top: fontSize.bottom
            anchors.topMargin: 20
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
                //console.log(settings.getValue("intensity_control",0.60))
            }
            KeyNavigation.up: fontSize
            KeyNavigation.down: my_phone
        }

        CuttingLine{
            id:cut_off2
            anchors.top: intensity_control.bottom
        }
        Item{
            id:my_phone
            width: parent.width
            height: intensity_control.height
            anchors.top: cut_off2.bottom
            anchors.topMargin:20
            KeyNavigation.up: intensity_control
            KeyNavigation.down: signature_input
            onFocusChanged: {
                if(focus)
                {
                    rect.opacity=0.8
                    settingFlick.contentY=settingFlick.contentY=Math.max(y-setting.height/2,0)
                }else{
                    rect.opacity=0
                }
            }
            Keys.onPressed: {
                if(event.key === Qt.Key_Select||event.key === Qt.Key_Enter||event.key === Qt.Key_Return){
                    phone_list.open()
                    event.accepted = true
                }
            }
            Rectangle {
                id:rect
                anchors.fill: parent
                color: night_mode? "#00ffee":"#00CCFF"
                opacity: 0
                radius: 10
                Behavior on  opacity{ SpringAnimation { spring: 3; damping: 0.2 } }
            }
            Text{
                text:"我的设备"
                font.pixelSize: 16
                anchors.left: parent.left
                anchors.leftMargin:10
                anchors.verticalCenter: parent.verticalCenter
                opacity: night_mode?brilliance_control:1
                color: main.night_mode?"#f0f0f0":"#282828"
            }
            Text{
                id:current_phone
                text:settings.getValue("myphone","Lumia 920")
                anchors.right: parent.right
                font.pixelSize: 16
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                opacity: night_mode?brilliance_control:1
                color: main.night_mode?"#f0f0f0":"#282828"
                SelectionDialog {
                    id: phone_list
                    //platformInverted: main.platformInverted
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

                    onStatusChanged: {
                        //utility.consoleLog("SelectionDialog现在的状态是："+status+" "+DialogStatus.Closed)
                        if(status===DialogStatus.Closed)
                            my_phone.forceActiveFocus()
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
            }
        }




        Text{
            id:my_signature
            text:"我的签名"
            anchors.left: parent.left
            anchors.leftMargin:10
            font.pixelSize: 16
            opacity: night_mode?brilliance_control:1
            color: main.night_mode?"#f0f0f0":"#282828"
            //anchors.horizontalCenter: signature_input.horizontalCenter
            anchors.verticalCenter: signature_input.verticalCenter
        }
        TextField{
            id:signature_input
            //platformInverted: main.platformInverted
            placeholderText: settings.getValue("signature","点击输入小尾巴")
            anchors.left: my_signature.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: my_phone.bottom
            anchors.topMargin:20
            KeyNavigation.up: my_phone
            KeyNavigation.down: night_mode_off_on
            onActiveFocusChanged: {
                if(activeFocus)
                {
                    settingFlick.contentY=Math.max(y-setting.height/2,0)
                }
            }
        }

        Behavior on contentY{
            NumberAnimation{duration: 200}
        }

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
            anchors.topMargin: 20
            text:"缓存大小"
            font.pixelSize: 16
            color: main.night_mode?"#f0f0f0":"#282828"
        }
        Text{
            id:cache
            opacity: night_mode?brilliance_control:1
            anchors.top: remove_cache.top
            anchors.right: parent.right
            anchors.rightMargin: 10
            text:Math.round(100*settings.getValue("cache_size",0)/(1024*1024))/100+"M"
            font.pixelSize: 16
            color: main.night_mode?"#f0f0f0":"#282828"
        }
    }
    Keys.onPressed: {
        utility.consoleLog("设置中按下了按键")
        switch(event.key)
        {
        case Qt.Key_Right:
            settingFlick.contentY=Math.min(settingFlick.contentY+setting.height,settingFlick.contentHeight-setting.height)
            break;
        case Qt.Key_Left:
            settingFlick.contentY=Math.max(settingFlick.contentY-setting.height,0)
            break;
        case Qt.Key_4:
            settingFlick.contentY=Math.min(settingFlick.contentY+setting.height,settingFlick.contentHeight-setting.height)
            break;
        case Qt.Key_1:
            settingFlick.contentY=Math.max(settingFlick.contentY-setting.height,0)
            break;
        case Qt.Key_2:
            settingFlick.contentY=0
            break;
        case Qt.Key_8:
            settingFlick.contentY=settingFlick.contentHeight-settingFlick.height
            break;
        case Qt.Key_Context1:
            backButton.clicked()
            break
        case Qt.Key_Context2:
            mymenu.open()
            break
        default:break;
        }
    }
    onActiveFocusChanged: {
        if(activeFocus)
        {
            utility.consoleLog("设置获得了焦点")
            night_mode_off_on.forceActiveFocus()
        }
    }
    onStatusChanged: {
        if(status===PageStatus.Active)
        {
            labelTxt="设置"
            cache.text=Math.round(100*settings.getValue("cache_size",0)/(1024*1024))/100+"M"
            utility.consoleLog("缓存大小是："+cache.text)
        }
    }
}
