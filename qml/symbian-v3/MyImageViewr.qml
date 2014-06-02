// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0

Item{
    id:image_zoom
    opacity: 0
    property url imageUrl;
    property alias myView: imageFlickable
    property alias myImage: imagePreview
    anchors.fill: parent
    function close(){}
    Behavior on opacity{
        NumberAnimation{duration: 100}
    }
    Rectangle{
        anchors.fill: parent
        color: "black"
        opacity: 0.8
    }
    Flickable {
        id: imageFlickable
        width: parent.width
        height: parent.height
        interactive: image_zoom.opacity
        contentWidth: imageContainer.width;
        contentHeight: imageContainer.height
        //clip: true
        onHeightChanged: if (imagePreview.status === Image.Ready) imagePreview.fitToScreen()

        Item {

            id: imageContainer
            width: Math.max(imagePreview.width * imagePreview.scale, imageFlickable.width)
            height: Math.max(imagePreview.height * imagePreview.scale, imageFlickable.height)

            Image {
                id: imagePreview
                property real prevScale
                function fitToScreen() {
                    scale = Math.min(imageFlickable.width / width, imageFlickable.height / height, 1)
                    //pinchArea.minScale = scale
                    prevScale = scale
                }

                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                source: image_zoom.visible?imageUrl:""
                sourceSize.width: 2000;
                smooth: !imageFlickable.moving

                onStatusChanged: {
                    if (status == Image.Ready) {
                        fitToScreen()
                        loadedAnimation.start()
                    }
                }

                NumberAnimation {
                    id: loadedAnimation
                    target: imagePreview
                    property: "opacity"
                    duration: 250
                    from: 0; to: 1
                    easing.type: Easing.InOutQuad
                }

                onScaleChanged: {
                    if ((width * scale) > imageFlickable.width) {
                        var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) * scale / prevScale;
                        imageFlickable.contentX = xoff - imageFlickable.width / 2
                    }
                    if ((height * scale) > imageFlickable.height) {
                        var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) * scale / prevScale;
                        imageFlickable.contentY = yoff - imageFlickable.height / 2
                    }
                    prevScale = scale
                }
            }
        }


        MouseArea{
            anchors.fill: parent
            onClicked: {
                close()
            }
        }
        MouseArea {
            id: mouseArea;
            width: imagePreview.width* imagePreview.scale
            height: imagePreview.height*imagePreview.scale
            y:parent.height/2-height/2+imageFlickable.contentY
            x:parent.width/2-width/2+imageFlickable.contentX
            enabled: imagePreview.status === Image.Ready;
            onDoubleClicked: {
                //utility.consoleLog("图片的比例："+Math.ceil(imagePreview.scale)+" "+Math.ceil(Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1)))
                if (Math.ceil(imagePreview.scale) != Math.ceil(Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1))){
                    bounceBackAnimation.to = Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1)
                    bounceBackAnimation.start()
                } else if(imagePreview.scale<Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1))
                {
                    bounceBackAnimation.to = Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1)
                    bounceBackAnimation.start()
                }
                else{
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }
            onClicked: {
                if(pinchArea.opacity===1)
                    pinchArea.opacity=0
                else
                    pinchArea.opacity=1
            }
        }
        onMovementStarted:
            if(pinchArea.opacity===1)
                pinchArea.opacity=0
    }
    PinchArea {
        id: pinchArea

        Behavior on opacity{
            NumberAnimation{
                duration: 200
            }
        }

        imageScale: imagePreview.scale

        onLarge: {
            if(imagePreview.scale<maxScale)
                imagePreview.scale+=0.1
        }
        onDiminish: {
            if(imagePreview.scale>minScale)
                imagePreview.scale-=0.1
        }
        onChangedImageScale: {
            //utility.consoleLog("要改变的比例是："+value)
            imagePreview.scale=value
        }

        NumberAnimation {
            id: bounceBackAnimation
            target: imagePreview
            duration: 250
            property: "scale"
            from: imagePreview.scale
        }
    }
}
