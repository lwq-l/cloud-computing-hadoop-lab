#!/usr/bin/env python3
"""第六章存储原理：精简配置使用真实稀疏文件，快照与链接克隆为概念演示。"""
from pathlib import Path
import os
import shutil
import tempfile

def main():
    print("=== CH6 Storage virtualization classroom demo ===")
    with tempfile.TemporaryDirectory(prefix="ch06-storage-") as tmp:
        folder = Path(tmp)
        sparse = folder / "thin-example.img"
        logical_size = 64 * 1024 * 1024
        with sparse.open("wb") as f:
            f.seek(logical_size - 1)
            f.write(b"\0")
        stat = sparse.stat()
        allocated = stat.st_blocks * 512
        print("[1] Sparse file: a thin provisioning analogy")
        print(f"  logical file size: {stat.st_size} bytes (64 MiB)")
        print(f"  filesystem-allocated blocks: {allocated} bytes")
        print("  NOTE: a sparse file is not a real SAN LUN or storage-array thin volume.")
        assert stat.st_size == logical_size

        base = folder / "base.txt"
        base.write_text("version=1\nshared=course-template\n", encoding="utf-8")
        saved = folder / "snapshot-copy.txt"
        shutil.copyfile(base, saved)
        base.write_text("version=2\nshared=course-template\n", encoding="utf-8")
        print("[2] Independent backup copy as snapshot concept illustration")
        print("  current:", base.read_text(encoding="utf-8").splitlines()[0])
        print("  saved copy:", saved.read_text(encoding="utf-8").splitlines()[0])
        assert saved.read_text(encoding="utf-8").startswith("version=1")

        template = {"course": "Cloud Computing", "level": "starter"}
        delta_a = {"level": "student-A"}
        delta_b = {"level": "student-B"}
        def view(delta, key):
            return delta.get(key, template[key])
        print("[3] Linked clone concept: shared base plus independent changes")
        print("  template level:", template["level"])
        print("  clone A level:", view(delta_a, "level"), "| shared course:", view(delta_a, "course"))
        print("  clone B level:", view(delta_b, "level"), "| shared course:", view(delta_b, "course"))
        assert template["level"] == "starter"
        assert view(delta_a, "level") != view(delta_b, "level")
        print("  NOTE: dictionary overlays are a simulation, not real linked-clone metadata.")
    print("PASS: CH6 storage principles demo finished.")

if __name__ == "__main__":
    main()
