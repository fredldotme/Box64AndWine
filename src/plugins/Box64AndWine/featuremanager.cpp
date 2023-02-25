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

FeatureManager::FeatureManager()
{
}

bool FeatureManager::recheckSupport()
{
    const QByteArray supportedFilesystems = m_commandRunner->readFile("/proc/filesystems");
    m_supported = supportedFilesystems.contains(QByteArrayLiteral("binfmt_misc"));

    return m_supported;
}

bool FeatureManager::enabled()
{
    m_enabled =
            (m_commandRunner->sudo(QStringList{"/usr/bin/test", "-f", "/etc/binfmt.d/box64andwine.fredldotme.conf"}, true) == 0);
    return m_enabled;
}

bool FeatureManager::enable()
{
    if (m_enabled)
        return false;

    const bool isMounted =
            (m_commandRunner->sudo(QStringList{"/usr/bin/mountpoint", "-q", "/proc/sys/fs/binfmt_misc"}, true)) == 0;

    QByteArray contents =
            m_commandRunner->readFile(QCoreApplication::applicationDirPath() + QStringLiteral("/winebox.conf"));
    contents.replace(QByteArrayLiteral("@CURRENT_BIN@"),
                     QByteArrayLiteral("/opt/click.ubuntu.com/box64andwine.fredldotme/current"));
    m_commandRunner->writeFile("/etc/binfmt.d/box64andwine.fredldotme.conf", contents);

    if (!isMounted)
        m_commandRunner->sudo(QStringList{"/usr/bin/mount", "-t", "binfmt_misc", "binfmt", "/proc/sys/fs/binfmt_misc"}, true);
    m_commandRunner->sudo(QStringList{"/usr/bin/systemctl", "restart", "systemd-binfmt"}, true);

    m_enabled = true;
    return true;
}

bool FeatureManager::disable()
{
    if (!m_enabled)
        return false;

    m_commandRunner->rm("/etc/binfmt.d/box64andwine.fredldotme.conf");
    m_commandRunner->sudo(QStringList{"/usr/bin/systemctl", "restart", "systemd-binfmt"}, true);

    m_enabled = false;
    return true;
}
