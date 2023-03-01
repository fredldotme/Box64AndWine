#include "../common.h"
#include <vector>

int main(int argc, char** argv) {
    setupEnvironment();
    setenv("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/sysroot/armhf/lib/arm-linux-gnueabihf", 1);
    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/bin/box86", argv);
}
