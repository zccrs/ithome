// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
//import XmlListModel 1.0
import "post_http.js" as PostHttp
Item {//
    id:mainlist
    anchors.fill: parent
    property alias myView: listview
    property int maxnewsidData: 0
    property int minnewsidData: 99999999
    property bool isOneStart: true
    property double showImage: night_mode?settings.getValue("intensity_control",0.60):1
    property string url:" "
    property string zone: "news"//记录当前在哪个专区
    property string zone_chinese: stateText.text//记录当前在哪个专区的中文
    property string doubleDayRank:"/rss/channel48rank/item"//排行榜中两天内最热门
    property string weekRank:"/rss/channelweekhotrank/item"//排行榜中一周内最热门
    property string weekCommentRank:"/rss/channelweekcommentrank/item"//排行榜中两周内最热门
    property string monthRank:"/rss/channelmonthrank/item"//排行榜中一月内最热门
    property string ranktype: doubleDayRank
    property int addListViewCount: 0//记录新增列表视图的数量

    signal buttonPress(int keysid);
    onButtonPress: {
        if(keysid===Qt.Key_Space)
        {
            open_selection_list()//打开界面选择框
        }
    }

    Connections{
        target: main
        onLoadingChanged:{
            if(!loading&addListViewCount>0)
            {
                //utility.consoleLog("新增")
                showBanner("获取了"+addListViewCount+"条新闻")
                addListViewCount=0
            }
        }
    }

    function headerHide(){//隐藏header
        page.pushContent()
    }

    function updataSlide()//刷新大海报
    {
        if( listmodel.count>0 )
            listmodel.remove(0)
        listmodel.insert(0, {"title":"",
                             "m_url":"",
                             "image":"",
                             "description":"",
                             "detail":"",
                             "newsid":"",
                             "hitcount":"",
                             "commentcount":"",
                             "postdate":"",
                             "newssource":"",
                             "newsauthor":"",
                             "isHighlight":false,
                             "m_text":"",
                             "zone":"zone", "loaderSource": "SlideNewsView.qml"
                         })
        utility.consoleLog("刷新大海报")
    }
    
    function postOk(maxsid)
    {
        utility.consoleLog("最新新闻ID："+maxsid)
        if(maxsid>maxnewsidData)
        {
            if(maxsid-maxnewsidData>19)
            {
                addListViewCount=20
                isOneStart=true
                maxnewsidData=0
                minnewsidData=99999999
                listmodel.clear()
                xmlModel.beginPost("http://www.ithome.com/rss/news.xml",zone)//获取最新资讯
            }
            else{
                addListViewCount=maxsid-maxnewsidData
                for(var i=maxnewsidData+1;i<=maxsid;++i){
                    utility.inQueue(i)
                }
                addonemodel.addone(0,"news")//一个一个的增加新闻
            }
        }else{
            loading=false
        }
    }
    function reModel(){
        if(loading) return
        switch (zone)
        {
        case "news":
            loading=true
            PostHttp.postBegin(mainlist,"GET","http://www.ithome.com/rss/maxnewsid.xml","")
            break
        case "rank":
            zone=""
            addRankZone()
            break
        case "wp":
            zone=""
            addWPZone()
            break
        case "windows":
            zone=""
            addWindowsZone()
            break
        case "ios":
            zone=""
            addIOSZone()
            break
        case "android":
            zone=""
            addAndroidZone()
            break
        case "phone":
            zone=""
            addPhoneZone()
            break
        case "digi":
            zone=""
            addDigiZone()
            break
        default:break
        }
    }

    function postNewModel(key)
    {
        listmodel.clear()
        isOneStart=true
        maxnewsidData=0
        minnewsidData=99999999
        xmlModel.beginPost("http://www.ithome.com/rss/"+zone+".xml",key)
    }
    function addFavoriteZone()
    {
        if(zone!="favorite"){
            if(utility.getFavoriteIsNull())
            {
                showBanner("收藏夹是空的")
                return;//如果收藏夹为空
            }
            zone="favorite"
            stateText.text="收藏夹"
            listmodel.clear()
            isOneStart=true
            maxnewsidData=0
            minnewsidData=99999999
            var favoritePath=sysIsSymbian?("D:/ithome/like.xml"):"/home/user/.ithome/like.xml"
            xmlModel.beginPost(favoritePath,zone)
        }
    }

    function addNewsZone(){
        if(zone!="news"){
            zone="news"
            stateText.text="最新资讯"
            postNewModel(zone)
        }
    }
    function addRankZone(){
        if(zone!="rank"){
            zone="rank"
            stateText.text="排行榜"
            isOneStart=true
            maxnewsidData=0
            minnewsidData=99999999
            listmodel.clear()
            //console.log("cleraing... list count:"+listview.count)
            ranktype=weekRank
            rankmodel.addRank("双日榜",doubleDayRank)
        }
    }
    function addWPZone(){
        if(zone!="wp"){
            zone="wp"
            stateText.text="WP专区"
            postNewModel(zone)
        }
    }
    function addWindowsZone(){
        if(zone!="windows"){
            zone="windows"
            stateText.text="Windows专区"
            postNewModel(zone)
        }
    }
    function addIOSZone(){
        if(zone!="ios"){
            zone="ios"
            stateText.text="IOS专区"
            postNewModel(zone)
        }
    }
    function addAndroidZone(){
        if(zone!="android"){
            zone="android"
            stateText.text="Android专区"
            postNewModel(zone)
        }
    }
    function addPhoneZone(){
        if(zone!="phone"){
            zone="phone"
            stateText.text="手机"
            postNewModel(zone)
        }
    }
    function addDigiZone(){
        if(zone!="digi"){
            zone="digi"
            stateText.text="数码"
            postNewModel(zone)
        }
    }

    Image{
        id:pageheader
        visible: !sysIsSymbian_v3//如果是s60v3就隐藏
        source: sysIsSymbian_v3?"":"qrc:/Image/PageHeader.svg"
        width: parent.width
        opacity: night_mode?brilliance_control:1
        Text{
            id:stateText
            text:"最新资讯"
            font.pixelSize: sysIsSymbian?22:30
            color: "white"
            x:10
            anchors.verticalCenter: parent.verticalCenter
        }
        Image{
            source: "qrc:/Image/ist_indicator.svg"
            x:parent.width-width-10
            anchors.verticalCenter: parent.verticalCenter
            z:1
        }
        MouseArea{
            id:headerButton
            anchors.fill: parent
            onClicked: {
                open_selection_list()
            }
        }
        Behavior on y{
            NumberAnimation{duration: 100}
        }
    }

    ListModel{
        id:listmodel
    }

    NewXmlModel{
        id:xmlModel
    }

    RankModel{
        id:rankmodel
    }
    AddOneModel{//用了加载单个新闻
        id:addonemodel
        onClose: {
            loading=false//取消缓存圈圈的显示
            if( zone=="news"|zone=="wp"|zone=="ios"|zone=="android" )
                updataSlide()//刷新大海报
        }
    }

    AddXmlModel{//用了加载更多新闻
        id:addxmlmodel
        signal postClose
        onStatusChanged: {
            if(status==XmlListModel.Ready&&count>0)
            {
                loading=false
                postClose()
            }
            else if(status==XmlListModel.Loading)
            {
                loading=true
            }
        }
    }
    
    MyLiseView{
        id:listview
        y:sysIsSymbian_v3?0:pageheader.height
        NumberAnimation on contentY{
            id:animation3
            to:0
            duration: 300
            running: false
            easing.type: Easing.OutQuart
        }
        onMovementStarted: {
            up.opacity=0
        }
        onMovementEnded: {
            if(listview.contentY>0)
                up.opacity=1
        }
        Keys.onPressed:mainlist.buttonPress(event.key)
    }
    
    Image{
        id:up
        opacity: 0
        visible: !sysIsSymbian_v3
        source: "qrc:/Image/up.svg"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        sourceSize.width:sysIsSymbian?60:80
        Behavior on opacity{
            NumberAnimation{duration: 300}
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                up.opacity=0
                animation3.start()
            }
        }
    }
    Connections{
        target: full?listview:null
        onMovementStarted: {
            main.showToolBar=false
        }
        onMovementEnded: {
            main.showToolBar=true
        }
    }
    Connections{
        target: main
        onCurrent_pageChanged:{
            if(zone=="favorite"&main.current_page=="page")
            {
                zone=""
                addFavoriteZone()//刷新收藏夹
            }
        }
    }

    onFocusChanged: {
        if(focus){
            listview.forceActiveFocus();//获得焦点
        }
    }
    
    Component.onCompleted: {
        addListViewCount=20
        xmlModel.beginPost("http://www.ithome.com/rss/news.xml",zone)//如果有网络就加载新闻
    }
}
