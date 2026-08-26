# Git Hooks

The hooks are managed with **pnpm** + Node, so you need both installed. They are
optional: every hook exits cleanly when its tooling is missing.

Used libraries:
* [husky](https://typicode.github.io/husky/) — installs the git hooks
* [commitizen](https://commitizen-tools.github.io/commitizen/) — interactive
  prompt that builds the commit message
* [cz-customizable](https://www.npmjs.com/package/cz-customizable) — commitizen
  adapter; reads the types from `.cz-config.js`
* [commitlint-config-gitmoji](https://www.npmjs.com/package/commitlint-config-gitmoji)
  — the gitmoji ruleset referenced by `commitlint.config.js`

## Installation

1. install packages
    ```shell
    pnpm i
    ```
2. Prepare husky
    ```shell
    pnpm run prepare
    ```

`prepare` writes the `core.hooksPath` git config that points at `.husky/`.

## What each hook does

| Hook | Runs |
|---|---|
| `prepare-commit-msg` | opens the commitizen prompt |
| `pre-commit` | `dart format --set-exit-if-changed lib`, then `flutter analyze` |
| `pre-push` | (no-op) |

`pre-commit` prints a warning and exits 0 when `flutter` is not on PATH, so it
never blocks a machine without the SDK.

## How to use it

```shell
git commit
```

The prompt appears, you pick a type from `.cz-config.js`, and the message is
assembled for you. To bypass the prompt for a one-off commit:

```shell
git commit -m ":memo: docs(global): fix typo" --no-verify
```

## Configuration files

| File | Purpose |
|---|---|
| `.cz-config.js` | the list of commit types and scopes shown in the prompt |
| `commitlint.config.js` | extends the `gitmoji` ruleset |
| `package.json` → `config.cz-customizable.config` | points commitizen at `.cz-config.js` |

## Adding a scope

`.cz-config.js` currently allows only `global`, and `allowCustomScopes` is
`false`. Add new scopes to the `scopes` array — one per feature folder is a good
default.
