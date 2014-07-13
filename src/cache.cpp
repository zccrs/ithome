#include "cache.h"
#include <QDebug>
#include <QVariant>
#include <QApplication>
Cache::Cache(Settings *new_set,QObject *parent) :
    QObject(parent)
{
    setting=new_set;
    contentImage="";

    mythread = new QThread(this);
    threadDownloadImage = new ThreadDownloadImage;
    threadDownloadImage->moveToThread(mythread);
    connect(this,SIGNAL(imageDownloads(QString,QString,QString,QString)),threadDownloadImage,SLOT(imageDownload(QString,QString,QString,QString)));
    connect(this,SIGNAL(cancleDownloadImages()),threadDownloadImage,SLOT(cancleDownloadImage()));
    connect(threadDownloadImage,SIGNAL(imageDownloadFinish(QString,QString,QString)),this,SIGNAL(imageDownloadFinish(QString,QString,QString)));
    mythread->start();


    mythread_removeCache = new QThread(this);
    reCache = new RemoveCache;
    reCache->moveToThread(mythread_removeCache);
    connect(this,SIGNAL(removeCache()),reCache,SLOT(clearCache()));
    connect(reCache,SIGNAL(removeResult(bool)),this,SIGNAL(removeResult(bool)));
    mythread_removeCache->start();

#if defined(Q_OS_HARMATTAN)
    prefix = QDir::homePath()+"/.ithome";
    coding="utf-8";
#else
    prefix="D:/ithome";
#ifdef Q_OS_LINUX
    coding="utf-8";
#else
    coding="gbk";
#endif
#endif
    QFileInfo info(prefix);
    QDir temp;
    if(!info.exists())
        if(!temp.mkpath(prefix))
            qDebug()<<prefix<<QString::fromUtf8("路径创建失败");
}
void Cache::saveTitle(const QString sid, QString string)
{
    QFileInfo fileinfo(prefix+"/cache/"+sid);
    QDir temp;
    QFileInfo info(prefix+"/cache");
    if(!info.isDir())
        temp.mkdir(prefix+"/cache");
    if(!fileinfo.isDir())
    {
        //qDebug()<<temp.exists();
        temp.mkdir(prefix+"/cache/"+sid);
    }
    file.setFileName(prefix+"/cache/"+sid+"/title.txt");
    if(!file.exists())
    {
        file.open(QIODevice::WriteOnly);
        QTextStream text(&file);
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
        text.setCodec("utf-8");
#endif
        setting->setValue("cache_size",setting->getValue("cache_size",0).toLongLong()+string.size());
        text<<string;
        file.close();
    }
}
void Cache::saveContent(const QString sid,QString string)
{
    QFileInfo fileinfo(prefix+"/cache/"+sid);
    QDir temp;
    QFileInfo info(prefix+"/cache");
    if(!info.isDir())
        if(! temp.mkdir(prefix+"/cache"))
            qDebug()<<QString::fromUtf8("路径创建失败")<<prefix+"/cache";
    if(!fileinfo.isDir())
    {
        //qDebug()<<temp.exists();
        temp.mkdir(prefix+"/cache/"+sid);
    }
    file.setFileName(prefix+"/cache/"+sid+"/content_noImageModel.html");
    if(!file.exists())
    {
        file.open(QIODevice::WriteOnly);
        QTextStream text(&file);
        
        QDir dirTemp;
#if   defined(Q_OS_HARMATTAN)
        text.setCodec("utf-8");//设置保存文件内容的编码，meego必须为utf-8，不然读取文件时会乱码
        QString temp="<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+coding+"\" />\n<script src=\"/opt/ithome/qml/general/jquery.min1.8.0.js\"></script>\n";
        string.append("\n<script>$(\"img\").attr(\"src\",\"/opt/ithome/qml/general/it.png\");$(\"img\").attr(\"loading-url\",\"/opt/ithome/qml/general/loading.png\");</script>\n<script src=\"/opt/ithome/qml/general/lazyLoadImage.js\"></script>");
#elif defined(Q_OS_S60V5)//判断qt的版本
        QString temp="<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+coding+"\" />\n";
        string.append("\n<script>var obj=document.getElementsByTagName(\"img\");for(var i=0;i<obj.length;i++){obj[i].setAttribute(\"src\",\""+dirTemp.absolutePath ()+"/qml/general/it.png\");obj[i].setAttribute(\"loading-url\",\""+dirTemp.absolutePath ()+"/qml/general/loading.png\");}</script>\n<script src=\""+dirTemp.absolutePath ()+"/qml/symbian-v5/lazyLoadImage.js\"></script>");
#elif defined(Q_OS_S60V3)//判断qt的版本
        QString temp="<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+coding+"\" />\n";
        string.append("\n<script>var obj=document.getElementsByTagName(\"img\");for(var i=0;i<obj.length;i++){obj[i].setAttribute(\"src\",\""+dirTemp.absolutePath ()+"/qml/general/it.png\");obj[i].setAttribute(\"loading-url\",\""+dirTemp.absolutePath ()+"/qml/general/loading.png\");}</script>\n<script src=\""+dirTemp.absolutePath ()+"/qml/symbian-v3/lazyLoadImage.js\"></script>");
#else
        QString temp="<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+coding+"\" />\n<script src=\""+dirTemp.absolutePath ()+"/qml/general/jquery.min1.8.0.js\"></script>\n";
        string.append("\n<script>$(\"img\").attr(\"src\",\""+dirTemp.absolutePath ()+"/qml/general/it.png\");$(\"img\").attr(\"loading-url\",\""+dirTemp.absolutePath ()+"/qml/general/loading.png\");</script>\n<script src=\""+dirTemp.absolutePath ()+"/qml/general/lazyLoadImage.js\"></script>");
#endif
        disposeHref(string);//修改超链接
        disposeLetvVideo(string);//解析乐视视频
        disposeYoukuVideo(string);//解析优酷视频
        //text<<temp<<string;
        //qDebug()<<"file size:"<<string.size();
        //file.close();
        //setting->setValue("cache_size",setting->getValue("cache_size",0).toLongLong()+string.size()+80);
        //saveNoImageModel(sid,temp+string);
        string.insert(0,temp);
        int pos=string.indexOf("<img");
        while(pos!=-1)
        {
            //string.insert(pos-1," align=\"center\"");
            //pos+=15;
            int begin=string.indexOf("src=",pos);
            int end=string.indexOf("\"",begin+10);
            QString myurl=string.mid(begin+5,end-begin-5);
            QString id="\""+myurl.mid(myurl.lastIndexOf("/")+1,myurl.lastIndexOf(".")-myurl.lastIndexOf("/")-1)+"\"";
            QString suffix="\""+myurl.mid(myurl.lastIndexOf("."),myurl.length()-myurl.lastIndexOf("."))+"\"";
            string.replace(begin,3,"myurl");
            temp=" onclick=imageClick(id) id="+id+" suffix="+suffix+" data-url=\"\" loading-url=\"\" ";
            string.insert(pos+5,temp);
            pos=string.indexOf("<img",pos+5);
        }
        text<<string;
        file.close();
        setting->setValue("cache_size",setting->getValue("cache_size",0).toLongLong()+string.size());
    }
}
/*void Cache::saveNoImageModel(const QString sid, QString string)
{
    file.setFileName(prefix+"/cache/"+sid+"/content_noImageModel.html");
    if(!file.exists())
    {
        file.open(QIODevice::WriteOnly);
        QTextStream text(&file);

#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
        text.setCodec("utf-8");
#endif
        int pos=string.indexOf("<img");
        while(pos!=-1)
        {
            int begin=string.indexOf("src=",pos);
            int end=string.indexOf("\"",begin+10);
            QString myurl=string.mid(begin+5,end-begin-5);
            QString id="\""+myurl.mid(myurl.lastIndexOf("/")+1,myurl.lastIndexOf(".")-myurl.lastIndexOf("/")-1)+"\"";
            QString suffix="\""+myurl.mid(myurl.lastIndexOf("."),myurl.length()-myurl.lastIndexOf("."))+"\"";
            string.replace(begin,3,"myurl");
            QString temp=" onclick=\"if(src.indexOf('qml/general/it.png')>0) window.qml.loadImage($('#'+id).attr('myurl'),id,$('#'+id).attr('suffix'));else window.qml.enlargeImage(src);\" id="+id+" suffix="+suffix+" ";
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
            string.insert(pos+5,"src=\"/opt/ithome/qml/general/it.png\" "+temp);//onclick=\"if(src!=id) src=id;else window.qml.enlargeImage(src);\"
#else
            string.insert(pos+5,"src=\"../../qml/general/it.png\" "+temp);//onclick=\"if(src!=id) src=id;else window.qml.enlargeImage(src);\"
#endif
            pos=string.indexOf("<img",pos+5);
        }
        text<<string;
        file.close();
        setting->setValue("cache_size",setting->getValue("cache_size",0).toLongLong()+string.size());
    }
}*/

