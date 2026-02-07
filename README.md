# Józef Image

Custom runtime Docker image for Józef agent — based on `node:22-bookworm` with additional tools.

## Included Tools

- **Node.js** 22.x
- **Bun** 1.x  
- **Python** 3.11 + pip
- **Vim**
- **curl**, **git**, **ssh**
- **pnpm** (via corepack)

## Usage

### Pull from GitHub Container Registry

```bash
# Latest stable release
docker pull ghcr.io/ioseph-ai/jozef-image:latest

# Specific version
docker pull ghcr.io/ioseph-ai/jozef-image:1.2.3

# Latest in 1.x series
docker pull ghcr.io/ioseph-ai/jozef-image:1
```

### Run locally

```bash
docker run --rm -it ghcr.io/ioseph-ai/jozef-image:latest bash
```

## Versioning (Semver)

Ten projekt używa [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH).

### Jak wydać nową wersję

```bash
# Drobna zmiana (patch) - np. bugfix
git tag v1.2.4
git push origin v1.2.4

# Nowa funkcjonalność (minor)
git tag v1.3.0
git push origin v1.3.0

# Zmiana niekompatybilna (major)
git tag v2.0.0
git push origin v2.0.0
```

### Automatyczne tagi Docker

Po pushu tagu `v1.2.3`, CI utworzy obrazy z tagami:

| Git Tag | Tagi Docker |
|---------|-------------|
| `v1.2.3` | `1.2.3`, `1.2`, `1`, `latest` |
| `v1.2.4` | `1.2.4`, `1.2`, `1`, `latest` |
| `v1.3.0` | `1.3.0`, `1.3`, `1`, `latest` |
| `v2.0.0` | `2.0.0`, `2.0`, `2`, `latest` |

Dzięki temu możesz:
- Przypiąć do konkretnej wersji: `:1.2.3`
- Automatycznie aktualizować patch: `:1.2` (dostaniesz 1.2.4, 1.2.5 itd.)
- Automatycznie aktualizować minor: `:1` (dostaniesz 1.3.0, 1.4.0 itd.)
- Zawsze mieć najnowsze: `:latest`

## Build Locally

```bash
docker build -t jozef-image:local .

# Test
./tests/test.sh
```

## CI/CD

GitHub Actions workflow:
1. Uruchamia testy na każdym PR/push
2. Buduje i pushuje do GHCR na push do main lub tag
3. Taguje obrazy semver + branch + SHA

## License

MIT
