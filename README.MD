# GammaCode Releases

Official release binaries for GammaCode - A privacy-focused AI coding assistant.

## Quick Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Zenprenuers/GammaCode-Releases/main/install.sh | bash
```

### Manual Installation

#### macOS

```bash
# ARM64 (Apple Silicon - M1/M2/M3)
curl -L https://github.com/Zenprenuers/GammaCode-Releases/releases/latest/download/gammacode-darwin-arm64.tar.gz | tar -xz
sudo mv gammacode-darwin-arm64/bin/gammacode /usr/local/bin/gammacode

# Intel x64
curl -L https://github.com/Zenprenuers/GammaCode-Releases/releases/latest/download/gammacode-darwin-x64.tar.gz | tar -xz
sudo mv gammacode-darwin-x64/bin/gammacode /usr/local/bin/gammacode
```

#### Linux

```bash
# ARM64
curl -L https://github.com/Zenprenuers/GammaCode-Releases/releases/latest/download/gammacode-linux-arm64.tar.gz | tar -xz
sudo mv gammacode-linux-arm64/bin/gammacode /usr/local/bin/gammacode

# x64
curl -L https://github.com/Zenprenuers/GammaCode-Releases/releases/latest/download/gammacode-linux-x64.tar.gz | tar -xz
sudo mv gammacode-linux-x64/bin/gammacode /usr/local/bin/gammacode
```

#### Windows

1. Download the latest `gammacode-windows-x64.zip` from [Releases](https://github.com/Zenprenuers/GammaCode-Releases/releases)
2. Extract the ZIP file
3. Add the `bin/` directory to your PATH

## Verify Installation

```bash
gammacode --version
gammacode --help
```

## Available Platforms

- **macOS**: ARM64 (Apple Silicon), x64 (Intel)
- **Linux**: ARM64, x64, x64-baseline
- **Windows**: x64

## Configuration

GammaCode stores configuration and data in:

- **Config**: `~/.config/gammacode/`
- **Data**: `~/.local/share/gammacode/`
- **Cache**: `~/.cache/gammacode/`
- **Logs**: `~/.local/share/gammacode/log/`

## Getting Started

1. **Configure AI Provider**:

   ```bash
   gammacode auth login
   ```

2. **List Available Models**:

   ```bash
   gammacode models
   ```

3. **Start Interactive Mode**:

   ```bash
   gammacode
   ```

4. **Run with Message**:
   ```bash
   gammacode run "Write a hello world function in Python"
   ```

## Privacy & Security

- ✅ **No telemetry** - GammaCode doesn't send usage data to external servers
- ✅ **Local-first** - All data stays on your machine
- ✅ **Open source** - Transparency in code and functionality
- ✅ **Self-contained** - No external dependencies required

## Support

- Report issues: [GitHub Issues](https://github.com/Zenprenuers/GammaCode-Releases/issues)
- Documentation: Coming soon
- Community: Coming soon

## Checksums

Each release includes a `checksums.txt` file with SHA256 hashes for verification:

```bash
# Verify download integrity
sha256sum -c checksums.txt
```

---

**Note**: This repository contains only release binaries. The source code is maintained in a private repository.
