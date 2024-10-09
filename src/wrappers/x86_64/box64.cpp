#include "../common.h"

int main(int argc, char** argv) {
    setupEnvironment();
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib");
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/aarch64-linux-gnu");
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/usr/lib/aarch64-linux-gnu");

    if (getenv("GL4ES")) {
        prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/usr/lib/aarch64-linux-gnu/gl4es");
    }

    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/bin/box64", argv);
}
