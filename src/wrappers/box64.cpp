#include "common.h"

int main(int argc, char** argv) {
    setupEnvironment();
    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/bin/box64", argv);
}
