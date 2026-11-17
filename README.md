# CODESYS 4 im Docker-Container

Dieses Dockerfile installiert CODESYS 4 als Web-Server in einem Ubuntu-24.04-Container
(nach der [offiziellen Quickstart-Anleitung](https://content.helpme-codesys.com/en/CODESYS%204/_c4_install_webserver_linux_quickstart.html)).

## Voraussetzungen

- Docker
- Docker Compose
- Das Debian-Paket von CODESYS 4, erhältlich im [CODESYS Store](https://store.codesys.com).
  Das Paket (`codesys-4_1.0.0.0_amd64.deb`) muss im selben Verzeichnis wie das Dockerfile liegen.

## Bauen

```bash
docker build -t codesys4 --build-arg C4_USER=christian --build-arg C4_PASSWORD=meinPasswort .
```

| Build-Argument | Standard    | Bedeutung                                         |
|----------------|-------------|---------------------------------------------------|
| `C4_USER`      | `christian` | Linux-Benutzer für die Anmeldung in der Anwendung |
| `C4_PASSWORD`  | `changeme`  | Passwort dieses Benutzers                         |

## Starten

```bash
docker run --rm -it -p 8080:8080 codesys4
```

Die Anwendung ist anschließend unter http://localhost:8080 erreichbar.
Die Anmeldung erfolgt mit `C4_USER` und `C4_PASSWORD`.

Optional kann das Datenverzeichnis dauerhaft gespeichert werden:

```bash
docker run --rm -it -p 8080:8080 -v codesys4-data:/var/opt/codesys-4 codesys4
```

## Docker Compose

Die mitgelieferte [docker-compose.yml](docker-compose.yml) baut das Image aus dem lokalen Verzeichnis
und bindet es per Traefik mit HTTPS an.

| Variable               | Standard     | Bedeutung                                       |
|------------------------|--------------|-------------------------------------------------|
| `CODESYS_DOMAIN`       | –            | Domain für die Traefik-Route (erforderlich)     |
| `CODESYS_USER`         | `christian`  | Anmeldebenutzer (Build-Argument)                |
| `CODESYS_PASSWORD`     | `changeme`   | Passwort des Anmeldebenutzers (Build-Argument)  |
| `CODESYS_PROJECTS_DIR` | `./projects` | Host-Verzeichnis für eigene Projektdateien      |

Die Variablen können in einer `.env`-Datei neben der Compose-Datei stehen.

```bash
mkdir -p projects
docker compose up -d --build
```

Das Verzeichnis für die Projekte muss für den Container-Benutzer beschreibbar sein
(UID ermitteln: `docker compose run --rm codesys id <C4_USER>`, dann `sudo chown <UID> projects`).

## Hinweise

- Der Server läuft als Benutzer `c4-server` (nicht als root!).
- Der Anmeldebenutzer ist Mitglied der Gruppe `codesys-4`.
- Das Passwort wird beim Build gesetzt und ist in der Image-Historie sichtbar. Nicht für produktive Zwecke geeignet.
