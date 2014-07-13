var winHeight = window.qml.screenHeight(); //当前窗口高度
function refreshImage()
{
	var scrolltop = window.qml.getcContentY();  //滚动条偏移高度
	//alert("内容的Y坐标:"+scrolltop)
	//alert("图片个数:"+$("img").length)
	var bottom=0;//记录上一个已经显示的图片的尾端坐标
	for(var i=0;i<$("img").length;++i){
		var obj=$("img:eq("+i+")");
		var oTop = Math.max(obj.offset().top,bottom+100); //图片相对高度
		bottom=oTop;//更新bottom的值
		//alert("刚刚显示的图片的尾部的坐标:"+bottom)
		//alert("图片的相对Y坐标和图片的高:"+oTop+","+obj.attr("height"));
		//判断是否在当前窗口内
        if((oTop-scrolltop) > -200 && (oTop-scrolltop) < winHeight &&obj.attr("src")!==obj.attr("data-url")){
            if(obj.attr("data-url")==="")
            {
                obj.attr("src",obj.attr("loading-url"));//显示正在加载的状态
                //obj.attr("src",obj.attr("myurl"));//加载图片
                window.qml.loadImage(obj.attr('myurl'),obj.attr('id'),obj.attr('suffix'))//如果图片不存在就调用qml中的函数加载
            }else{
                //渐出效果
                obj.hide()
                //给src属性赋值
                obj.attr("src",obj.attr("data-url"));
                obj.fadeIn(300);
            }
        }
	}
}
function imageClick(myid)
{
    var obj=$("#"+myid)
    if(obj.attr("src").indexOf('qml/general/')>0)
    {
        if(obj.attr('data-url')==="")
        {
            window.qml.loadImage(obj.attr('myurl'),myid,obj.attr('suffix'));
            obj.attr("src",obj.attr('loading-url'));
        }else{
            obj.hide();
            obj.fadeIn(1000);
            obj.attr("src",obj.attr('data-url'));
        }
    }else window.qml.enlargeImage(obj.attr("src"),obj.offset().top,obj.height());
}
