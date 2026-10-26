# Bash

Eine Sammlung nützlicher Bash-Skripte für Linux – vor allem für Installation,
Setup und Wartungsaufgaben, die ich immer wieder brauche.

## Skripte

### `install-rar2fs.sh`

Installiert [rar2fs](https://github.com/hasse69/rar2fs) auf Debian-basierten
Systemen inklusive einer statisch eingebundenen UnRAR-Bibliothek.

- Prüft, dass das Skript als root läuft und auf einer Debian-basierten
  Distribution ausgeführt wird
- Installiert die Build-Abhängigkeiten (FUSE 2 API) über `apt-get`
- Lädt UnRAR und rar2fs in den gewünschten Versionen herunter, verifiziert
  den Download per SHA256 (für die Standardversion) und baut beides
  statisch zusammen
- Installiert das fertige `rar2fs`-Binary nach `/usr/local/bin`

**Verwendung:**

```bash
sudo ./install-rar2fs.sh
```

Versionen lassen sich über Umgebungsvariablen anpassen:

```bash
sudo RAR2FS_VERSION=1.29.4 UNRAR_VERSION=6.0.3 ./install-rar2fs.sh
```

**Beispiel nach der Installation:**

```bash
rar2fs -o ro /pfad/zu/archiven /pfad/zum/mountpunkt
```

## Nutzung

Jedes Skript ist eigenständig ausführbar. Vor dem Ausführen kurz in das
Skript schauen, um zu verstehen, was es tut – insbesondere wenn es mit
`sudo`/root-Rechten läuft.

## Beitragen

Weitere Skripte landen einfach als neue Datei in diesem Repo mit einem
kurzen Eintrag in dieser README.
