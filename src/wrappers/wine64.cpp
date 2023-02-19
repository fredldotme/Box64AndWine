#include <unistd.h>
#include <stdlib.h>
#include <vector>

using namespace std;

int main(int argc, char** argv) {
    setenv("BOX64_LOG", "0", 1);
    setenv("BOX64_NOBANNER", "1", 1);
    setenv("BOX64_LD_LIBRARY_PATH", "/opt/click.ubuntu.com/box64andwine.fredldotme/current/lib/x86_64-linux-gnu", 1);

    const char* wine64bin = "/opt/click.ubuntu.com/box64andwine.fredldotme/current/wine/bin/wine64";

    vector<const char*> args;
    args.push_back(wine64bin);
    for (int i = 0; i < argc; i++) {
        args.push_back(argv[i]);
    }
    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/box64wrapper", (char**)args.data());
}
