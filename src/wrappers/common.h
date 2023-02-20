#ifndef WRAPPER_COMMON_H
#define WRAPPER_COMMON_H

#include <unistd.h>
#include <stdlib.h>
#include <string>

inline void setupEnvironment() {
    setenv("BOX64_LOG", "0", 1);
    setenv("BOX64_NOBANNER", "1", 1);
    setenv("BOX64_LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/x86_64-linux-gnu", 1);

    const char* ldp = getenv("LD_LIBRARY_PATH");
    std::string newLdp = "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/aarch64-linux-gnu";
    if (ldp) {
        newLdp += (":" + std::string(ldp));
    }
    setenv("LD_LIBRARY_PATH", newLdp.c_str(), 1);

    const char* path = getenv("PATH");
    std::string newPath = "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/aarch64-linux-gnu/bin";
    if (path) {
        newPath += (":" + std::string(path));
    }
    setenv("PATH", newPath.c_str(), 1);
}

#endif
