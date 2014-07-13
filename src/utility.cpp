#include "utility.h"
#include <QDebug>

Utility::Utility(QObject *parent) :
    QObject(parent)
{
    imageShowing="";

    queue_begin=queue_end=0;
    manager = new QNetworkAccessManager(this);
    connect(manager, SIGNAL(finished(QNetworkReply*)),this, SLOT(replyFinished(QNetworkReply*)));

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
    m_cacheImagePrefix = prefix+"/cache/";
    
    favoritePath=prefix+"/favorite.txt";
    
    QDir temp;
    QFileInfo info(prefix);
    if(!info.exists())
        if(!temp.mkpath(prefix))
            qDebug()<<prefix<<QString::fromUtf8("路径创建失败");
}

QString Utility::cacheImagePrefix()
{
    return m_cacheImagePrefix;
}

bool Utility::imageIsShow(const QString name)
{
    if(imageShowing.indexOf(name)!=-1)
        return true;
    else
        return false;
}
void Utility::imageToShow(const QString name)
{
    imageShowing.append(name+",");
}


void Utility::postHttp(const QString postMode,const QString postUrl,const QString postData)
{
    QTextCodec *codec = QTextCodec::codecForName("gb2312");
    QByteArray array=codec->fromUnicode(postData);
    QNetworkRequest request;
    request.setUrl(QUrl(postUrl));
    request.setRawHeader("Content-Type","application/x-www-form-urlencoded;charset=gb2312");/*设置http请求头，不然塞班真机会出现问题*/
    if(postMode=="POST")
    {
        manager->post(request,array);
    }else if(postMode=="GET"){
        manager->get(request);
    }else qDebug()<<"暂时没有支持其他种类的http请求";
}
void Utility::replyFinished(QNetworkReply *replys)
{
    //qDebug()<<haha->errorString();
    if(replys->error() == QNetworkReply::NoError)
    {
        QTextCodec *codec = QTextCodec::codecForName("gb2312");
        QString string=codec->toUnicode(replys->readAll());
        emit postOk(string);
    }
}

//#ifdef Q_OS_SYMBIAN
//void Utility::launchPlayer(const QString &url)
//{
     //QDesktopServices::openUrl(QUrl(url));
//}
//#endif
bool Utility::inQueue(const QString sid)
{
    //qDebug()<<"in queue data:"<<sid<<"end is:"<<queue_end;
    if(queue_end==queue_begin&&queue[queue_begin]!="") return false;
    else{
        queue[queue_end]=sid;
        queue_end=(queue_end+1)%50;
    }
    return true;
}
QString Utility::outQueue()
{
    int temp=(queue_begin+1)%50;
    if(temp==queue_end+1){
        //queue_begin=queue_end=0;
        return "null";
    }
    else{
        QString string=queue[queue_begin];
        queue[queue_begin]="";
        //qDebug()<<"out queue data:"<<string<<"begin is:"<<queue_begin;
        queue_begin=temp;
        return string;
    }
}
void Utility::consoleLog(QString string)
{
    qDebug()<<string;
}
QString Utility::saveImageToLocality(const QString imageSrc)
{
    QString imageName=imageSrc.mid(imageSrc.lastIndexOf("/")+1,imageSrc.length()-imageSrc.lastIndexOf("/")-1);
#if defined(Q_OS_HARMATTAN)
    QString toSrc="/home/user/MyDocs/Pictures/";
#elif defined(Q_OS_LINUX)
    QString toSrc=QDir::homePath();
#else
    QString toSrc="E:/Images/";
#endif
    QFileInfo fileinfo(toSrc);
    if(!fileinfo.isDir())
    {
        QDir temp;
        temp.mkdir(toSrc);
    }
    QFile file(toSrc+imageName);
    if(!file.exists())
    {
        file.setFileName(prefix+"/"+imageSrc.mid(imageSrc.indexOf("cache"),imageSrc.length()-imageSrc.indexOf("cache")));
        if (file.exists()){
            if(file.copy(toSrc+imageName))
                return QString::fromUtf8("成功保存到")+toSrc+imageName;
            else return QString::fromUtf8("保存失败！");
        }else return QString::fromUtf8("您要保存的文件不存在");
        
    }else{
        return QString::fromUtf8("您要保存的文件已经存在");
    }
}
void Utility::setClipboard(const QString string)
{
    QClipboard *board = QApplication::clipboard();
    board->setText(string);
    qDebug()<<QString::fromUtf8("复制内容成功");
}
void Utility::setCss(const QString string,const int width)//width为当前屏幕宽度
{
    //qDebug()<< QString::fromUtf8("css的width是：")<<width;
    QFile file(string);
    if(file.exists())
    {
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
        file.open(QIODevice::ReadOnly);
#else
        file.open(QIODevice::ReadWrite);
#endif
        QString string2=file.readAll();
        int begin=string2.indexOf("width:"),end=0;
        while(begin!=-1)
        {
            end=string2.indexOf("px",begin);
            if(string2.mid(begin+6,end-begin-6).toInt()>200)
                string2.replace(begin+6,end-begin-6,QString::number(width));
            begin=string2.indexOf("width:",end);
        }
#if defined(Q_OS_HARMATTAN)
        file.close();
        QString path=prefix+"/temp.css";
        QFile temp(path);
        if(temp.exists()) temp.remove();//如果存在则删除
        temp.open(QIODevice::ReadWrite);
        QTextStream text(&temp);
        text<<string2;
        temp.close();
        qDebug()<<QString::fromUtf8("css被设置为：")<<path;
        QWebSettings::globalSettings()->setUserStyleSheetUrl(QUrl::fromLocalFile(path));
#else
        QTextStream text(&file);
        text.seek(0);//设置文件指针为头
        text<<string2;
        file.close();
        qDebug()<<QString::fromUtf8("css被设置为：")<<string;
        QWebSettings::globalSettings()->setUserStyleSheetUrl(QUrl::fromLocalFile(string));
#endif
    }
}

