

## remarks

## systemd needs to be disabled

```
/mnt/c/Windows/System32/cmd.exe /c set
ResourceUnavailable: Program 'cmd.exe' failed to run: An error occurred trying to start process '/mnt/c/Windows/System32/cmd.exe' with working directory '/mnt/c/Users/MEichhorn/projects'. No such file or directoryAt line:1 char:1
+ /mnt/c/Windows/System32/cmd.exe /c set
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.


wsl
sudo nano /etc/wsl.conf
[boot]
systemd = false
```

## not needed
WSL Interop needs to be enabled for running windows exe

```ini
[interop]
enable = true
```