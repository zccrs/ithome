var maxnewsid = new XMLHttpRequest();
function postBegin(page_id,postMode,url,postData){
    console.log("post url:"+url)
    maxnewsid.open(postMode,url);
    if(postMode==="POST")
        maxnewsid.setRequestHeader("Content-Type"," text/html; charset=utf-8");
    maxnewsid.onreadystatechange=function(){
                //console.log("maxnewsid.readyState:"+maxnewsid.readyState)
                if(maxnewsid.readyState===4){
                    //console.log("maxnewsid.status:"+maxnewsid.status)
                    if(maxnewsid.status===200){
                        //console.log(Number(maxnewsid.responseText)-maxnewsidData)
                        page_id.postOk(maxnewsid.responseText)
                    }
                }
            }
    if(postMode==="POST"){
        console.log("post data:"+postData)
        maxnewsid.send(postData)
    }else maxnewsid.send()
}
function stop(){
    if(maxnewsid.status!=200&maxnewsid.readyState!=4)
    {
        maxnewsid.abort()
        return true
    }
    else return false
}
