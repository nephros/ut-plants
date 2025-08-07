// **************************************************************************
// Model for handling locally stored plants managed by this app
// **************************************************************************
// MIT License
// Copyright © 2022 Patrick Fial
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the “Software”), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright notice and this
// permission notice shall be included in all copies or substantial portions of the Software. THE
// SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// **************************************************************************
// includes
// **************************************************************************

#pragma once

#include <QAbstractListModel>
#include <QDir>
#include <QImage>
#include <QObject>
#include <QLocale>

#include "identification.hpp"
#include "network.hpp"
#include "plant.hpp"

// **************************************************************************
// namespace plants
// **************************************************************************

namespace plants
{
// **************************************************************************
// struct PlantSorter
// **************************************************************************

struct PlantSorter
{
   bool operator()(Plant* a, Plant* b) const
   {
      return a->added.toMSecsSinceEpoch()/1000 > b->added.toMSecsSinceEpoch()/1000;
   }
};

template <typename T>
using ResultCallback = std::function<void(QString, T)>;

// **************************************************************************
// class PlantsModel
// **************************************************************************

class PlantsModel : public QAbstractListModel
{
   enum RoleNames
   {
      PlantRole = Qt::UserRole + 1
   };

   Q_OBJECT
   Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
   Q_PROPERTY(QString language MEMBER language NOTIFY languageChanged)

public:
   static PlantsModel* getInstace()
   {
      return instance;
   }

public:
   explicit PlantsModel(QObject* parent = nullptr);

   // QAbstractListModel

   QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
   int rowCount(const QModelIndex& parent = QModelIndex()) const;
   QHash<int, QByteArray> roleNames() const;

   // QML interaction

   Q_INVOKABLE QString init();
   Q_INVOKABLE void reload();
   Q_INVOKABLE void setApiKey(QString key)
   {
      identificator.setApiKey(key);
   }
   Q_INVOKABLE void setLanguage(QString language)
   {
      identificator.setLanguage(language);
   }

   Q_INVOKABLE QString savePlant(QVariantMap identificationResult);
   Q_INVOKABLE QString deletePlant(QString id);
   Q_INVOKABLE void identifyPlant(QVariantList request);

   Plant* getPlant(QString id)
   {
      return mItemMap.count(id) ? mItemMap[id] : nullptr;
   }

   Q_INVOKABLE QVariantMap availableLanguages() const;

signals:
   void countChanged();
   void identificationResult(QString error, QVariantList result);
   void availableLanguagesChanged(QStringList languages);
   void languageChanged(QString language);

private:
   QString getDataPath() const;

   static PlantsModel* instance;

   bool storageReady;
   PlantSorter plantSorter;

   std::vector<Plant*> mItems;
   std::map<QString, Plant*> mItemMap;
   QDir plantsDir;

   network::Network net;
   Plants plants;
   Identification identificator;

   QStringList languages;
   QString language;
};

} // namespace plants
