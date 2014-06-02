// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
import QtMobility.systeminfo 1.1
import com.nokia.extras 1.0
import "../general"
PageStackWindow {
    id:main
    platformSoftwareInputPanelEnabled :true
    property bool night_mode: settings.getValue("night_mode",false)//夜间模式
    property bool no_show_image: settings.getValue("show_image_off_on",false)//无图模式
    property bool isWifi: settings.getValue("wifi_load_image",true)//wifi下显示图片
    property bool full: settings.getValue("full_screen",false)//浏览文章全屏
    property int content_font_size: settings.getValue("fontSize",20)//正文字体大小
    property double brilliance_control: settings.getValue("intensity_control",0.60)//夜间模式亮度
    property string current_page: "page"//当前显示的界面
    property bool online: true//网络连接状态
    property bool sysIsSymbian: true//是不是塞班系统
    property bool sysIsSymbian_v3: false//是不是塞班s60v3系统
    property int wifiStatus: wlaninfo.networkSignalStrength
    property bool loading: false
    property string deviceName: deviceInfo.productName//设备名称，例如n9为RM-696
    property string deviceMode: deviceInfo.model//设备型号，例如n9为n9
    property string deviceManufacturer: deviceInfo.manufacturer//设备厂家，例如n9为Nokia
    property bool screenOrientation: settings.getValue("screenOrientation",PageOrientation.LockPortrait)//自动旋转屏幕

    onOrientationChangeFinished: {
        utility.consoleLog("屏幕方向变了："+width)
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
            banner.close()
        }
        else netTimer.stop()
    }
    function setCssToComment()
    {
        if(night_mode) utility.setCss("./qml/symbian-v5/comment_black.css",width-20)
        else utility.setCss("./qml/symbian-v5/comment_white.css",width-20)
    }
    function setCssToTheme()
    {
        if(night_mode) utility.setCss("./qml/symbian-v5/theme_black.css",width-20)
        else utility.setCss("./qml/symbian-v5/theme_white.css",width-20)
    }
    function showBanner(string)
    {
        banner.text=string
        banner.open()
    }
    function busyIndicatorHide()
    {
        indicator.visible=false
    }
    function busyIndicatorShow()
    {
        indicator.visible=true
    }

    Label {
        text:"IT之家"
        x:10
        font.pixelSize: 18
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
    DeviceInfo{
        id:deviceInfo
    }
    InfoBanner {
         id: banner
         timeout: 2000
         //platformInverted: main.platformInverted
    }
    NetworkInfo {
             id: wlaninfo
             mode:NetworkInfo.WlanMode
    }
    //platformInverted: !night_mode
    onNight_modeChanged: {
        setCssToTheme()
    }
    initialPage:MainPage{
        id:page

    }
    BusyIndicator{
        id: indicator
        running: visible
        //onRunningChanged: console.log("mian size:"+main.width+" "+main.height)
        //platformInverted:main.platformInverted
        width: 50
        height: 50
        anchors.centerIn: parent
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
