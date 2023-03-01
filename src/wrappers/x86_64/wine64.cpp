#include "../common.h"
#include <unistd.h>
#include <pwd.h>

int main(int argc, char** argv) {
    setupEnvironment();

    struct passwd *pw = getpwuid(getuid());

    const std::string homeDir = (pw && pw->pw_dir) ?
                                std::string(pw->pw_dir) : "/home/phablet";
    const std::string wineDir = homeDir + "/.wine64";
    setenv("WINEARCH", "win64", 1);
    setenv("WINEPREFIX", wineDir.c_str(), 1);

    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/wine/bin/wine64", argv);
}
