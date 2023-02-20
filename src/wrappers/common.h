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
    setenv("BOX64_LOG", "0", 1);
    setenv("BOX64_NOBANNER", "1", 1);
    setenv("BOX64_LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/x86_64-linux-gnu", 1);
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/aarch64-linux-gnu");
    prependEnvVar("PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/aarch64-linux-gnu/bin");
}

#endif
