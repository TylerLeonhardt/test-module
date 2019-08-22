# GitHub Actions test-module

[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2FTylerLeonhardt%2Ftest-module%2Fbadge&style=flat)](https://actions-badge.atrox.dev/TylerLeonhardt/test-module/goto)

This is a dummy module used to test out functionality of GitHub Actions.

Shout to @devblackops for his PSScriptAnalyzer action!

The yml is located [here](https://github.com/TylerLeonhardt/test-module/blob/master/.github/workflows/ci.yml).

It will:
- Run PSSA
- "Build" by running Pester tests
- Publish artifacts for each platform
