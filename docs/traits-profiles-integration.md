# Traits & profiles integration plan

Machine **profiles** and **traits** are already selected at chezmoi init (`.chezmoi.toml.tmpl`) and written to `[data.machine]`. Nothing else in the repo reads them yet. This plan wires the rest of the source tree to that data.

## Current state

**Source of truth:** `.chezmoi.toml.tmpl`

| Profile | OS | Context | Traits |
|---------|----|---------|--------|
| `personal-laptop` | darwin | personal | `desktop`, `shell-full` |
| `personal-server` | darwin | personal | `headless`, `shell-full`, `stack-ai` |
| `corp-laptop` | darwin | corp | `desktop`, `shell-full`, `stack-cloud` |
| `corp-devbox` | linux | corp | `headless`, `shell-full`, `stack-cloud` |
| `ephemeral-sandbox` | any | none | `headless`, `shell-lite` |

**Trait meanings (intended):**

| Trait | Role |
|-------|------|
| `desktop` | GUI apps, Hammerspoon, Ghostty, browser/media casks |
| `headless` | No desktop GUI surface |
| `shell-full` | Full Fish/zsh/vim/shell trees and tooling |
| `shell-lite` | Minimal shell; skip heavy editor/plugin trees where possible |
| `stack-cloud` | gcloud / kubectl / terraform / kind-style tooling & aliases |
| `stack-ai` | AI CLIs and related secrets (e.g. Gemini) |

**Already wired:** init prompt, OS check, trait-catalog validation, git identity from `context`.

**Not wired:** ignores, packages, shell/secrets, symlinks, CI fixture data, README.

---

## Guiding rules

1. **Gate on traits (and sometimes context), not only OS.** Keep OS checks where they are about Homebrew paths or Darwin-only binaries; add trait checks for *capability*.
2. **Profiles stay the UX; traits stay the implementation knob.** Templates should almost always test `has "…" .machine.traits`, not hard-code profile names.
3. **Fail closed for missing data.** After this work, CI and local configs must always provide `[data.machine]`. Prefer `index` / explicit defaults over silent no-ops that install everything.
4. **One helper pattern.** Use the same idiom everywhere, e.g. `{{ if has "desktop" .machine.traits }}` (chezmoi/sprig `has`). Avoid inventing a second abstraction unless duplication becomes painful.
5. **Do not enforce mutual exclusivity in templates** beyond what profiles already encode (`desktop` vs `headless`, `shell-full` vs `shell-lite`). Keep exclusivity in the profile table.

---

## Phased steps

### Phase 0 — Contract & CI baseline

**Goal:** Make `[data.machine]` a required, documented shape so later template changes do not break apply/CI.

1. Update `.github/workflows/chezmoi.yml` “Write test chezmoi config” to include:
   ```toml
   [data.machine]
   profile = "ephemeral-sandbox"
   context = "none"
   traits = ["headless", "shell-lite"]
   ```
   (Optionally matrix later for `corp-devbox` / desktop profiles.)
2. Document the data contract in README (short “Machine profiles” section): init lists profiles, what gets written to `~/.config/chezmoi/chezmoi.toml`, how to re-run init / change profile.
3. Optionally add a small static check that every `*.tmpl` referencing `.machine` is covered by the CI fixture (or that the fixture always defines `traits`).

**Exit criteria:** `chezmoi apply --dry-run` in CI still passes with the new data shape; README describes the prompt.

---

### Phase 1 — Ignore & symlink gating (low risk)

**Goal:** Stop shipping desktop-only paths to headless machines; lighten `shell-lite`.

1. **`.chezmoiignore.tmpl`**
   - Ignore `dot_hammerspoon` unless `has "desktop" .machine.traits` (replace or complement the current Darwin-only check).
   - Ignore `dot_config/ghostty` unless `desktop`.
   - Consider ignoring other GUI-adjacent paths the same way.
2. **`symlink_dot_{vim,zsh,shell}.tmpl` / ignore rules**
   - For `shell-lite`: ignore or skip heavy `vim` / full `zsh` plugin trees if the intent is a thin sandbox; keep a minimal Fish or bare shell path.
   - Decide explicitly: does `shell-lite` still get Fish + `dfu`, or only a stub? Record the decision in this doc when implementing.
3. Keep `README.md` / non-dotfile source files ignored as today.

**Exit criteria:** Applying `ephemeral-sandbox` / `corp-devbox` does not link Hammerspoon or Ghostty; desktop profiles still do on Darwin.

---

### Phase 2 — Package surface (`Brewfile`)

**Goal:** End “one Brewfile installs Steam + k8s + AI on every Mac.”

**Recommended approach:** split by trait into multiple Brewfiles, then have `run_onchange_install-packages.sh.tmpl` bundle each present trait:

| File (proposed) | Trait / condition |
|-----------------|-------------------|
| `dot_Brewfile` or `Brewfile.base` | Always on Darwin (chezmoi, fish, tmux, coreutils, gh, 1password-cli, …) |
| `Brewfile.desktop` | `desktop` — Ghostty, Hammerspoon, browsers, media, Steam, … |
| `Brewfile.stack-cloud` | `stack-cloud` — kind, kubectl, terraform, docker, … |
| `Brewfile.stack-ai` | `stack-ai` — gemini-cli, claude-code, openclaw, … |
| *(none for shell-lite extras)* | Base only |

