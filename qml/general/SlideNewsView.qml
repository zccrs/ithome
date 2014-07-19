// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
//import myXmlListModel 1.0
import QtWebKit 1.0

Item{
    id: slideNews_main
    width: parent.width
    height: 347/600*width
    property bool updata: false
    clip: true
    Connections{
        target: get_slide_xml
        onAddSlideData:{
            model.append( {"title":title, "imageSrc":image, "newsid": newsid} )
        }
    }
    
    
    XmlListModel{//用了加载大海报
        id:get_slide_xml
        signal addSlideData(string title,string image, string newsid)
        source: "http://www.ithome.com/xml/slide/"+(zone=="news"?"slide":zone)+".xml"
        query:"/rss/channel/item"
        XmlRole { name: "title"; query: "title/string()" }//文章标题
        XmlRole { name: "image"; query: "image/string()" }//大图
        XmlRole { name: "newsid"; query: "link/string()" }//文章id
        onStatusChanged: {
            if(status==XmlListModel.Ready&&count>0)
            {
                for( var i=0;i<count;++i ){
                    addSlideData( get(i).title, get(i).image, get(i).newsid )
                }
            }
        }
    }
    
    Image{
        id: loading_image
        anchors.centerIn: parent
        source: "loading.png"
    }

    ListView{
        id: slide_list
        anchors.fill:parent
        model: ListModel{id:model}
        delegate: Image{
            id: slide_image
            sourceSize.width: slideNews_main.width
            source: imageSrc
            //source: "qrc:/Image/Symbian.png"
            onStatusChanged: {
                if( slide_image.status == Image.Ready ){
                    loading_image.visible=false
                    timer_flipable.start()
                }
            }
            property string me_to_xml: ""//这篇新闻的xml格式的内容
            AddXmlModel{
                id: slide_xmlmodel
                source: "http://www.ithome.com/rss/"+newsid+".xml"
                onStatusChanged: {
                    if(status==XmlListModel.Ready&&count>0)
                    {
                        var string1="            <newsid>"+String(newsid)+"</newsid>\r\n"
                        var string2="            <title>"+String(get(0).title)+"</title>\r\n"
                        var string3="            <url>"+String(get(0).m_url)+"</url>\r\n"
                        var string4="            <postdate>"+String(get(0).postdate)+"</postdate>\r\n"
                        var string5="            <newssource>"+String(get(0).newssource)+"</newssource>\r\n"
                        var string6="            <newsauthor>"+String(get(0).newsauthor)+"</newsauthor>\r\n"
                        var string7="            <image>"+String(get(0).image)+"</image>\r\n"
                        var string8="            <description>"+String(get(0).description)+"</description>\r\n"
                        var string9="            <detail>"+String(get(0).detail)+"</detail>\r\n"
                        var string10="            <hitcount>"+String(get(0).hitcount)+"</hitcount>\r\n"
                        var string11="            <commentcount>"+String(get(0).commentcount)+"</commentcount>\r\n"
                        me_to_xml=string1+string2+string3+string4+string5+string6+string7+string8+string9+string10+string11
                        mouse_slide.enabled = true
                    }
                }
            }
            Connections{//接收按键信号
                target: slideNews_main.parent
                onKeyPressed: {
                    if(keysid === Qt.Key_Select||keysid === Qt.Key_Enter||keysid === Qt.Key_Return){
                        if(!isHighlight)
                            mouse_slide.clicked(0)
                    }
                }
            }
            MouseArea{
                id: mouse_slide
                anchors.fill: parent
                enabled: false
                onClicked: {
                    if(cacheContent.getContent_noImageModel(newsid)==="-1"|sysIsSymbian_v3){
                        //cacheContent.saveTitle(newsid,title)
                        cacheContent.saveContent(newsid,slide_xmlmodel.get(0).detail)
                    }
                    main.current_page="content"
                    settings.setValue("titleTextClock"+String(newsid),true)//记录此新闻已经看过
        
                    if((no_show_image|isWifi&wifiStatus===-1)&!utility.imageIsShow("contentImage"+String(newsid))){
                        var contentData={
                            mysid:newsid,
                            title:slide_xmlmodel.get(0).title,
                            myurl:slide_xmlmodel.get(0).m_url,
                            postdate:slide_xmlmodel.get(0).postdate,
                            newsauthor:slide_xmlmodel.get(0).newsauthor,
                            newssource:slide_xmlmodel.get(0).newssource,
                            allowDoubleClick:true,
                            url:sysIsSymbian_v3?slide_xmlmodel.get(0).detail:cacheContent.getContent_noImageModel(newsid),
                            me_to_xml:slide_image.me_to_xml//这篇新闻的xml格式的内容
                        }
                    }
                    else{
                        loading=true
                        //console.log("contentSrc is:"+contentSrc)
                        contentData={
                            mysid:newsid,
                            title:slide_xmlmodel.get(0).title,
                            myurl:slide_xmlmodel.get(0).m_url,
                            postdate:slide_xmlmodel.get(0).postdate,
                            newsauthor:slide_xmlmodel.get(0).newsauthor,
                            newssource:slide_xmlmodel.get(0).newssource,
                            url:sysIsSymbian_v3?slide_xmlmodel.get(0).detail:cacheContent.getContent_noImageModel(newsid),
                            me_to_xml:slide_image.me_to_xml//这篇新闻的xml格式的内容
                        }
                    }
                    page.loadContent(contentData)//打开新闻
                }
            }
            Rectangle{
                anchors.bottom: parent.bottom
                width: parent.width
                height: slide_text.height+8
                color: "white"
                opacity: 0.6
                clip: true
                Text{
                    id: slide_text
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    text: title
                    font.pixelSize: sysIsSymbian_v3?10:16
                }
                Text{
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    font.pixelSize: sysIsSymbian_v3?10:16
                    text: (index+1)+"/"+get_slide_xml.count
                }
            }
        }
        boundsBehavior: Flickable.StopAtBounds
        maximumFlickVelocity :800//滑动速度
        orientation: ListView.HorizontalFlick
        snapMode :ListView.SnapOneItem
    }
    
    Flipable{
        id: slide_flipable
        anchors.fill: parent
        property bool flipable: false
        front: slide_list
        state: "front"
        Timer{
            id: timer_flipable
            interval: 5000
            onTriggered: slide_flipable.flipableBegin()
            repeat: true
        }
        function flipableBegin()
        {
            if(state == "front" )
                state = "back"
            else
                state = "front"
            set_list.start()
        }

        Timer{
            id: set_list
            interval: 500
            property int number: 1//记录改翻转到第几个大海报
            onTriggered: {
                //console.log(number)
                slide_list.positionViewAtIndex(number,ListView.Beginning)
                number = (number+1)%get_slide_xml.count
            }
        }
        
        transform: Rotation {
            id: rotation
            origin.x: slide_flipable.width/2
            origin.y: slide_flipable.height/2
            axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
            angle: 0    // the default angle
        }
   
        states: [
            State {
                name: "back"
                PropertyChanges { target: rotation; angle: 360 }
            },
            State {
                name: "front"
                PropertyChanges { target: rotation; angle: 0 }
            }
        ]    
        transitions: Transition {
            NumberAnimation { 
                target: rotation; 
                property: "angle"; 
                duration: 1000 
                easing.type: Easing.InOutBack
            }
        }
    }
}