QString Cache::getTitle(const QString sid,const QString string)
{
    file.setFileName(prefix+"/cache/"+sid+"/title.txt");
    if(file.exists())
    {
        file.open(QIODevice::ReadOnly);
        QTextStream text(&file);

        QString string=text.readAll();
        //qDebug()<<string;
        file.close();
        return string;

    }else return string;
}


/*QString Cache::getContent_noImage(const QString sid)
{
    file.setFileName(prefix+"/cache/"+sid+"/content_noImage.html");
    if(file.exists())
    {
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
        return prefix+"/cache/"+sid+"/content_noImage.html";
#else
        return "../../cache/"+sid+"/content_noImage.html";
#endif
    }else return "-1";
}*/
QString Cache::getContent_noImageModel(const QString sid)
{
    file.setFileName(prefix+"/cache/"+sid+"/content_noImageModel.html");
    if(file.exists())
    {
#if defined(Q_OS_HARMATTAN)
        return prefix+"/cache/"+sid+"/content_noImageModel.html";
#else
        return prefix+"/cache/"+sid+"/content_noImageModel.html";
#endif
    }else return "-1";
}

QString Cache::getContent_image(const QString sid)
{
    //m_sid=sid;
    file.setFileName(prefix+"/cache/"+sid+"/content_image.html");
    if(!file.exists())
    {
        //qDebug()<<sid<<"is no-exists";
        file.setFileName(prefix+"/cache/"+sid+"/content_noImageModel.html");
        if(file.exists())
        {
            file.open(QIODevice::ReadOnly);
            QTextStream text(&file);
            //content=text.readAll();
            QString data=text.readAll();
            file.close();
            //qDebug()<<content;
            //editContent();
            int begin=data.indexOf("enlargeImage(src);");//查找第一个img标签
            while(begin!=-1)
            {
                int temp1=data.indexOf("id=",begin)+4;
                int temp2=data.indexOf("\"",temp1);
                QString image_id=data.mid(temp1,temp2-temp1);//获取图片标签的id
                temp1=data.indexOf("suffix=",temp2)+8;
                temp2=data.indexOf("\"",temp1);
                QString suffix=data.mid(temp1,temp2-temp1);//获取图片的格式
                temp1=data.indexOf("data-url=",begin)+10;
                data.insert(temp1,image_id+suffix);//插入真实的图片地址
                temp1=data.indexOf("myurl=",temp2)+7;
                temp2=data.indexOf("\"",temp1);
                QString url=data.mid(temp1,temp2-temp1);//获取图片的地址
                imageDownload(sid,url,image_id,suffix);
                begin=data.indexOf("enlargeImage(src);",temp2);//查找下一个img标签
            }
            contentImage=data;
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
            return prefix+"/cache/"+sid+"/content_noImageModel.html";
#else
            return prefix+"/cache/"+sid+"/content_noImageModel.html";
#endif
        }else return "-1";
    }else{
        qDebug()<<QString::fromUtf8("保存有本地图片的新闻缓存文件存在，直接返回文件地址");
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
        return prefix+"/cache/"+sid+"/content_image.html";
#else
        return prefix+"/cache/"+sid+"/content_image.html";
#endif
    }
}
void Cache::disposeHref(QString &string,int i)
{
    int begin=string.indexOf("href=",i);
    while(begin!=-1)
    {
        int end=string.indexOf("\"",begin+10);
        if(string.indexOf("<img",end)>string.indexOf("</a>",end)||string.indexOf("<img",end)==-1)
            string.insert(end+1," onclick=\"window.qml.openUrl(this.href)\" ");
        int temp=string.indexOf(">",end+1);
        if(string.indexOf("target=\"_blank\"",end+1)>temp)
            string.insert(end+1," target=\"_blank\" ");
        begin=string.indexOf("href=",end+30);
    }
}
void Cache::disposeLetvVideo(QString &string, int i)
{
    int begin=string.indexOf("<div",i);
    while(begin!=-1)
    {
        string.insert(begin+5,"onclick='window.qml.openVideoUrl(\"letv\")' ");
        //disposeLetvVideo(string,begin+20);
        begin=string.indexOf("<div",begin+20);
    }
}
void Cache::disposeYoukuVideo(QString &string, int i)
{
    int begin=string.indexOf("<video",i);
    while(begin!=-1)
    {
        string.insert(begin+7,"onclick=\"window.qml.openVideoUrl(this.src)\" ");
        //disposeYoukuVideo(string,begin+20);
        begin=string.indexOf("<video",begin+20);
    }
}

