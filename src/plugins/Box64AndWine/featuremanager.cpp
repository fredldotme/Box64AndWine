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
#include <QDir>
#include <QFile>
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

void FeatureManager::recheckSupport()
{
    const QByteArray supportedFilesystems = m_commandRunner->readFile("/proc/filesystems");
    m_supported = supportedFilesystems.contains("binfmt_misc");
    emit supportedChanged();
}

bool FeatureManager::enable()
{
    if (m_enabled)
        return false;

    m_commandRunner->sudo(QStringList{"/usr/bin/mount", "-o", "remount,rw", "/"}, true);
    m_commandRunner->sudo(QStringList{"/usr/bin/cp", box64conf, "/etc/binfmt.d/box64.conf"}, true);
    m_commandRunner->sudo(QStringList{"/usr/bin/cp", wine64conf, "/etc/binfmt.d/wine64.conf"}, true);
    m_commandRunner->sudo(QStringList{"/usr/bin/mount", "-o", "remount,ro", "/"}, true);
    m_commandRunner->sudo(QStringList{"/usr/bin/systemctl", "restart", "systemd-binfmt"}, true);

    m_enabled = true;
    emit enabledChanged();
    return true;
}

bool FeatureManager::disable()
{
    if (!m_enabled)
        return false;

    m_commandRunner->sudo(QStringList{"/usr/bin/mount", "-o", "remount,rw", "/"}, true);
    m_commandRunner->rm("/etc/binfmt.d/box64.conf");
    m_commandRunner->rm("/etc/binfmt.d/wine64.conf");
    m_commandRunner->sudo(QStringList{"/usr/bin/mount", "-o", "remount,ro", "/"}, true);
    m_commandRunner->sudo(QStringList{"/usr/bin/systemctl", "restart", "systemd-binfmt"}, true);

    m_enabled = false;
    emit enabledChanged();
    return true;
}
