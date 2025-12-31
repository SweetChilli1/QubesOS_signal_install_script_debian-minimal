# QubesOS_signal_install_script_debian-minimal
Schnelles Installations Skript für ein debian-xy-minimal-signal Template aufzusetzten:
Das Skript muss mit sudo ausgeführt werden.

## Anleitung:
### Auf beliebeigen Qube:
Repositorie klonen:
```bash
git clone
```
### Dom0 Terminal: 
1. Debian-xy-minimal template installieren:
   dom0:
   ```bash
   sudo qubes-dom0-update qubes-template-debian-13-minimal
   ```
2. Template klonen:
   ```bash
   qvm-clone debian-13-minimal debian-13-minimal-signal
   ```
3. Root-User starten auf debian-13-minimal debian-11-minimal-signal:
   ```bash
   qvm-run --user root debian-11-minimal-signal xterm
   ```
   
### Debian-13-minimal-signal template:
1. Skript nach debian-13-minimal-signal kopieren
2. Skript ausführbar machen:
   ```bash
   chmod +x install_signal_debian_minimal_qube.sh
   ```
3. Skript ausführen:
   ```bash
   sudo ./install_signal_debian_minimal_qube.sh
   ```
### In Arbeit:
Es sollen am Ende noch alle unnötigen Pakete entfernt werden, um das Template so leicht wie möglich zu halten