/*void Cache::editContent()
{
    //qDebug()<<m_sid<<":\n"<<content;
    int begin=content.indexOf("<img",count);
    count=begin+1;
    if(begin!=-1){
        content.insert(begin+5,"onclick=\"window.qml.enlargeImage(this.src)\" ");
        int temp=content.indexOf("\" />",begin);
        int temp2=content.indexOf("http",begin);
        //int temp3=content.indexOf("_",begin)+1;
        QString temp_string=content.mid(temp2,temp-temp2);
        if(temp_string.indexOf("jpg")==-1)
            if(temp_string.indexOf("png")==-1)
            {
                editContent();
                return;
            }
        int temp3=temp_string.lastIndexOf("/")+1;
        //qDebug()<<"temp:"<<temp<<";temp3:"<<temp3<<";"<<content.count();
        QString image_src=temp_string.mid(temp3,temp_string.size()-temp3);
        imageName=prefix+"/cache/"+m_sid+"/"+image_src;
        if(m_canclePost){//判断用户是否停止了请求
            m_canclePost=false;
            return;
        }
        file.setFileName(imageName);
        if(!file.exists())//如果文件不存在就下载
        {
            qDebug()<<"post url:"<<temp_string;
            manager->get(QNetworkRequest(QUrl(temp_string)));//
        }
        //count=temp;
        //qDebug()<<count<<"is 2";
        content.replace(temp2,temp-temp2,"./"+image_src);//"file:///
    }else{
        file.setFileName(prefix+"/cache/"+m_sid+"/content_image.html");
        file.open(QIODevice::WriteOnly);
        QTextStream text(&file);

#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
        text.setCodec("utf-8");
#endif
        text<<content;
        file.close();
        setting->setValue("cache_size",setting->getValue("cache_size",0).toLongLong()+content.size()+80);
        //qDebug()<<content;
        if(m_canclePost){
            m_canclePost=false;
            return;
        }
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
        emit content_image(prefix+"/cache/"+m_sid+"/content_image.html");
#else
        emit content_image("../../cache/"+m_sid+"/content_image.html");
#endif
        //count=0;
    }
}
void Cache::replyFinished(QNetworkReply *replys)
{
    //qDebug()<<haha->errorString();
    if(replys->error() == QNetworkReply::NoError)
    {
        QByteArray temp=replys->readAll();
        //qDebug()<<"image size:"<<temp.size();
        QImage image;
        image.loadFromData(temp);
        file.setFileName(imageName);
        if(!file.exists())
            image.save(imageName);
        setting->setValue("cache_size",setting->getValue("cache_size",0).toLongLong()+temp.size());
        editContent();//再次调用解析下一个图片地址
    }
}*/
void Cache::clearCache(QString dirPath , bool deleteSelf , bool deleteHidden /*= false*/)
{
    emit removeCache();
}

