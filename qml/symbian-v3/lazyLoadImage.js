var winHeight = window.qml.screenHeight(); //当前窗口高度
function getPosition(id)
 {
    var obj=id
    var top  = 0;
    while(obj != document.body)
    {
        top  = obj.offsetTop;
        obj = obj.offsetParent;
    }
    //alert("图片坐标:"+top)
    return top
}
function refreshImage()
{
	var scrolltop = window.qml.getcContentY();  //滚动条偏移高度
	//alert("内容的Y坐标:"+scrolltop)
    var imageObj=document.getElementsByTagName("img")

	var bottom=0;//记录上一个已经显示的图片的尾端坐标
    for(var i=0;i<imageObj.length;++i){
        //alert("图片个数:"+imageObj.length)
        var obj=imageObj[i];
        var oTop = Math.max(getPosition(obj),bottom+100); //图片相对高度
		bottom=oTop;//更新bottom的值
        //alert("age image pos:"+bottom)
        //alert("image pos:"+oTop+","+obj.height);
		//判断是否在当前窗口内
        if((oTop-scrolltop) > -200 && (oTop-scrolltop) < winHeight &&obj.getAttribute("src")!==obj.getAttribute("data-url")){
            if(obj.getAttribute("data-url")=="")
            {
                obj.setAttribute("src",obj.getAttribute('loading-url'));//显示正在加载的状态
                //alert("")
                window.qml.loadImage(obj.getAttribute('myurl'),obj.getAttribute('id'),obj.getAttribute('suffix'))//如果图片不存在就调用qml中的函数加载
            }else{
                obj.setAttribute("src",obj.getAttribute('data-url'));
            }
        }
	}
}
function imageClick(myid)
{
    var obj=document.getElementById(myid)
    if(obj.getAttribute("src").indexOf('qml/general/')>0)
    {

        if(obj.getAttribute('data-url')==="")
        {
            window.qml.loadImage(obj.getAttribute('myurl'),myid,obj.getAttribute('suffix'));
            obj.setAttribute("src",obj.getAttribute('loading-url'));
        }else{
            //obj.hide();
            //obj.fadeIn(1000);
            obj.setAttribute("src",obj.getAttribute('data-url'));
        }
    }else window.qml.enlargeImage(obj.getAttribute("src"),getPosition(obj),obj.height());
}
