# Rustypaste

**rustypaste** is a self-hosted and minimal file upload/pastebin service written in Rust.

## Features

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
  
## How to use this Makejail

### Standalone

```sh
appjail makejail \
    -j rustypaste \
    -f gh+AppJail-makejails/rustypaste \
    -o virtualnet=":<random> default" \
    -o nat
```

Now you can run [rpaste](https://github.com/orhun/rustypaste-cli) to upload some code.

```
$ rpaste -s http://rustypaste:8000 main.c
http://rustypaste:8000/enhanced-pika.c
$ curl http://rustypaste:8000/enhanced-pika.c
#include <stdio.h>
#include <stdlib.h>

int
main(void)
{
    printf("Hello!\n");
    return EXIT_SUCCESS;
}
```

### Customization

This Makejail can process some environment variables best described in [#environment](#environment).

```sh
appjail makejail \
    -j rustypaste \
    -f gh+AppJail-makejails/rustypaste \
    -o virtualnet=":<random> default" \
    -o nat \
    -V RUSTYPASTE_EXPOSE_VERSION=true \
    -V RUSTYPASTE_EXPOSE_LIST=true \
    -V RUSTYPASTE_AUTH_TOKENS_01=123 \
    -V RUSTYPASTE_AUTH_TOKENS_02=321 \
    -V RUSTYPASTE_DELETE_TOKENS_01=456 \
    -V RUSTYPASTE_DELETE_TOKENS_02=654 \
    -V RUSTYPASTE_DEFAULT_EXPIRY=1h \
    -V RUSTYPASTE_RANDOM_URL_TYPE=alphanumeric
```

### Deploy using appjail-director

Using environment variables to deploy rustypaste is fine, but [appjail-director](https://github.com/DtxdF/director) is more suitable when we need to define many environment variables as in the example above.

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  rustypaste:
    makejail: gh+AppJail-makejails/rustypaste
    name: rustypaste
    environment:
      - RUSTYPASTE_EXPOSE_VERSION: true
      - RUSTYPASTE_EXPOSE_LIST: true
      - RUSTYPASTE_AUTH_TOKENS_01: 123
      - RUSTYPASTE_AUTH_TOKENS_02: 321
      - RUSTYPASTE_DELETE_TOKENS_01: 456
      - RUSTYPASTE_DELETE_TOKENS_02: 654
      - RUSTYPASTE_DEFAULT_EXPIRY: 1h
      - RUSTYPASTE_RANDOM_URL_TYPE: alphanumeric
```

### Arguments

* `rustypaste_tag` (default: `13.3`) See [#tags](#tags).

### Environment

* `RUSTYPASTE_REFRESH_RATE` (default: `30s`): Refresh rate for hot-reloading the configuration file.
* `RUSTYPASTE_ADDRESS` (default: `0.0.0.0:8000`): Address and port to listen for connections.
* `RUSTYPASTE_URL` (optional): URL used when uploading files. If not defined, the URL used by the client is chosen.
* `RUSTYPASTE_WORKERS` (optional): Sets number of workers to start (per bind address). If not defined, the available physical CPUs are chosen.
* `RUSTYPASTE_MAX_CONTENT_LENGTH` (default: `10MB`): Upload/Download limit.
* `RUSTYPASTE_UPLOAD_PATH` (default: `/var/db/rustypaste`): Where the files are stored.
* `RUSTYPASTE_TIMEOUT` (default: `30s`): Request timeout.
* `RUSTYPASTE_EXPOSE_VERSION` (default: `false`): Expose rustypaste version with the `/version` entrypoint.
* `RUSTYPASTE_EXPOSE_LIST` (default: `false`): Expose list of stored files with the `/list` entrypoint.
* `RUSTYPASTE_AUTH_TOKENS_*`: Authentication tokens. Multiple tokens are allowed, just use any suffix (e.g.: `_01`, `_02`, etc.) you want to differentiate them when processing environment variables.
* `RUSTYPASTE_DELETE_TOKENS_*`: Delete tokens to allow clients to delete files with the `DELETE` HTTP method. It has the same format for defining multiple values as explained in `RUSTYPASTE_AUTH_TOKENS_*`.
* `RUSTYPASTE_HANDLE_SPACES` (default: `replace`): Replace whitespaces with either underscore or encoded space (`%20`) character in the filenames.
* `RUSTYPASTE_RANDOM_URL_TYPE` (default: `petname`): Which method to use to generate the file names. Valid options are `petname`, `alphanumeric` and `none`.
* `RUSTYPASTE_RANDOM_URL_WORDS` (default: `2`): Number of words to be used when `RUSTYPASTE_RANDOM_URL_TYPE` is set to `petname`.
* `RUSTYPASTE_RANDOM_URL_SEPARATOR` (default: `-`): Separate words using this separator. It is only valid if `RUSTYPASTE_RANDOM_URL_TYPE` is set to `petname`.
* `RUSTYPASTE_RANDOM_URL_LENGTH` (default: `8`): Length of the filename. Only valid if `RUSTYPASTE_RANDOM_URL_URL_TYPE` has the value `alphanumeric`.
* `RUSTYPASTE_RANDOM_URL_SUFFIX_MODE` (optional): Append a random suffix to the filename before the extension. For example, `foo.tar.gz` will result in `foo.eu7f92x1.tar.gz`.
* `RUSTYPASTE_DEFAULT_EXTENSION` (default: `txt`): If the filename does not have an extension, it is replaced with this environment variable.
* `RUSTYPASTE_MIME_OVERRIDE_*`: Override MIME types. This environment variable uses `;` to separate the mime and regex, e.g. `RUSTYPASTE_MIME_OVERRIDE_01='image/jpeg;^.*\\.jpg$'`, `RUSTYPASTE_MIME_OVERRIDE_02='image/png;^.*\\.png$'`, etc. It has the same format for defining multiple values as explained in `RUSTYPASTE_AUTH_TOKENS_*`.
* `RUSTYPASTE_MIME_BLACKLIST_*`. Blacklisting MIME types. It has the same format for defining multiple values as explained in `RUSTYPASTE_AUTH_TOKENS_*`.
* `RUSTYPASTE_DUPLICATE_FILES` (default: `true`): Enable or not duplicate files.
* `RUSTYPASTE_DEFAULT_EXPIRY`: Default expiry time for uploaded files.
* `RUSTYPASTE_DELETE_EXPIRED_FILES`.
* `RUSTYPASTE_DELETE_INTERVAL`: Interval for deleting the expired files automatically.

### Volumes

| Name           | Owner | Group | Perm | Type | Mountpoint          |
| -------------- | ----- | ----- | ---- | ---- | ------------------- |
| rustypaste-db  | 498   | 498   |  -   |  -   | /var/db/rustypaste  |

## Tags
  
| Tag      | Arch    | Version        | Type   |
| -------- | ------- | -------------- | ------ |
| `13.3`   | `amd64` | `13.3-RELEASE` | `thin` |
| `14.0`   | `amd64` | `14.0-RELEASE` | `thin` |

## Notes

1. You can change the landing page by overriding the `/usr/local/etc/rustypaste/index.txt` file.
