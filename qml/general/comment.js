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
    //alert(msg)
    //document.getElementById("LoadArticleReply").innerHTML=unescape(msg)
    //$("#LoadArticleReply").attr("id","temp")"<ul class=\"list\" id=\"LoadArticleReply\"></ul>"
    $("#LoadArticleReply").prepend(msg).fadeIn('slow');
}
function pagecomment(page,num) {
    window.qml.loadMoreComment(page)
}
function addCommentFinish(page)
{
    $("#LoadArticleReply").text('')
    $("#ulcommentlist").append("<div>"+page+"</div>").fadeIn('slow');
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
    window.qml.acquireComment(commentid,typeid,"commentid=" + commentid + "&type=replyVote&typeid=" + typeid)
 }
function reData(commentid,typeid,count)
{
    if (typeid == 1) {
        $("#agree" + commentid).text('支持(' + count + ')');
        $("#agree" + commentid).removeAttr("href");

        $("#agree" + commentid).css({ "position": "relative" });
        $("#agree" + commentid).append("<span class='flower'></span>");
        $("#agree" + commentid).find(".flower").css({ "position": "absolute", "text-align": "center", "left": "6px", "top": "-10px", "display": "block", "width": "30px", "height": "30px", "background": "url(http://file.ithome.com/images/agree.gif) left center no-repeat", "opacity": "0" }).animate({ top: '-30px', opacity: '1' }, 300, function () { $(this).delay(300).animate({ top: '-35px', opacity: '0' }, 300) });
        $("#agree" + commentid).find(".flower").removeClass();
    }
    else {
        $("#against" + commentid).text('反对(' + count + ')');
        $("#against" + commentid).removeAttr("href");

        $("#against" + commentid).css({ "position": "relative" });
        $("#against" + commentid).append("<span class='shit'></span>");
        $("#against" + commentid).find(".shit").css({ "position": "absolute", "text-align": "center", "left": "6px", "top": "-60px", "display": "block", "width": "30px", "height": "30px", "background": "url(http://file.ithome.com/images/against.gif) left center no-repeat", "opacity": "0" }).animate({ top: '-30px', opacity: '1' }, 300, function () { $(this).delay(300).animate({ top: '-5px', opacity: '0' }, 300) });
        $("#against" + commentid).find(".shit").removeClass();
    }
}
