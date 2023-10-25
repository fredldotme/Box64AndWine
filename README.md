# Winebox

Run Linux and Windows x86_64 binaries on your ARM64 Ubuntu Touch device

## How to build
- Get [Clickable](https://clickable-ut.dev)
- Clone the repository: `git clone --recursive https://github.com/fredldotme/Box64AndWine.git`
- Run the `clickable` command inside the cloned directory

## Includes

- Wine (LGPL v2.1+)
- Box86 (MIT)
- Box64 (MIT)
- GL4ES (MIT)
- pe-parse (MIT)
- Various libraries fetched from the Ubuntu & UBports archives



## Usage

- Enable the system-wide binfmt handler inside the packaged app
- Open a terminal
- Mark the to-be-executed file as executable using `chmod +x file.exe`
- Run it like a regular binary as in `./file.exe`

