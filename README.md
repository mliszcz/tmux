# AppImage builds for https://github.com/tmux/tmux

This repository contains AppImages with tmux.

Features:
* it is built on `centos:7` (compatible with many old distros),
* all dependencies are statically compiled in (except glibc),
* an up-to-date terminfo database is included.

## Workflow

Releases containing AppImages are created on every push to the `add-appimage`
branch. To create a new AppImage it is sufficient to rebase this branch on a
desired commit from the upstream `master` branch and do a forced push.

*NOTE: 'Sync fork' GitHub UI feature should not be used for the `add-appimage`
branch as it creates a merge commit.*

NOTE: I asked the maintainers about providing AppImages directly in the
upstream repository but they rejected the idea.
See: https://github.com/tmux/tmux/issues/3351
