#ifndef MYIMAGE_H
#define MYIMAGE_H

#include <QDeclarativeItem>
#include <QImage>
#include <QString>
#include <QtNetwork>
#include <QByteArray>
#include <QFile>
#include <QFileInfo>
#include "settings.h"
class MyImage : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString sid READ sid WRITE setSid NOTIFY sidChanged)
public:
    explicit MyImage(QObject *parent = 0);
    ~MyImage();

private:

    QString m_source;
    QNetworkAccessManager *manager;
    QString source();
    void setSource(const QString string);
    QString m_sid,prefix,imageQmlSrc;//imageQmlSrc记录着图片相对于qml的路径
    void setSid(QString newid);
    QString sid();
private slots:
    void replyFinished(QNetworkReply* replys);
signals:
    void sourceChanged();
    void sidChanged();
    void imageClose(const QString imageSrc);
public slots:
    
};

#endif // MYIMAGE_H
