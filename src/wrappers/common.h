#ifndef WRAPPER_COMMON_H
#define WRAPPER_COMMON_H

#include <unistd.h>
#include <stdlib.h>
#include <string>

inline void prependEnvVar(const char* key, const char* value)
{
    const char* ldp = getenv(key);
    std::string newLdp = std::string(value);
    if (ldp) {
        newLdp += (":" + std::string(ldp));
    }
    setenv(key, newLdp.c_str(), 1);
}

inline void setupEnvironment()
{
    setenv("BOX64_LOG", "0", 0);
    setenv("BOX64_NOBANNER", "1", 0);
    prependEnvVar("BOX64_LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/sysroot/amd64/lib/x86_64-linux-gnu");
    prependEnvVar("BOX64_LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/x86_64-linux-gnu");
    setenv("BOX64_BASH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/sysroot/amd64/usr/bin/bash", 0);

    setenv("BOX86_LOG", "0", 0);
    setenv("BOX86_NOBANNER", "1", 0);
    prependEnvVar("BOX86_LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/i386-linux-gnu");

    setenv("LIBGL_NOBANNER", "1", 0);
    setenv("LIBGL_SILENTSTUB", "1", 0);
    setenv("LIBGL_FB", "3", 0);
    setenv("HYBRIS_EGLPLATFORM", "null", 0);

    prependEnvVar("PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/aarch64-linux-gnu/bin");
}

#endif
