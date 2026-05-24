# Release Guide

This project is released as a lightweight practice kit, not a package-manager-first product. GitHub Releases are the default distribution channel.

## Release Checklist

1. Update `VERSION`.
2. Update `CHANGELOG.md` with the release date and user-facing changes.
3. Run local checks:

```bash
bash -n install.sh doctor.sh upgrade.sh tests/smoke.sh
./tests/smoke.sh
```

4. Manually verify a fresh install in a temporary project:

```bash
tmp="$(mktemp -d)"
./install.sh "$tmp"
./doctor.sh "$tmp"
```

5. Manually verify upgrade from the previous version if upgrade behavior changed.
6. Commit the release changes.
7. Create and push a tag:

```bash
git tag "v$(cat VERSION)"
git push origin "v$(cat VERSION)"
```

8. Create a GitHub Release using the changelog entry as release notes.

## Release Notes Template

~~~markdown
## Context Engineering Kit vX.Y.Z

### Highlights
- ...

### Upgrade Notes
- Commands in `.claude/commands/` are overwritten.
- Existing project docs, prompts, and memory files are preserved.
- New templates are created only when missing.

### Verify
```bash
/path/to/context-engineering-kit/doctor.sh /path/to/your-project
```
~~~

## Distribution

Use the GitHub source archive or a cloned checkout:

```bash
git clone https://github.com/<owner>/context-engineering-kit.git
cd context-engineering-kit
./install.sh /path/to/your-project
```

Do not add Homebrew, npm, or other package-manager distribution until there is clear user demand.
