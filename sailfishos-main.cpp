// SPDX-FileCopyrightText: 2025 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0
// SPDX-License-Identifier: MIT

#include <QQuickView>
#include <QScopedPointer>
#include <QtQuick>
#include <QString>
#include <QUrl>
#include <QDebug>
#include <QDBusConnection>
#include <QDBusError>
#include <QDBusAbstractAdaptor>

#include <sailfishapp.h>

#include "src/plantsimageprovider.hpp"
#include "src/plantsmodel.hpp"

#ifndef APP_DBUS_SERVICE
#define APP_DBUS_SERVICE "s710.plants"
#endif
#ifndef APP_DBUS_PATH
#define APP_DBUS_PATH "/s710/plants"
#endif

/* Adaptor to provide the SFOS/FDO DBus-Activation interface */
class BusAdaptor : public  QDBusAbstractAdaptor
{
   Q_OBJECT
   Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Application")
public:
   BusAdaptor(QGuiApplication *application, QQuickView *view)
        : QDBusAbstractAdaptor(application), app(application), view(view)
    {
    }
public slots:
   /* To test:
      busctl --user call s710.plants  /s710/plants org.freedesktop.Application Activate a{sv} 0
   */
   void Activate( const QVariantMap &platform_data ) const
   {
      Q_UNUSED(platform_data)
      view->show();
      QMetaObject::invokeMethod(view->rootObject(), "activate");
   }
   /* To test:
      busctl --user call s710.plants  /s710/plants org.freedesktop.Application Open asa{sv} 1 "file:///home/nemo/Pictures/IMG20250923.png" 0
   */
   void Open( const QStringList &uris, const QVariantMap &platform_data ) const
   {
      Q_UNUSED(platform_data);

      QStringList images = uris.filter(QRegularExpression("^file:"));
      //qDebug() << "Got image urls:" << images.count();
      if (!images.isEmpty()) {
         QObject *object = view->rootObject();
         QObject *rqPage = object->findChild<QQuickItem*>(QStringLiteral("requestPage"));
         if (rqPage) {
            qDebug() << "Request page is open, handy!";
            rqPage->setProperty("sharedImages", images);
         } else {
            qDebug() << "Request page not open!";
            QMetaObject::invokeMethod(object, "openImageUrls", Q_ARG(QVariant, images));
         }
         QMetaObject::invokeMethod(object, "activate");
      }
      view->show();
   }
private:
   QGuiApplication *app;
   QQuickView *view;
};

#include "sailfishos-main.moc"

/* Register a service on the bus, for Sailfish::Share */
void registerBus() {
   QDBusConnection bus = QDBusConnection::sessionBus();
   if (bus.registerService(APP_DBUS_SERVICE)) {
       qDebug() << "Successfully registered DBus service.";
   } else {
       QDBusError e = bus.lastError();
       qWarning() << "Failed to register DBus service:"
                                << QDBusError::errorString(e.type())
                                << e.name()
                                << e.message();
   }
}
int main(int argc, char *argv[])
{
   QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
   QScopedPointer<QQuickView> view(SailfishApp::createView());

   app->setOrganizationName("s710");
   app->setApplicationName("plants");
   app->setApplicationVersion("0.0.0");

   qmlRegisterType<plants::PlantsModel>("PlantsModel", 1, 0, "PlantsModel");

   view->engine()->addImageProvider(QLatin1String("plants"), new plants::PlantsImageProvider());

   QUrl qmlPath;
   const QString envPath = QString::fromUtf8(qgetenv("PLANTS_QML_ROOT_DIR"));
   if (!envPath.isEmpty()) {
       const QString wantDir = QDir::cleanPath(envPath);
       // in case we have imports there:
       view->engine()->addImportPath(wantDir);
       qmlPath = QUrl::fromLocalFile(wantDir + "/harbour-plants.qml");
       qInfo() << "QML Path set from Environment:" << wantDir;
   } else {
       //qmlPath = SailfishApp::pathToMainQml();
       qmlPath = QUrl("qrc:/harbour-plants.qml");
   }

   // only load custom translators if running with Resources:
   if (qmlPath.toString().startsWith("qrc:") || qmlPath.toString().startsWith(":")) {
       QTranslator translator;
       if(translator.load(QLocale(), QStringLiteral("harbour-plants"), QStringLiteral("_"), QLatin1String(":/i18n"))) {
           QCoreApplication::installTranslator(&translator);
           qDebug() << "Successfully loaded translations for" << QLocale::system().name().split('_').at(0);
       } else {
           qWarning() << "Failed to load translation for" << QLocale::system().name().split('_').at(0);
       }
   }

   view->setSource(qmlPath);

   // create the FDO activation adapter
   new BusAdaptor(app.data(), view.data());
   QDBusConnection::sessionBus().registerObject(APP_DBUS_PATH, app.data());
   // Sailfish Share:Registering the service after QML is loaded
   registerBus();

   if (!app->arguments().contains(QStringLiteral("-prestart"))) {
       view->show();
   }

   return app->exec();
}

