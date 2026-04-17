# Appwrite Homebrew Tap

Official [Homebrew](https://brew.sh) tap for the [Appwrite CLI](https://github.com/appwrite/sdk-for-cli).

## Install

```bash
brew install appwrite/appwrite/appwrite
```

That single command both adds this tap and installs the native CLI binary for your platform (macOS and Linux, x86_64 and arm64).

If you prefer to tap first and install separately:

```bash
brew tap appwrite/appwrite
brew install appwrite
```

## Upgrade

```bash
brew upgrade appwrite/appwrite/appwrite
```

## Uninstall

```bash
brew uninstall appwrite
brew untap appwrite/appwrite
```

## How it works

The formula in [`Formula/appwrite.rb`](./Formula/appwrite.rb) downloads the prebuilt native binary from the [`appwrite/sdk-for-cli`](https://github.com/appwrite/sdk-for-cli/releases) release matching the tap's pinned version, verifies its SHA256, and installs it as `appwrite`.

When the Appwrite CLI publishes a new release, the [`appwrite/sdk-for-cli`](https://github.com/appwrite/sdk-for-cli) publish workflow opens a pull request against this repo that updates the formula's `version` and the four per-target SHA256 checksums. Merging that PR rolls the tap out to users on their next `brew upgrade`.

## Contribute

This tap is intentionally small — the only thing that lives here is the formula and the GitHub workflow that keeps it clean. If the formula needs to be re-structured (new build targets, dependencies, bottling, etc.), open a PR against this repo. If the CLI itself needs changes, open the PR against [`appwrite/sdk-generator`](https://github.com/appwrite/sdk-generator) (templates) or [`appwrite/sdk-for-cli`](https://github.com/appwrite/sdk-for-cli) (generated output).

## License

The CLI and this formula are released under the [BSD-3-Clause license](https://github.com/appwrite/sdk-for-cli/blob/master/LICENSE.md). The repository scaffolding (workflows, README) is released under [BSD-2-Clause](./LICENSE) to match the Homebrew tap convention.
