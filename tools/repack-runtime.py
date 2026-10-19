"""Repackage a runtime as the archive huFFuη imports.

huFFuη imports a runtime only from a ZIP whose files all sit below the pin's
root folder. This puts the files of a directory, or of a zip's top level,
below ROOT/ with their bytes, stored uncompressed with fixed dates and modes
in path order, so the archive is the same bytes wherever it is made: anyone
can rebuild it from the official download and check its SHA-256. Windows
programs and libraries (.exe, .dll) get mode 755, everything else 644.

It prints the archive's SHA-256 and the tree digest the pin records
(huffun-server/src/sleeves/digest.ts, runtimeDigest).

Usage: python3 -I tools/repack-runtime.py ROOT SOURCE OUT.zip
  SOURCE is a directory or a .zip; extract a .7z first (7z x).
"""
import hashlib
import os
import stat
import sys
import zipfile

root, source, target = sys.argv[1], sys.argv[2], sys.argv[3]
files = []
if source.endswith(".zip"):
    with zipfile.ZipFile(source) as z:
        for info in z.infolist():
            if not info.is_dir():
                files.append((info.filename, z.read(info)))
else:
    for folder, dirs, names in os.walk(source):
        for name in names:
            full = os.path.join(folder, name)
            if os.path.islink(full):
                raise SystemExit(f"links are not expected in a Windows runtime: {full}")
            rel = os.path.relpath(full, source).replace(os.sep, "/")
            with open(full, "rb") as f:
                files.append((rel, f.read()))
files = sorted((f"{root}/{rel}", data) for rel, data in files)


def executable(path):
    return path.lower().endswith((".exe", ".dll"))


with zipfile.ZipFile(target, "w", compression=zipfile.ZIP_STORED, allowZip64=True) as out:
    for path, data in files:
        info = zipfile.ZipInfo(path, (2000, 1, 1, 0, 0, 0))
        info.create_system = 3
        info.compress_type = zipfile.ZIP_STORED
        mode = 0o755 if executable(path) else 0o644
        info.external_attr = (stat.S_IFREG | mode) << 16
        out.writestr(info, data)

tree = hashlib.sha256()
for path, data in files:
    flag = "x" if executable(path) else "-"
    tree.update(f"f\0{path}\0{len(data)}\0{flag}\0{hashlib.sha256(data).hexdigest()}\n".encode())
with open(target, "rb") as f:
    archive = hashlib.sha256()
    for chunk in iter(lambda: f.read(1 << 20), b""):
        archive.update(chunk)
print(f"archiveSha256 {archive.hexdigest()}")
print(f"treeSha256    {tree.hexdigest()}")
print(f"files         {len(files)}")
