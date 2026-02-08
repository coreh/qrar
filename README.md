# qrar

[![Lint](https://github.com/coreh/qrar/actions/workflows/lint.yml/badge.svg)](https://github.com/coreh/qrar/actions/workflows/lint.yml)
[![Tests (macOS)](https://github.com/coreh/qrar/actions/workflows/test-macos.yml/badge.svg)](https://github.com/coreh/qrar/actions/workflows/test-macos.yml)
[![Tests (Ubuntu)](https://github.com/coreh/qrar/actions/workflows/test-ubuntu.yml/badge.svg)](https://github.com/coreh/qrar/actions/workflows/test-ubuntu.yml)

Pure shell, single file utility script to encode and decode multiple files to/from QR codes. (Via `qrencode`, `zbarimg`, `tar`, `ffmpeg`, `magick`, `openssl`, `ghostscript`) Supports splitting large files across multiple QR codes, compression, optional encryption, and various output/input formats, including live webcam feed.

```bash
# Encode file(s) to QR code(s)
qrar encode *.txt

# Decode back to file(s)
qrar decode myfile.txt.qr.*.png
```

## Features

- **File encoding** - Convert any file(s) or directory to QR code(s) with automatic chunking
- **File decoding** - Reconstruct files from QR code images, videos, or PDFs
- **Metadata preservation** - File names, permissions, and timestamps are preserved via tar
- **Encryption** - Optional AES-256-CBC encryption with passphrase
- **Multiple output formats**:
  - PNG images (default)
  - Terminal display (UTF-8)
  - Animated GIF
  - Video (MP4)
  - Print-ready PDF montage
- **Webcam support**:
  - Live scanning - Point your webcam at QR codes and decode in real-time
  - Streaming - Transfer files between machines by cycling QR codes on one screen and scanning with a webcam on the other
  - Live camera preview in the terminal via half-block Unicode characters (requires ImageMagick)
- **Video/PDF input** - Extract and decode QR codes from video files or multi-page PDFs
- **Robust decoding**:
  - Multiple QR codes per image (e.g., printed sheets)
  - Any order, with duplicates handled automatically
  - Missing chunks detected and reported
  - Unrelated QR codes ignored
- **Stdin/pipe support** - Read input from stdin via `-` or automatic detection, and pipe output through `-T`
- **Cross-platform** - Works on macOS, Linux, and BSD with automatic dependency detection

## Installation

### Quick install (curl | bash)

```bash
curl -fsSL https://raw.githubusercontent.com/coreh/qrar/main/qrar | bash -s install
```

### Manual install

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/coreh/qrar/main/qrar -o qrar
chmod +x qrar

# Install dependencies and script
./qrar install
```

### Dependencies

**Required:**
- `qrencode` - QR code generation
- `zbar` - QR code decoding

**Optional:**
- `openssl` - Encryption support (`-e` flag)
- `ffmpeg` - Video/GIF output (`-V`, `-G`), video input, and webcam capture (`-W`)
- `imagemagick` - Montage/print output (`-m`, `-P`), PDF input, and webcam preview (`-W`)
- `ghostscript` - PDF input (used by ImageMagick)

The `install` command will detect your package manager and offer to install missing dependencies.

### Update

```bash
qrar update
```

### Uninstall

```bash
qrar uninstall
```

This removes the `qrar` script and optionally uninstalls its dependencies.

## Usage

### Encode a file to QR codes

```bash
# Basic encoding (creates document.pdf.qr.png or document.pdf.qr.001.png, etc.)
qrar encode document.pdf

# Encode multiple files into one archive
qrar encode file1.txt file2.txt config.json

# Encode an entire directory
qrar encode ./my-project/

# With encryption
qrar encode -e secret.txt

# Output to terminal
qrar encode -T message.txt

# Create animated GIF
qrar encode -G archive.tar.gz

# Create video
qrar encode -V large-file.bin

# Create montage (all QR codes in one image)
qrar encode -m backup.tar.gz

# Create print-ready PDF montage
qrar encode -P backup.tar.gz

# Stream QR codes to terminal for webcam scanning
qrar encode -W document.pdf

# Encode from stdin (auto-detected)
echo "hello world" | qrar encode -T
cat secret.txt | qrar encode -o backup.png

# Pipe-friendly (defaults to -T when stdout is a pipe)
cat secret.txt | qrar encode | less

# Mix stdin with file inputs using explicit -
cat header.txt | qrar encode -T - footer.txt
```

### Decode QR codes back to file

```bash
# From image files
qrar decode *.png

# From multiple sources (images, videos, PDFs can be mixed)
qrar decode photo1.jpg photo2.jpg video.mp4 scan.pdf

# From a video recording
qrar decode recording.mp4

# From a PDF scan
qrar decode scanned-pages.pdf

# With decryption
qrar decode -e secret.txt.qr.*.png

# From webcam (live scanning)
qrar decode -W

# Decode from stdin (auto-detected)
cat qrcode.png | qrar decode
cat recording.mp4 | qrar decode
```

### Options

| Option | Description |
|--------|-------------|
| `-o, --output <path>` | Output path (file for encode, directory for decode) |
| `-O, --output-dir <dir>` | Output directory |
| `-l, --level <L\|M\|Q\|H>` | Error correction level (default: M). L=7%, M=15%, Q=25%, H=30% recovery |
| `-s, --size <pixels>` | QR code dot size (default: 10) |
| `-c, --compression <type>` | Compression: `gz`, `xz`, `none` (default: `gz`) |
| `-e, --encrypt` | Encrypt data (prompts for passphrase) |
| `-p, --passphrase <pass>` | Encryption/decryption passphrase (inline, avoids prompt) |
| `-f, --force` | Overwrite files without confirmation |
| `-T, --terminal [mode]` | Display QR codes in terminal. Modes: `UTF8`, `UTF8i` (inverted), `ANSI`, `ASCII`, `ANSI256` (default: `UTF8`) |
| `-G, --gif` | Output as animated GIF |
| `-V, --video` | Output as MP4 video |
| `-m, --montage` | Combine all QR codes into a single image |
| `-P, --print` | Combine all QR codes into a print-ready multi-page PDF |
| `--montage-cols <n>` | Number of columns in montage (default: auto) |
| `-W, --webcam` | Webcam mode (encode: cycle QR codes at 2fps; decode: scan from webcam) |
| `--frame-duration <sec>` | Seconds per QR code in video/GIF (default: 2) |
| `--verbose` | Show detailed progress |
| `-v, --version` | Show version |
| `-h, --help` | Show help |

## How it works

1. **Encoding**: Input files and directories are bundled into a tar archive (preserving names, permissions, timestamps), optionally compressed and encrypted, then base64-encoded and split into chunks small enough for QR codes (~230 bytes each for version 10-12 codes)

2. **Chunk format**: Each QR code contains a header with version, flags, sequence number, session ID, and checksum:
   ```
   QRAR:V1:<flags>:<seq>/<total>:<session_id>:<checksum>:<data>
   ```

3. **Decoding**: QR codes are scanned from images, videos, or PDFs. Multiple codes per image are supported (e.g., a photo of a printed sheet). Chunks are validated by checksum, deduplicated, and reassembled in the correct order regardless of scan order. Unrelated QR codes are silently ignored. Missing chunks are reported with their sequence numbers

## Examples

```bash
# Encode a small text file and display in terminal
echo "Hello, World!" > hello.txt
qrar encode -T hello.txt

# Encode with encryption and create a GIF
qrar encode -e -G sensitive-data.json

# Decode from phone camera recording
qrar decode -e phone-recording.mov

# Decode from a photo of a printed page (multiple QR codes in one image)
qrar decode photo-of-printout.jpg

# Create printable backup of encryption keys
qrar encode -e -P ~/.ssh/id_ed25519

# Transfer a file between two machines via webcam
# Machine A (sender):
qrar encode -e -W secret.txt
# Machine B (receiver, point webcam at Machine A's screen):
qrar decode -e -W -o ./received/
```

## License

MIT License - see [LICENSE](LICENSE) for details.