QString Utility::getContent_text(const QString sid)
{
    QFile file(prefix+"/cache/"+sid+"/content_noImageModel.html");
    if(file.exists())
    {
        file.open(QIODevice::ReadOnly);
        QTextStream text(&file);
        QString temp=text.readAll();
        int m=temp.indexOf("<script>");
        int n=0;
        if(m!=-1){
            n=temp.indexOf("</script>");
            if(n!=-1)
                temp.replace(m,m-n+9,"");
        }
        m=temp.indexOf("<");
        while(m!=-1)
        {
            n=temp.indexOf(">",m);
            if(n!=-1)
            {
                temp.replace(m,n-m+1,"");
            }
            m=temp.indexOf("<",m);
        }
        return temp;
    }else return "-1";
}


QString Utility::addMyLikeNews(const QString newsid,const QString item,bool isRecursion)
{
    qDebug()<<item;
    QString fileName=prefix+"/like.xml";
    QFile file(fileName);
    if(!file.exists()&&QFile::exists(prefix+"/backupLike.xml"))
    {
        if(!QFile::copy(prefix+"/backupLike.xml",fileName))
            return QString::fromUtf8("操作失败，请重试");
    }
    if(!file.open(QIODevice::ReadWrite))
        return QString::fromUtf8("操作失败，请重试");
    QTextStream text(&file);
    QString string = text.readAll();
    if(string=="")
    {
        string="<?xml version=\"1.0\" encoding=\""+coding+"\"?>\r\n<rss version=\"2.0\">\r\n    <channel>\r\n        <item>\r\n"+item+"        </item>\r\n    </channel>\r\n</rss>";
    }else{
        int pos=string.lastIndexOf("<channel>")+9;
        if(pos==8)
        {
            file.remove();
            file.close();
            QFile backup(prefix+"/backupLike.xml");
            if((isRecursion&&backup.exists()))//如果是递归调用
            {
                backup.remove();
                if(QFile::exists(favoritePath))
                    QFile::remove(favoritePath);//删除所有收藏
                return QString::fromUtf8("文件被破坏，数据已丢失");
            }
            if(!backup.exists())//或者是备份的文件不存在
            {
                if(QFile::exists(favoritePath))
                    QFile::remove(favoritePath);//删除所有收藏
                return QString::fromUtf8("文件被破坏，数据已丢失");
            }
            backup.copy(fileName);//从备份恢复文件
            return addMyLikeNews(newsid,item,true);//递归调用
        }
        string.insert(pos,"\r\n        <item>\r\n"+item+"        </item>");
        text.seek(0);
    }
    int nbsp=string.indexOf("&nbsp");
    while(nbsp!=-1)
    {
        string.replace(nbsp,5," ");
        nbsp=string.indexOf("&nbsp");
    }
    text.setCodec(coding.toStdString().c_str());//设置要保存的编码
    text<<string;
    if(QFile::exists(prefix+"/backupLike.xml"))
        QFile::remove(prefix+"/backupLike.xml");
    file.copy(prefix+"/backupLike.xml");//备份文件
    file.close();
    if(setFavorite(newsid,true))
        return QString::fromUtf8("操作完成");
    else
        return QString::fromUtf8("操作失败，请重试");
}

