// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "../general"
Item{
    anchors.fill: parent
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
        id:input_code
        placeholderText: "验证码"
        platformInverted: main.platformInverted
        anchors.top: input_email.bottom
        anchors.topMargin: 20
        anchors.left: input_email.left
        anchors.right: code_image.left
        anchors.rightMargin: 10
        KeyNavigation.down: input_email
        KeyNavigation.up:input_email
        KeyNavigation.tab: input_email
    }
    Connections{
        target: utility
        onGetCodeOk:{
            var re = new RegExp("CheckCode=(\\w+(?=;))")
            var cookie2 = replyData.match(re)

            input_code.text = cookie2[1].toLocaleLowerCase()//toLocaleLowerCase为转化为小写
            code_image.source = utility.cacheImagePrefix+"code.jpg"
            
            re = new RegExp("ASP.NET_SessionId=\\w+;")
            settings.setValue("CodeCookie", replyData.match(re)+cookie2[0])
        }
        
        onTestEmailOk:{
            var isExist = JSON.parse( replyData )
            if( isExist.d ){
                showBanner("邮箱不可用")
            }else{
                utility.registerUserGeneral( "{user:\""+input_email.text+"\",requestValidate:\""+input_code.text+"\"}",
                                            "http://i.ruanmei.com/reg.aspx/PostRegemail")
            }
        }
        
        onRegisterUserOk:{
            showBanner(JSON.parse(replyData).d)
        }
    }

    Image{
        id:code_image
        width: sourceSize.width
        cache: false
        anchors.right: input_email.right
        anchors.verticalCenter: input_code.verticalCenter
        MouseArea{
            anchors.fill: parent
            onClicked: {
                parent.source=""
                utility.getCode()//获取验证码
            }
        }
    }

    Button{
        id: register_button
        enabled: input_email.text!=""&input_code.text!=""
        text: "注        册"
        font.pixelSize: 18
        anchors.top: input_code.bottom
        anchors.topMargin: 20
        
        width: parent.width*0.6
        platformInverted: main.platformInverted
        anchors.horizontalCenter: parent.horizontalCenter
        
        onClicked: {
            utility.registerUserGeneral( "{email:\""+input_email.text+"\"}" )
        }
    }
    
    onVisibleChanged: {
        if(visible)
            utility.getCode()//获取验证码
    }
}
