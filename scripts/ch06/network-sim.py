#!/usr/bin/env python3
"""第六章概念模拟：虚拟交换、网络分段、VPN路径。不是OVS/VLAN/VPN实际部署。"""
def main():
    print("=== CH6 Network virtualization conceptual simulation ===")
    mac_to_segment = {
        "02:00:00:00:01:10": "class-A",
        "02:00:00:00:01:11": "class-A",
        "02:00:00:00:02:10": "class-B",
    }
    src = "02:00:00:00:01:10"
    same = "02:00:00:00:01:11"
    other = "02:00:00:00:02:10"
    print("[1] Virtual switch forwarding (illustrative MAC table)")
    print("  source MAC:", src, "segment:", mac_to_segment[src])
    print("  same-segment destination:", same, "->", "FORWARD")
    print("  other-segment destination:", other, "->", "BLOCKED by example policy")
    assert mac_to_segment[src] == mac_to_segment[same]
    assert mac_to_segment[src] != mac_to_segment[other]
    print("[2] VPN logical path (illustrative, no tunnel created)")
    print("  Beijing LAN -> VPN gateway -> encrypted tunnel over Internet -> VPN gateway -> Shanghai LAN")
    print("[3] SDN: controller defines policy; forwarding plane applies flow decisions")
    print("[4] NFV: firewall/router functions may run as software services")
    print("NOTE: no real VLAN, OVS, IPsec VPN, SDN controller or encrypted tunnel is configured.")
    print("PASS: CH6 network concept demo finished.")

if __name__ == "__main__":
    main()
