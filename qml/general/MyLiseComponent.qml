// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0

Component{
    id:delegate

    Rectangle {
        id:root
        height: isHighlight?40:(sysIsSymbian_v3?60:100)
        width: page.width
        property string me_to_xml: ""//这篇新闻的xml格式的内容
        color: (night_mode?index%2?"#000000":"#191919":index%2?"#EBEBEB":"#F5F5F5")//isHighlight?"#be0028":
        Connections{
            target: isHighlight?null:listview
            onFlickStarted:{
                showImage=0
                imageHide.start()
            }
            onMovementEnded:{
                imageShow.start()
                //titleimage.visible=true
            }
        }
        Connections{
            target: isHighlight?null:main
            onBrilliance_controlChanged:{
                if(main.night_mode)
                    titleimage.opacity=brilliance_control
            }
        }
        Image{
            id:yiyue//已经阅读
            visible: settings.getValue("titleTextClock"+String(newsid),false)&&(!isHighlight)
            source: "qrc:/Image/yiyue.png"
            sourceSize.width:sysIsSymbian_v3?30:50
            anchors.bottom: sysIsSymbian_v3?parent.bottom:comment_count.top
            anchors.right: parent.right
            anchors.rightMargin: main.sysIsSymbian?10:20
        }
        Text{
            x:main.sysIsSymbian?10:20
            anchors.verticalCenter: parent.verticalCenter
            visible: isHighlight?true:false
            text:m_text
            verticalAlignment: Text.AlignVCenter
            color: main.night_mode?"#f0f0f0":"#282828"
            font.pixelSize: main.sysIsSymbian?20:26
        }

        Image{
            id:titleimage
            visible: isHighlight?false:true
            opacity: showImage
            anchors.verticalCenter: parent.verticalCenter
            x:main.sysIsSymbian?10:20
            asynchronous:true
            width:parent.height-10
            height: width
            sourceSize.width:width
            sourceSize.height:height
            source:(no_show_image|isWifi&wifiStatus===-1)&!utility.imageIsShow("titleImage"+String(newsid))?"qrc:/Image/it.png":image
            NumberAnimation on opacity{
                id:imageHide
                to:0
                duration: 200
                running: false
            }
            NumberAnimation on opacity{
                id:imageShow
                to:{
                    if(main.night_mode)
                        return brilliance_control
                    else return 1
                }
                duration: 1500
                running: false
            }
            NumberAnimation on opacity{
                id:imageToShow
                from:0
                to:{
                    if(main.night_mode)
                        return brilliance_control
                    else return 1
                }
                duration: 1000
                running: false

            }

            /*MyImage{
                id:loadImage
                sid:newsid
                //source:(no_show_image|isWifi&wifiStatus===-1)&!utility.imageIsShow("titleImage"+String(newsid))?"noImage":image
                onImageClose: {
                    //titleimage.source=imageSrc
                }
            }*/
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    //console.log("click title image")
                    if(!utility.imageIsShow("titleImage"+String(newsid)))
                    {
                        titleimage.source=image
                        imageToShow.start()
                        utility.imageToShow("titleImage"+String(newsid))
                    }
                }
            }

        }
        Text {
            id:titletext
            clip:true
            visible: isHighlight?false:true
            anchors.top: titleimage.top
            anchors.left: titleimage.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: main.sysIsSymbian?10:20
            anchors.bottom: date.top
            opacity: night_mode?brilliance_control:1
            text: title
            font.pixelSize: sysIsSymbian?sysIsSymbian_v3?14:20:24
            wrapMode: Text.WordWrap
            color: main.night_mode?"#f0f0f0":"#282828"
        }
        Text{
            id:date
            visible: isHighlight?false:true
            anchors.left: titletext.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            font.pixelSize: main.sysIsSymbian?(sysIsSymbian_v3?10:11):18
            text:postdate
            color: main.night_mode?"#f0f0f0":"#282828"
            opacity: night_mode?brilliance_control:1
        }
        Text{
            visible:(isHighlight||sysIsSymbian_v3)?false:true
            anchors.top: date.top
            anchors.right: comment_count.left
            anchors.left: date.right
            text:"人气："+hitcount
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: main.sysIsSymbian?11:18
            color: main.night_mode?"#f0f0f0":"#282828"
            opacity: night_mode?brilliance_control:1
        }
        Text{
            id:comment_count
            visible: (isHighlight||sysIsSymbian_v3)?false:true
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: date.top
            font.pixelSize: main.sysIsSymbian?11:18
            text:"评论："+commentcount
            color: main.night_mode?"#f0f0f0":"#282828"
            opacity: night_mode?brilliance_control:1
        }


        MouseArea{
            id:mouse
            enabled: allowMouse&!isHighlight
            anchors.fill: titletext
            onClicked: {
                if(cacheContent.getContent_noImageModel(newsid)==="-1"|sysIsSymbian_v3){
                    //cacheContent.saveTitle(newsid,title)
                    cacheContent.saveContent(newsid,detail)
                }
                main.current_page="content"
                yiyue.visible=true
                settings.setValue("titleTextClock"+String(newsid),true)

                //console.log("utility.imageIsShow="+utility.imageIsShow("contentImage"+String(newsid)))
                if((no_show_image|isWifi&wifiStatus===-1)&!utility.imageIsShow("contentImage"+String(newsid))){
                    var contentData={
                        mysid:newsid,
                        title:title,
                        myurl:m_url,
                        postdate:postdate,
                        newsauthor:newsauthor,
                        newssource:newssource,
                        allowDoubleClick:true,
                        url:sysIsSymbian_v3?detail:cacheContent.getContent_noImageModel(newsid),
                        me_to_xml:root.me_to_xml//这篇新闻的xml格式的内容
                    }
                }
                else{
                    loading=true
                    //console.log("contentSrc is:"+contentSrc)
                    contentData={
                        mysid:newsid,
                        title:title,
                        myurl:m_url,
                        postdate:postdate,
                        newsauthor:newsauthor,
                        newssource:newssource,
                        url:sysIsSymbian_v3?detail:cacheContent.getContent_noImageModel(newsid),
                        me_to_xml:root.me_to_xml//这篇新闻的xml格式的内容
                    }
                }
                page.loadContent(contentData)
            }
        }
        Keys.onPressed: {
            if(event.key === Qt.Key_Select||event.key === Qt.Key_Enter||event.key === Qt.Key_Return){
                if(!isHighlight)
                    mouse.clicked(0)
                event.accepted = true
            }
        }
        Component.onCompleted: {
            var string1="            <newsid>"+String(newsid)+"</newsid>\r\n"
            var string2="            <title>"+String(title)+"</title>\r\n"
            var string3="            <url>"+String(m_url)+"</url>\r\n"
            var string4="            <postdate>"+String(postdate)+"</postdate>\r\n"
            var string5="            <newssource>"+String(newssource)+"</newssource>\r\n"
            var string6="            <newsauthor>"+String(newsauthor)+"</newsauthor>\r\n"
            var string7="            <image>"+String(image)+"</image>\r\n"
            var string8="            <description>"+String(description)+"</description>\r\n"
            var string9="            <detail>"+String(detail)+"</detail>\r\n"
            var string10="            <hitcount>"+String(hitcount)+"</hitcount>\r\n"
            var string11="            <commentcount>"+String(commentcount)+"</commentcount>\r\n"
            me_to_xml=string1+string2+string3+string4+string5+string6+string7+string8+string9+string10+string11
        }
    }
}
