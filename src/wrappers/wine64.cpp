#include <unistd.h>
#include <stdlib.h>
#include <string>

#include "common.h"

int main(int argc, char** argv) {
    setupEnvironment();
    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/wine/bin/wine64", argv);
}
