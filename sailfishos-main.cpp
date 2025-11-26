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

#include <sailfishapp.h>

#include "src/plantsimageprovider.hpp"
#include "src/plantsmodel.hpp"

void registerBus() {
   QDBusConnection bus = QDBusConnection::sessionBus();
   if (bus.registerService(QStringLiteral("s710.plants"))) {
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
       qmlPath = SailfishApp::pathToMainQml();
   }

   // only load custom translators if running with Resources:
   if (qmlPath.startsWith("qrc:") || qmlPath.startsWith(":")) {
       QTranslator translator;
       if(translator.load(QLocale(), QStringLiteral("harbour-plants"), QStringLiteral("_"), QLatin1String(":/i18n"))) {
           QCoreApplication::installTranslator(&translator);
           qDebug() << "Successfully loaded translations for" << QLocale::system().name().split('_').at(0);
       } else {
           qWarning() << "Failed to load translation for" << QLocale::system().name().split('_').at(0);
       }
   }

   //view->setSource(QUrl("qrc:/harbour-plants.qml"));
   //view->setSource(SailfishApp::pathToMainQml());
   view->setSource(qmlPath);
   view->show();

   // Sailfish Share:Registering the service after QML is loaded
   registerBus();

   return app->exec();
}
