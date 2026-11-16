#!/usr/bin/env python3
"""对象/文件/块三类存储的本地教学示例；不访问付费云存储服务。"""
from hashlib import sha256
from pathlib import Path
import json
import tempfile

def main():
    print("=== CH6 File / Object / Block storage concepts ===")
    with tempfile.TemporaryDirectory(prefix="ch06-cloud-storage-") as temp:
        root = Path(temp)
        folder = root / "department" / "reports"
        folder.mkdir(parents=True)
        report = folder / "lab.txt"
        report.write_text("cloud-storage-ch6\n", encoding="utf-8")
        print("[1] FILE: directory path =", report.relative_to(root))
        print("    content =", report.read_text(encoding="utf-8").strip())

        data = report.read_bytes()
        obj = {
            "key": "course/2026/ch06/lab.txt",
            "metadata": {"content-type": "text/plain", "sha256": sha256(data).hexdigest()},
            "content": data.decode("utf-8").strip()
        }
        print("[2] OBJECT: key and metadata (local simulation)")
        print("    ", json.dumps(obj, ensure_ascii=False))
        assert obj["metadata"]["sha256"] == sha256(data).hexdigest()

        disk = root / "virtual-block-device.img"
        with disk.open("wb") as f:
            f.truncate(1024 * 1024)
        with disk.open("r+b") as f:
            f.seek(4096)
            f.write(b"BLOCK-CH6")
            f.seek(4096)
            value = f.read(9)
        print("[3] BLOCK: offset=4096, read=", value.decode())
        assert value == b"BLOCK-CH6"
        print("NOTE: files, metadata and local binary images are classroom analogies, not OSS/S3/SAN.")
    print("PASS: CH6 cloud storage types demo finished.")

if __name__ == "__main__":
    main()