QString Utility::deleteMyLikeNews(const QString newsid,bool isRecursion)
{
    QString fileName=prefix+"/like.xml";
    QFile file(fileName);
    if(!file.exists())//如果文件不存在
    {
        if(!QFile::exists(prefix+"/backupLike.xml"))//判断备份的文件是否存在
        {
            if(QFile::exists(favoritePath))
                QFile::remove(favoritePath);//删除所有收藏
            return QString::fromUtf8("文件被破坏，数据已丢失");
        }
        if(!QFile::copy(prefix+"/backupLike.xml",fileName))
            return QString::fromUtf8("操作失败，请重试");
    }
    if(!file.open(QIODevice::ReadWrite))
        return QString::fromUtf8("操作失败，请重试");
    QTextStream text(&file);
    QString string = text.readAll();

    int begin=string.indexOf("<newsid>"+newsid);
    if(begin==-1)
        return QString::fromUtf8("操作完成");
    begin=string.lastIndexOf("<item>",begin);
    int end=string.indexOf("</item>",begin)+7;
    if(begin==-1||end==6)
    {
        file.remove();
        file.close();
        QFile backup(prefix+"/backupLike.xml");
        if((isRecursion&&backup.exists()))//如果是递归调用
        {
            backup.remove();
            backup.close();
            if(QFile::exists(favoritePath))
                QFile::remove(favoritePath);//删除所有收藏
            return QString::fromUtf8("文件被破坏，数据已丢失");
        }
        if(!backup.exists())//或者是备份的文件不存在
        {
            if(QFile::exists(favoritePath))
                QFile::remove(favoritePath);//删除所有收藏
            return QString::fromUtf8("文件被破坏，数据已丢失");
        }
        backup.copy(fileName);//从备份恢复文件
        return deleteMyLikeNews(newsid,true);//递归调用
    }
    string.replace(begin,end-begin+9,"");//删除这个新闻，多加的删除是空格和换行
    text.setCodec(coding.toStdString().c_str());//设置要保存的编码
    file.resize(0);//清空文件内容
    text<<string;//然后再写入
    if(QFile::exists(prefix+"/backupLike.xml"))
        QFile::remove(prefix+"/backupLike.xml");
    file.copy(prefix+"/backupLike.xml");//备份文件
    file.close();
    if(setFavorite(newsid,false))
        return QString::fromUtf8("操作完成");
    else
        return QString::fromUtf8("操作失败，请重试");
}

bool Utility::getFavorite(QString newsid)
{
    QFile file(favoritePath);
    if(!file.exists()) return false;
    else{
        file.open(QIODevice::ReadOnly);
        QString string=file.readAll();
        file.close();
        if(string.indexOf("<newsid>"+newsid+"</newsid>")==-1)//判断是否被收藏
            return false;
        else
            return true;
    }
}

bool Utility::setFavorite(QString newsid,bool value)
{
    QFile file(favoritePath);
    if(!file.open(QIODevice::ReadWrite))
        return false;//打开失败就返回
    else{
        QTextStream text(&file);
        QString string=text.readAll();
        file.close();
        if(value)
        {
            if(string.indexOf("<newsid>"+newsid+"</newsid>")==-1)
                string.append("<newsid>"+newsid+"</newsid>\r\n");
        }
        else{
            int begin=string.indexOf("<newsid>"+newsid);
            if(begin!=-1)
            {
                int end=string.indexOf("</newsid>",begin)+10;
                string.replace(begin,end-begin,"");
            }
        }
        if(file.exists())
            if(!file.remove())
                return false;//如果删除失败就返回
        if(!file.open(QIODevice::ReadWrite))
            return false;//打开失败就返回
        text.seek(0);
        text<<string;
    }
    file.close();
    return true;
}

bool Utility::getFavoriteIsNull()
{
    QFile file(favoritePath);
    if(file.exists()&&QFile::exists(prefix+"/like.xml"))
    {
        file.open(QIODevice::ReadOnly);
        QString string=file.readAll();
        file.close();
        if(string.indexOf("<newsid>")==-1)
            return true;
        else
            return false;
    }else
        return true;//为空返回true
}

Utility::~Utility()
{
    manager->deleteLater();
}