void Cache::cancleDownloadImage()
{
    emit cancleDownloadImages();//发送停止下载图片的信号到新的线程
}
void Cache::imageDownload(const QString id_content, const QString url, const QString id_image, const QString suffix)
{
    emit imageDownloads(id_content, url,id_image, suffix);//发送下载图片的信号到新的线程
}

Cache::~Cache()
{
    //manager->deleteLater();
    if(mythread)
    {
        mythread->terminate();
        mythread->wait();
        threadDownloadImage->deleteLater();
    }
    if(mythread_removeCache)
    {
        mythread_removeCache->terminate();
        mythread_removeCache->wait();
        reCache->deleteLater();
    }
}


#include <QThread>

RemoveCache::RemoveCache(QObject *parent) :
    QObject(parent)
{
}
bool RemoveCache::clearCache(QString dirPath , bool deleteSelf , bool deleteHidden /*= false*/)
{
    qDebug()<<QString::fromUtf8("清理缓存的线程id:")<<QThread::currentThread();
    QDir entry (dirPath);
    if(!entry.exists()||!entry.isReadable())
    {
        emit removeResult(false);
        return false;
    }
    entry.setFilter(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot | QDir::Hidden);
    QFileInfoList dirList = entry.entryInfoList();
    bool bHaveHiddenFile = false;

    if(!dirList.isEmpty())
    {
        for( int i = 0; i < dirList.size() ; ++i)
        {
            QFileInfo info = dirList.at(i);

            if(info.isHidden() && !deleteHidden)
            {
                bHaveHiddenFile = true;
                continue;
            }

            QString path = info.absoluteFilePath();

            if(info.isDir())
            {
                if(!clearCache(path, true, deleteHidden))
                {
                    emit removeResult(false);
                    return false;
                }
            }
            else if(info.isFile())
            {
                if(!QFile::remove(path))
                {
                    emit removeResult(false);
                    return false;
                }
            }
            else
            {
                emit removeResult(false);
                return false;
            }
        }
    }

    if(deleteSelf && !bHaveHiddenFile)
    {
        if(!entry.rmdir(dirPath))
        {
            emit removeResult(false);
            return false;
        }
    }
    emit removeResult(true);
    return true;
}
