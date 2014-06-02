
function CloseReplay(commentid) {
        var ReplyDiv = document.getElementById('Reply' + commentid);
        ReplyDiv.style.display = 'none';
}
function ShowReplay(commentid,newsid)
{
    var obj
    obj=document.getElementById("against" + commentid).parentNode.parentNode.parentNode.firstChild.firstChild
    window.qml.commentReply(commentid,obj.innerHTML)
}

function commentFinish(msg)
{
    var html=document.getElementById("LoadArticleReply").innerHTML
    document.getElementById("LoadArticleReply").innerHTML=html+unescape(msg);
}
function pagecomment(page) {
    window.qml.loadMoreComment(page)
}
function addCommentFinish(page)
{
    document.getElementById("LoadArticleReply").innerHTML=""
    document.getElementById("ulcommentlist").innerHTML+=unescape(page);
    var obj
    obj=document.getElementsByClassName("p_floor")
    var string=obj[obj.length-1].innerHTML
    if(string=="1楼")//如果加载到了最后
    {
        var more=document.getElementById("pagecomment")
        more.parentNode.removeChild(more) //删除加载更多的按钮
    }
}
 function commentVote(commentid, typeid) {
    //alert("楼层id:"+commentid)
    window.qml.acquireComment(commentid,typeid,"commentid=" + commentid + "&type=replyVote&typeid=" + typeid)
 }
function reData(commentid,typeid,count)
{
    //alert("楼层id:"+commentid)
    var obj
    if (typeid == 1) {
        obj=document.getElementById("agree" + commentid)
        obj.innerHTML='支持(' + count + ')';
        obj.setAttribute("href","");

        //obj.style.position = "relative";
        //obj.insertAdjacentHTML("afterEnd","<span class='flower'></span>");
        //obj.firstChild.style.position="absolute"
        //obj.firstChild.style.textAlign="center"
        //obj.firstChild.style.left="6px"
        //obj.firstChild.style.top="-10px"
        //obj.firstChild.style.display="block"
        //obj.firstChild.style.width="30px"
        //obj.firstChild.style.height="30px"
        //obj.firstChild.style.background="url(http://file.ithome.com/images/agree.gif)"
        //obj.firstChild.style.opacity="0"

        //obj.firstChild.css({ "position": "absolute", "text-align": "center", "left": "6px", "top": "-10px", "display": "block", "width": "30px", "height": "30px", "background": "url(http://file.ithome.com/images/agree.gif) left center no-repeat", "opacity": "0" }).animate({ top: '-30px', opacity: '1' }, 300, function () { $(this).delay(300).animate({ top: '-35px', opacity: '0' }, 300) });
        //$("#agree" + commentid).find(".flower").removeClass();
        //setTimeout('obj.removeChild(obj.firstChild)',"2000");
    }
    else {
        obj=document.getElementById("against" + commentid)
        //$("#against" + commentid).text('反对(' + count + ')');
        //$("#against" + commentid).removeAttr("href");

        //$("#against" + commentid).css({ "position": "relative" });
        //$("#against" + commentid).append("<span class='shit'></span>");
        //$("#against" + commentid).find(".shit").css({ "position": "absolute", "text-align": "center", "left": "6px", "top": "-60px", "display": "block", "width": "30px", "height": "30px", "background": "url(http://file.ithome.com/images/against.gif) left center no-repeat", "opacity": "0" }).animate({ top: '-30px', opacity: '1' }, 300, function () { $(this).delay(300).animate({ top: '-5px', opacity: '0' }, 300) });
        //$("#against" + commentid).find(".shit").removeClass();

        obj.innerHTML='反对(' + count + ')';
        obj.setAttribute("href","");

        //obj.style.position = "relative";
        //obj.insertAdjacentHTML("afterEnd","<span class='shit'></span>");
        //obj.firstChild.style.position="absolute"
        //obj.firstChild.style.textAlign="center"
        //obj.firstChild.style.left="6px"
        //obj.firstChild.style.top="-10px"
        //obj.firstChild.style.display="block"
        //obj.firstChild.style.width="30px"
        //obj.firstChild.style.height="30px"
        //obj.firstChild.style.background="url(http://file.ithome.com/images/against.gif) left center no-repeat"
        //obj.firstChild.style.opacity="0"
        //obj.firstChild.css({ "position": "absolute", "text-align": "center", "left": "6px", "top": "-10px", "display": "block", "width": "30px", "height": "30px", "background": "url(http://file.ithome.com/images/agree.gif) left center no-repeat", "opacity": "0" }).animate({ top: '-30px', opacity: '1' }, 300, function () { $(this).delay(300).animate({ top: '-35px', opacity: '0' }, 300) });
        //$("#agree" + commentid).find(".flower").removeClass();
        //setTimeout('obj.removeChild(obj.firstChild)',"2000");
    }
}
