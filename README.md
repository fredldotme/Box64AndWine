# Winebox

Run Linux and Windows x86_64 binaries on your ARM64  Ubuntu Touch device



## Includes

- Wine
- Box86
- Box64
- GL4ES
- A minimal set of libraries, fetched from the Ubuntu archive



## Usage

- Enable the system-wide binfmt handler inside the packaged app
- Open a terminal
- Mark the to-be-executed file as executable using `chmod +x file.exe`
- Run it like a regular binary as in `./file.exe`

