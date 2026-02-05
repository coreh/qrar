# qrar

Encode and decode files to/from QR codes. Supports splitting large files across multiple QR codes, optional encryption, and various output formats.

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
- **Video/PDF input** - Extract and decode QR codes from video files or multi-page PDFs
- **Robust decoding**:
  - Multiple QR codes per image (e.g., printed sheets)
  - Any order, with duplicates handled automatically
  - Missing chunks detected and reported
  - Unrelated QR codes ignored
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
- `ffmpeg` - Video/GIF output (`-V`, `-G`) and video input
- `imagemagick` - Montage/print output (`-M`, `-P`) and PDF input
- `ghostscript` - PDF input (used by ImageMagick)

The `install` command will detect your package manager and offer to install missing dependencies.

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
qrar encode -M backup.tar.gz

# Create print-ready PDF montage
qrar encode -P backup.tar.gz
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
```

### Options

| Option | Description |
|--------|-------------|
| `-o, --output <path>` | Output file or directory |
| `-e, --encrypt` | Enable encryption (prompts for passphrase) |
| `-T, --terminal` | Display QR code(s) in terminal |
| `-G, --gif` | Output as animated GIF |
| `-V, --video` | Output as MP4 video |
| `-M, --montage` | Output as print-ready PDF |
| `-q, --quiet` | Suppress non-essential output |
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
qrar encode -e -M ~/.ssh/id_ed25519
```

## License

MIT License - see [LICENSE](LICENSE) for details.