Implementation sketch for the run script:

```sh
brew bundle --file=…/Brewfile.base --no-upgrade
# then conditionally brew bundle each trait file that exists / is selected
```

Notes:

- Keep `--no-upgrade` and “no `brew bundle dump`” behavior from the current script.
- Linux profiles that need packages are out of scope for Homebrew; document that `corp-devbox` does not use this run script today (`darwin`-only guard stays unless you add a separate path later).
- `go` tools / language servers: put in `shell-full` or base, not desktop.

**Exit criteria:** `personal-laptop` does not pull cloud/AI casks; `corp-laptop` pulls cloud not AI GUI stack; `personal-server` pulls AI not desktop casks.

---

### Phase 3 — Shell, aliases, and secrets

**Goal:** Load stack-specific config only when the trait is present.

1. **Cloud aliases** (`shell/aliases.sh` `g`/`k`/`tf`, Fish abbreviations in `20-abbreviations.fish`): either
   - split into `aliases.cloud.sh` sourced from a templated wrapper when `stack-cloud`, or
   - generate those lines from a `.tmpl` gated on the trait.
2. **AI secrets** (`60-secrets.fish`, `dot_zshrc.tmpl` `GEMINI_API_KEY`): load only if `stack-ai` (and ideally `context` ≠ `none` if secrets should never hit sandboxes).
3. **PATH / Homebrew blocks** in `00-path.fish.tmpl` and `dot_zshrc.tmpl`: keep OS-based Homebrew prefixes; do not conflate with traits.
4. **Optional:** expose a small Fish/zsh helper that prints current profile/traits for debugging (`chezmoi data` is enough at first).

**Exit criteria:** `ephemeral-sandbox` does not attempt Gemini secret load or cloud abbrs; cloud profiles still get `g`/`k`/`tf`.

---

### Phase 4 — Identity polish (orthogonal but related)

**Goal:** Align machine display name with the new init model.

1. Revisit draft machine-name work (prompt for a friendly `machine_name` at init, write `~/.name`).
2. Keep `machine_name` separate from `profile` (profile = role pack; name = host label for tmux/prompt).
3. Update CI fixture and `dot_name.tmpl` accordingly.

**Exit criteria:** Prompt shows profile list *and* optional name; tmux/zsh prompt use the friendly name, not raw OS.

---

### Phase 5 — Hardening & docs

1. README: profile table, trait glossary, how to change profile (`chezmoi init` / edit `chezmoi.toml` + re-apply).
2. Comment in `.chezmoi.toml.tmpl` pointing at this doc.
3. Optional CI matrix: render/apply with at least one desktop-less and one `stack-cloud` fixture (Darwin job only if you need Brewfile path tests; Linux remains the cheap default).
4. Migration note for existing machines: existing `chezmoi.toml` without `[data.machine]` must be regenerated or hand-edited before apply after Phase 1+.

---

## Suggested implementation order (PRs)

| PR | Scope | Why this order |
|----|-------|----------------|
| 1 | Phase 0 (CI + README contract) | Unblocks safe template use of `.machine` |
| 2 | Phase 1 (ignore / symlink) | Immediate value, small blast radius |
| 3 | Phase 2 (Brewfile split + run script) | Largest behavior change; isolate review |
| 4 | Phase 3 (shell / secrets) | Depends on traits being trusted in templates |
| 5 | Phase 4 (machine_name) | Nice-to-have; independent of packages |
| 6 | Phase 5 leftovers / CI matrix | After consumers exist |

Prefer small PRs; do not combine Brewfile splits with ignore changes unless necessary.

---

## Non-goals (for this integration)

- Redesigning the profile catalog or renaming traits.
- Enforcing trait exclusivity beyond the profile table.
- Non-Homebrew package management on Linux.
- Per-app feature flags finer than the six traits.
- Auto-migrating old `chezmoi.toml` files in-place without user action.

---

## Verification checklist (per phase)

- [ ] `chezmoi execute-template` / CI render succeeds with fixture `[data.machine]`.
- [ ] Dry-run apply on Linux CI for `ephemeral-sandbox` (and later a cloud profile).
- [ ] Manual apply on a Darwin machine for at least one desktop and one headless profile.
- [ ] Confirm ignored paths absent from destination; Brew bundles match traits.
- [ ] Confirm git `user.email` still follows `context` (corp vs personal).

---

## Key files

| File | Change type |
|------|-------------|
| `.chezmoi.toml.tmpl` | Already defines catalog; later: comments / optional `machine_name` |
| `.chezmoiignore.tmpl` | Trait-based ignores |
| `dot_Brewfile` (+ splits) | Trait-scoped packages |
| `run_onchange_install-packages.sh.tmpl` | Multi-file `brew bundle` |
| `shell/aliases.sh` / Fish abbrs / secrets | Trait-gated loading |
| `symlink_dot_*.tmpl` | Possibly `shell-lite` behavior |
| `.github/workflows/chezmoi.yml` | Fixture `[data.machine]` |
| `README.md` | User-facing profile docs |
| `dot_name.tmpl` / `dot_gitconfig_local.tmpl` | Identity (name / already uses git data) |
