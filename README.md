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

## Versioning

Wersja obrazu składa się z dwóch części: **WERSJA_OPENCLAW-SEMVER_REPO**.

Przykład: `2026.2.6-3-v0.1.0` oznacza OpenClaw w wersji `2026.2.6-3` i obraz repo w wersji `v0.1.0`.

### Jak wydać nową wersję

```bash
# Drobna zmiana (patch) - np. bugfix w obrazie
git tag v0.1.1
git push origin v0.1.1

# Nowa funkcjonalność (minor) - np. nowe narzędzie
git tag v0.2.0
git push origin v0.2.0

# Zmiana niekompatybilna (major)
git tag v1.0.0
git push origin v1.0.0
```

### Automatyczne tagi Docker

Po pushu tagu `v0.1.0`, CI utworzy obrazy z tagami:

| Git Tag | Tagi Docker (przykład) | Opis |
|---------|------------------------|------|
| `v0.1.0` | `2026.2.6-3-v0.1.0` | Pełna wersja |
| `main` | `2026.2.6-3-latest`, `latest` | Najnowsza z main |
| - | `<sha>` | Commit SHA |

Dzięki temu wiesz dokładnie jaka wersja OpenClaw jest w środku.

### Sprawdź wersję OpenClaw w obrazie

```bash
docker run --rm ghcr.io/ioseph-ai/jozef-image:latest node openclaw.mjs --version
```

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
