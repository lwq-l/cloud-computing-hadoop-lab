#!/usr/bin/env python3
"""第5章：仅使用Python标准库演示虚拟化概念；不是实际Hypervisor。"""
from pathlib import Path

def main() -> None:
    print("=== CH5: conceptual simulation (NOT real VM execution) ===")
    print("[1] Physical CPU scheduling example")
    slots = ["VM-A", "VM-B", "VM-A", "VM-C", "VM-B", "VM-A"]
    print("  one physical CPU; three vCPU requests share time slots")
    for i, vm in enumerate(slots, 1):
        print(f"  time slice {i}: {vm}")
    print("[2] Guest address translation (illustrative only)")
    guest_virtual_to_physical = {0x1000: 0x3000, 0x2000: 0x4000}
    guest_physical_to_machine = {0x3000: 0xA000, 0x4000: 0xB000}
    for gva, gpa in guest_virtual_to_physical.items():
        machine = guest_physical_to_machine[gpa]
        print(f"  GVA 0x{gva:04X} -> GPA 0x{gpa:04X} -> MA 0x{machine:04X}")
    print("  Shadow page tables / EPT aim to support address translation.")
    print("[3] I/O virtualization (illustrative only)")
    print("  emulation: Guest Driver -> VMM/QEMU -> Host Driver -> Device")
    print("  paravirtual I/O: Guest Frontend -> Host Backend -> Device")
    print("  passthrough: Guest Driver -> assigned physical device")
    print("[4] Containers vs virtual machines")
    print("  container: isolated processes and filesystem, shared kernel")
    print("  VM: guest OS running with virtual hardware under a hypervisor")
    print("PASS: CH5 conceptual simulation complete.")
    print("Reminder: this simulation does not create a virtual machine.")

if __name__ == "__main__":
    main()
