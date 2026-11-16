#!/usr/bin/env python3
"""CNB备用教学实验：真实本机回环HTTP + 应用层逻辑分段访问策略。

这是在127.0.0.1上运行的Python HTTP服务器和两个客户端请求。
展示软件按逻辑分段控制访问的原理；没有创建Docker bridge、VLAN、VPN或真实隔离网络。
"""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from threading import Thread
from urllib.error import HTTPError
from urllib.request import Request, urlopen


class LessonHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        segment = self.headers.get("X-CH6-Segment", "")
        if self.path == "/course" and segment == "class-A":
            status, body = 200, b"CH6_FALLBACK_HTTP_OK"
        else:
            status, body = 403, b"CH6_POLICY_DENIED"
        self.send_response(status)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


def request(url, segment):
    req = Request(url, headers={"X-CH6-Segment": segment})
    try:
        with urlopen(req, timeout=3) as response:
            return response.status, response.read().decode("utf-8")
    except HTTPError as exc:
        return exc.code, exc.read().decode("utf-8")


def main():
    server = ThreadingHTTPServer(("127.0.0.1", 0), LessonHandler)
    worker = Thread(target=server.serve_forever, daemon=True)
    worker.start()
    url = "http://127.0.0.1:{}/course".format(server.server_port)
    try:
        print("=== CH6 local HTTP + application-policy fallback ===")
        print("Listen: 127.0.0.1:{} (local only)".format(server.server_port))
        status_a, body_a = request(url, "class-A")
        print("Client class-A -> HTTP {} {}".format(status_a, body_a))
        assert (status_a, body_a) == (200, "CH6_FALLBACK_HTTP_OK")

        status_b, body_b = request(url, "class-B")
        print("Client class-B -> HTTP {} {}".format(status_b, body_b))
        assert (status_b, body_b) == (403, "CH6_POLICY_DENIED")

        print("PASS: CH6 fallback HTTP and application-policy demo.")
        print("NOTE: Both requests use the SAME loopback interface and TCP server.")
        print("NOTE: The access rule is implemented at APPLICATION level; no Docker,")
        print("      VLAN, VPN, switch or kernel network-isolation effect is claimed.")
    finally:
        server.shutdown()
        server.server_close()
        worker.join(timeout=3)


if __name__ == "__main__":
    main()
