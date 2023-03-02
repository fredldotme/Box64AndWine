#include "../common.h"
#include <vector>

int main(int argc, char** argv) {
    setupEnvironment();
    setenv("LD_LIBRARY_PATH", "", 1);
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/sysroot/armhf/usr/lib/arm-linux-gnueabihf");
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/sysroot/armhf/usr/lib");
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/usr/lib/arm-linux-gnueabihf");
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/usr/lib/arm-linux-gnueabihf/gl4es");
    setenv("LIBGL_DRIVERS_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/sysroot/armhf/usr/lib/arm-linux-gnueabihf/dri", 1);
    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/bin/box86", argv);
}
