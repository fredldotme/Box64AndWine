/*
 * Copyright (C) 2023  Alfred Neumayer
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * Box64AndWine is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QCoreApplication>
#include <QDebug>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QString>
#include <QVariant>

#include <stdio.h>
#include <unistd.h>

#include "featuremanager.h"

static const QString box64conf = QStringLiteral("/opt/click.ubuntu.com/box64andwine.fredldotme/current/box64.conf");
static const QString wine64conf = QStringLiteral("/opt/click.ubuntu.com/box64andwine.fredldotme/current/wine64.conf");

FeatureManager::FeatureManager()
{

}

bool FeatureManager::enable()
{
    if (m_enabled)
        return false;

    m_commandRunner->sudo(QStringList{"mount", "-o", "remount,rw", "/"});

    const QByteArray box64contents = m_commandRunner->readFile(box64conf);
    m_commandRunner->writeFile("/etc/binfmt.d/box64.conf", box64contents);

    const QByteArray wine64contents = m_commandRunner->readFile(wine64conf);
    m_commandRunner->writeFile("/etc/binfmt.d/wine64.conf", wine64contents);

    m_commandRunner->sudo(QStringList{"mount", "-o", "remount,ro", "/"});

    m_enabled = true;
    emit enabledChanged();
    return true;
}

bool FeatureManager::disable()
{
    if (!m_enabled)
        return false;

    m_enabled = false;
    emit enabledChanged();
    return true;
}
