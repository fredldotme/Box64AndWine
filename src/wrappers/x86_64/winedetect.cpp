#include "../common.h"
#include <memory>
#include <pe-parse/parse.h>

using ParsedPeRef = std::unique_ptr<peparse::parsed_pe, void (*)(peparse::parsed_pe *)>;

ParsedPeRef openExecutable(const std::string &path) noexcept {
    ParsedPeRef obj(peparse::ParsePEFromFile(path.data()),
                    peparse::DestructParsedPE);
    if (!obj) {
        return ParsedPeRef(nullptr, peparse::DestructParsedPE);
    }

    return obj;
}

int main(int argc, char** argv) {
    if (argc > 1) {
        const std::string exe = std::string(argv[1]);
        auto pe = openExecutable(exe);
        if (pe) {
            const std::string type = std::string(peparse::GetMachineAsString(pe.get()));
            if (type == "x64") {
                return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/wine64wrapper", argv);
            }
        }
    }
    return execvp("/opt/click.ubuntu.com/box64andwine.fredldotme/current/winewrapper", argv);
}
