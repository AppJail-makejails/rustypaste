# Rustypaste

**rustypaste** is a self-hosted and minimal file upload/pastebin service written in Rust.

**Features**:

- File upload & URL shortening & upload from URL
  - supports basic HTTP authentication
  - random file names (optional)
    - pet name (e.g. `capital-mosquito.txt`)
    - alphanumeric string (e.g. `yB84D2Dv.txt`)
    - random suffix (e.g. `file.MRV5as.tar.gz`)
  - supports expiring links
    - auto-expiration of files (optional)
    - auto-deletion of expired files (optional)
  - supports one shot links/URLs (can only be viewed once)
  - guesses MIME types
    - supports overriding and blacklisting
    - supports forcing to download via `?download=true`
  - no duplicate uploads (optional)
  - listing/deleting files
  - custom landing page
- Single binary
  - [binary releases](https://github.com/orhun/rustypaste/releases)
- Simple configuration
  - supports hot reloading
- Easy to deploy
  - [appjail images](https://github.com/AppJail-makejails/rustypaste)
  - [docker images](https://hub.docker.com/r/orhunp/rustypaste)
- No database
  - filesystem is used
- Self-hosted
  - *centralization is bad!*
- Written in Rust
  - *blazingly fast!*

blog.orhun.dev/blazingly-fast-file-sharing

<img src="https://github.com/orhun/rustypaste/raw/master/img/rustypaste_logo.png" width="30%" height="auto" alt="Rustypaste logo">

## How to use this Makejail

### Standalone

```console
$ mkdir -p upload
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o fstab="$PWD/upload /app/upload" \
    -o fstab="$PWD/config.toml app/config.toml nullfs ro" \
    -e PUID=15000 \
    -e PGID=15000 \
    ghcr.io/appjail-makejails/rustypaste rustypaste
```

**Note**: The previous example assumes that you have a [config.toml](config.toml) file in the current directory.

Now you can run [rpaste](https://www.freshports.org/www/rustypaste-cli) to upload some code.

```console
$ rpaste -s http://rustypaste:8000 main.c
http://rustypaste:8000/creepy-nell.c
$ curl http://rustypaste:8000/creepy-nell.c
#include <stdio.h>
#include <stdlib.h>

int
main(void)
{
    printf("Hello!\n");
    return EXIT_SUCCESS;
}
```

### Deploy using `appjail-director`

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  rustypaste:
    makejail: gh+AppJail-makejails/rustypaste
    options:
      - container: 'args:--pull'
    volumes:
      - upload: /app/upload
      - config: app/config.toml
    oci:
      environment:
        - PUID: 15000
        - PGID: 15000

volumes:
  upload:
    device: /var/appjail-volumes/rustypaste/upload
  config:
    device: /path/to/your/config.toml
    type: nullfs
    options: ro
```

**.env**:

```dotenv
DIRECTOR_PROJECT=rustypaste
```

### Arguments (stage: build)

* `rustypaste_from` (default: `ghcr.io/appjail-makejails/rustypaste`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `rustypaste_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).

### Environment (OCI image)

* `PGID` (default: `1000`): Equivalent to `PUID` but for the Process Group ID.
* `PUID` (default: `1000`): Process User ID for the container's main process, allowing you to match the owner of files written to mounted host volumes to your host system's user. Writable volumes are changed based on this environment variable.

### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-9ce1ec3b7e-app_upload | `${PUID}` | `${PGID}` | - | - | /app/upload |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1
      containerfile: Containerfile
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```
