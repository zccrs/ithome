function CloseReplay(commentid) {
        var ReplyDiv = document.getElementById('Reply' + commentid);
        ReplyDiv.style.display = 'none';
}
function ShowReplay(commentid,newsid,lou)
{
    var obj
    obj=document.getElementById("against" + commentid).parentNode.parentNode.parentNode.firstChild.firstChild
    
    var text = obj.innerHTML
    text = text.substr(0,text.length-1)
    
    window.qml.commentReply(commentid,text,lou)
}

function commentFinish(msg, commentid)
{
    alert(commentid)
    if(msg.indexOf("评论成功") >= 0)
    {
        window.qml.showAlert("评论成功")
        var post=new XMLHttpRequest
        post.open("POST","http://www.ithome.com/ithome/GetAjaxData.aspx")
        post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
        post.onreadystatechange=function()
                {
                    if(post.readyState===4)
                    {
                        if(post.status===200)
                        {
                            //utility.consoleLog()
                            if( Number(commentid)!=0 ){
                                //$("#lou" + commentid).append('   <li class="gh"><div class="re_info"><strong class="p_floor"></strong>新回复</div><div class="re_comm"><p class="p_1">' + $("#commentContent" + commentid).val() + '</p><p class="p_2"><span class="comm_reply"><a  href="javascript:;">支持(0)</a><span class="v">|</span><a id="against877904" href="javascript:;">反对(0)</a><span class="v">|</span><a href="javascript:;">回复</a></span></p></li>');
                                $("#lou"+commentid).append(post.responseText).fadeIn('slow');
                                $("#lou"+commentid).show();
                            }else{
                                $("#LoadArticleReply").append(post.responseText).fadeIn('slow');
                                window.qml.commentToEnd()
                            }
                            //web.evaluateJavaScript('commentFinish('+'\''+post.responseText+'\''+')')
                        }
                    }
                }
        if( Number(commentid)!= 0 )
            post.send("commentid="+commentid+"&type=getloucomment")
        else
            post.send("newsID="+window.qml.mySid()+"&type=comment")
    }
}
function pagecomment(page,num) {
    alert("点击了增加更多评论")
    var post=new XMLHttpRequest
    post.open("POST","http://www.ithome.com/ithome/GetAjaxData.aspx")
    post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
    post.onreadystatechange=function()
            {
                if(post.readyState===4)
                {
                    if(post.status===200)
                    {
                        if(post.responseText==="")
                            window.qml.showAlert("下面没有啦")
                        else
                            addCommentFinish(post.responseText)
                    }
                }
            }
    post.send("newsID="+window.qml.mySid()+"&type=commentpage&page="+page)
    //window.qml.loadMoreComment(page)
}
function addCommentFinish(page)
{
    $("#LoadArticleReply").text('')
    $("#ulcommentlist").append("<div>"+page+"</div>").fadeIn('slow');
    var obj
    obj=document.getElementsByClassName("p_floor")
    var string=obj[obj.length-1].innerHTML

    string = string.substr(0,string.length-1)
    
    if(Number(string)%50!=0)//如果加载到了最后
    {
        var more=document.getElementById("pagecomment")
        more.parentNode.removeChild(more) //删除加载更多的按钮
    }
}
 function commentVote(commentid, typeid) {
    var post=new XMLHttpRequest
    post.open("POST","http://www.ithome.com/ithome/postComment.aspx")
    post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
    post.onreadystatechange=function()
            {
                if(post.readyState===4)
                {
                    if(post.status===200)
                    {
                        if(post.responseText.indexOf('您')>-1)
                            window.qml.showAlert(post.responseText)
                        else
                            reData(commentid,typeid,post.responseText)
                    }
                }
            }
    post.send("commentid=" + commentid + "&type=replyVote&typeid=" + typeid)
    //window.qml.acquireComment(commentid,typeid,"commentid=" + commentid + "&type=replyVote&typeid=" + typeid)
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

function commentComplain(commentid) {
    alert("点击了举报")
    var post=new XMLHttpRequest
    post.open("POST","http://www.ithome.com/ithome/postComment.aspx")
    post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
    post.onreadystatechange=function()
            {
                if(post.readyState===4){
                    if(post.status===200){
                        window.qml.showAlert(post.responseText)
                    }
                }
            }
    post.send("commentid=" + commentid + "&type=complain")
}

function initHtml()
{
    var post=new XMLHttpRequest
    post.open("POST","http://www.ithome.com/ithome/GetAjaxData.aspx")
    post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
    post.onreadystatechange=function()
            {
                if(post.readyState===4)
                {
                    if(post.status===200)
                    {
                       if(post.responseText!=""){
                            var string=post.responseText
                           //alert(string)
                            var count=0
                            var pos=string.indexOf("class=\"entry\"")
                            while(pos>=0)
                            {
                                count++
                                pos=string.indexOf("class=\"entry\"",pos+100)
                            }
                            if(count>=50)//判断评论是否超过50,用来判断是否要显示“查看更多评论的选项”
                                document.getElementById("commentlist").innerHTML = unescape('<h3><span class="icon2"></span>评论列表</h3><ul class="list" id="ulcommentlist">'+string+'</ul><ul class="list" id="LoadArticleReply"></ul><div class="more_comm"><a id="pagecomment" href="javascript:pagecomment(++commentpage,0);">查看更多评论 ...</a></div>');
                            else
                                document.getElementById("commentlist").innerHTML = unescape('<h3><span class="icon2"></span>评论列表</h3><ul class="list" id="ulcommentlist">'+string+'</ul><ul class="list" id="LoadArticleReply"></ul>');
                        }else{
                            document.getElementById("commentlist").innerHTML = unescape('<h3><span class="icon2"></span>评论列表</h3>');
                            window.qml.showAlert("还没有人评论，赶快抢沙发")
                        }
                        window.qml.initHtmlFinisd()
                    }
                }
            }
    post.send("newsID="+window.qml.mySid()+"&type=commentpage&page=1")
}

function displayCommentLouMore(commentid)//加载更多楼中楼评论
{
    var post=new XMLHttpRequest
    post.open("POST","http://www.ithome.com/ithome/GetAjaxData.aspx")
    post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
    post.onreadystatechange=function()
            {
                if(post.readyState===4){
                    if(post.status===200){
                        $("#lou" + commentid).append(post.responseText).fadeIn('slow');
                        $("#liGetMore" + commentid).hide();
                    }
                }
            }
    post.send("commentid=" + commentid + "&type=getmorelou")
}
