#include "../common.h"

int main(int argc, char** argv) {
    setupEnvironment();
    prependEnvVar("LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/aarch64-linux-gnu");
    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/bin/box64", argv);
}
