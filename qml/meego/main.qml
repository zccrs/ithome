// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.systeminfo 1.2
import com.nokia.extras 1.1
PageStackWindow {
    id:main
    property bool night_mode: settings.getValue("night_mode",false)//夜间模式
    property bool no_show_image: settings.getValue("show_image_off_on",false)//无图模式
    property bool isWifi: settings.getValue("wifi_load_image",true)//wifi下显示图片
    property bool full: settings.getValue("full_screen",false)//浏览文章全屏
    property int content_font_size: settings.getValue("fontSize",20)//正文字体大小
    property real brilliance_control: settings.getValue("intensity_control",0.60)//夜间模式亮度
    property string current_page: "page"//当前显示的界面
    property bool online: true//网络连接状态
    property bool sysIsSymbian: false//是不是塞班系统
    property bool sysIsSymbian_v3: false//是不是塞班s60v3系统
    property int wifiStatus: wlaninfo.networkSignalStrength
    property string deviceName: deviceInfo.productName//设备名称，例如n9为RM-696
    property string deviceMode: deviceInfo.model//设备型号，例如n9为n9
    property string deviceManufacturer: deviceInfo.manufacturer//设备厂家，例如n9为Nokia
    property bool loading: false
    property int screenOrientation: settings.getValue("screenOrientation",PageOrientation.LockPortrait)//自动旋转屏幕
    property bool screenIsLandscape: screen.currentOrientation == Screen.Landscape

    onOrientationChangeStarted: {
        utility.consoleLog("屏幕方向变了："+(screen.currentOrientation===Screen.Portrait?height:width))
        if(current_page==="comment")
            setCssToComment()
        else
            setCssToTheme()//如果屏幕方向变了
    }

    onLoadingChanged:{
        indicator.visible=loading
        if(loading)
        {
            netTimer.start()
            //banner.hide()
        }

        else netTimer.stop()
    }
    Timer{
        id:netTimer
        running: false
        interval: 25000
        onTriggered: {
            if(loading===true){
                page.myList.addListViewCount=0
                loading=false
                showBanner("网络忒差了，联网超时了，一会在试试吧")
            }
        }
    }
    
    function setCssToComment()
    {
        if(night_mode){
            utility.setCss("/opt/ithome/qml/meego/comment_black.css",(screen.currentOrientation===Screen.Portrait?height:width)-20)
            theme.inverted=true
        }
        else {
            utility.setCss("/opt/ithome/qml/meego/comment_white.css",(screen.currentOrientation===Screen.Portrait?height:width)-20)
            theme.inverted=false
        }
    }
    function setCssToTheme()
    {
        if(night_mode){
            utility.setCss("/opt/ithome/qml/meego/theme_black.css",(screen.currentOrientation===Screen.Portrait?height:width)-20)
            theme.inverted=true
        }
        else {
            utility.setCss("/opt/ithome/qml/meego/theme_white.css",(screen.currentOrientation===Screen.Portrait?height:width)-20)
            theme.inverted=false
        }
    }

    function showBanner(string)
    {
        banner.text=string
        banner.show()
        //hide_banner.start()
    }
    function busyIndicatorHide()
    {
        indicator.visible=false
    }
    function busyIndicatorShow()
    {
        indicator.visible=true
    }

    InfoBanner{
        y:35
        id: banner
    }
    DeviceInfo{
        id:deviceInfo
        Component.onCompleted: {
            utility.consoleLog("手机型号:"+deviceInfo.model)
            utility.consoleLog("手机名字:"+deviceInfo.productName)
            utility.consoleLog("手机厂商:"+deviceInfo.manufacturer)
        }
    }
    NetworkInfo {
             id: wlaninfo
             mode:NetworkInfo.WlanMode
             monitorModeChanges: true
             monitorStatusChanges: true
             monitorSignalStrengthChanges: true//wifi信号强度
             monitorCurrentMobileNetworkCodeChanges: true
             onModeChanged: console.log("mode"+mode)
             onSignalStrengthChanged: console.log("SignalStrength:"+wlaninfo.networkSignalStrength)
             onNetworkStatusChanged: {
                 console.log("wifi status is:"+wlaninfo.networkStatus)
             }
         }

    onNight_modeChanged: {
        //console.log(night_mode+" "+settings.getValue("night_mode",false))
        setCssToTheme()//刷新css
    }
    Binding {
        target: theme;
        property: "inverted"
        value: night_mode
    }
    initialPage:MainPage{
        id:page
        //height: screen.displayHeight-mainBar.height
    }
    BusyIndicator{
        id: indicator
        running: visible
        platformStyle: BusyIndicatorStyle {
                 period: 800
                 size: "large"
             }
        //onRunningChanged: console.log("mian size:"+main.width+" "+main.height)
        width: 100
        height: 100
        anchors.centerIn: parent
    }
    Image{
        source: "qrc:/Image/01.png"
        anchors.left: parent.left
        anchors.top: parent.top
        z:3
    }
    Image{
        source: "qrc:/Image/02.png"
        anchors.right: parent.right
        anchors.top: parent.top
        z:3
    }
    Image{
        source: "qrc:/Image/03.png"
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        z:3
    }
    Image{
        source: "qrc:/Image/04.png"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        z:3
    }
}
