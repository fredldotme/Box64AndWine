#include <unistd.h>
#include <stdlib.h>
#include <vector>

using namespace std;

int main(int argc, char** argv) {
    setenv("BOX64_LOG", "0", 1);
    setenv("BOX64_NOBANNER", "1", 1);
    setenv("BOX64_LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/x86_64-linux-gnu", 1);
    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/wine/bin/wine64", argv);
}
