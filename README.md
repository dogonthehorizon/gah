# gah!

`gah` is a simple Github Actions CLI for the flumoxed developer.

It aims to be simple by infering as much context as possible before making
requests, while still allowing you to precisely define what information you
need from the GitHub Actions API. The fully realized goal of `gah` is to
provide straightforward workflow lifecycle management from jobs to secrets.

### What's in a Name?

`gah` is a GitHub Actions tool written in [Haskell], so taking the initials of each
word you get `gah`, a common expression of exasperation.

## Table of Contents

* [Installation](#installation)
* [Configuration](#configuration)
* [Usage](#usage)
    * [Getting Logs](#getting-logs)
    * [Triggering Workflows](#triggering-workflows)
    * [Re-Running Workflows](#re-running-workflows)
    * [Cancelling Workflows](#cancelling-workflows)
    * [Creating Secrets](#creating-secrets)
    * [Deleting Secrets](#deleting-secrets)
    * [Updating Secrets](#updating-secrets)

## Installation

### from GitHub

`gah` can be installed from GitHub Releases. To install the latest version run
the following commands.

For Linux users:

```bash
bash -c \
  'curl -fsSL -o gah "https://github.com/dogonthehorizon/gah/releases/latest/download/gah-linux-amd64"' \
  && chmod +x gah
```

For macOS users:

```bash
bash -c \
  'curl -fsSL -o gah "https://github.com/dogonthehorizon/gah/releases/latest/download/gah-macos-amd64"' \
  && chmod +x gah
```

If you want to install a specific release, you can naviate to the [releases page]
and grab the URL for the desired release to download.

You can then move the binary to somewhere in your environment's `$PATH`.

_Note: at this time only Linux binaries are statically compiled._

### from Source

`gah` can optionally be compiled from source. You will need the [`stack`]
program to build this project.

You can build and copy the binary for this project by running the following
command:

```bash
stack build --copy-bins
```

This may take a while if you don't usually work with Haskell projects, feel
free to grab a beverage of your choice and come back in 5-10 minutes.

A future release will provide binaries for Mac and Linux, as well as Windows if
it isn't too onerous to do.

## Configuration

`gah` requires [personal access token][token] to function. It needs one for a
few reasons:

- Unauthenticated access to the GitHub API is capped at around 60 requests per
hour. Each run requires a few API calls, so you'll quickly exhaust your limit.
- If you want to pull logs for private repositories or organizations that use
SSO authentication, you'll need a token.

If your project is private, you'll also need to provide the following
permissions at token creation time:

- `repo`

Once you've created your token you can store it
[somewhere secret, somewhere safe][gandalf], and reference it via the
`GAH_GITHUB_TOKEN` environment variable. Here's a sample invocation:

```bash
GAH_GITHUB_TOKEN=$(cat .github_token) gah logs my-org/my-repo latest
```

## Usage

If this is your first time using `gah`, make sure you look at the `Configuration`
section to make sure your environment is properly setup.

### Getting Logs

__Since: 0.1.0__

__Updated: 0.2.0__

You can retrieve the latest logs for a given org/repo combination:

```bash
gah logs --organization my-org --repository my-repo
```

If your project supports multiple workflows, you can specify the desired workflow
with the `--workflow` or `-w` flag:

```bash
gah logs --organization my-org --repository my-repo --workflow my-workflow
```

If you'd like to find logs for a particular branch, you can inform `gah` with
the `--branch` or `-b` flags:

```
gah logs --organization my-org --repository my-repo --branch my-branch
```

You can specify one or both of workflow and branch flags to filter results
accordingly.

Short flags are also available:

```bash
gah logs -o my-org -r my-repo -w my-workflow -b my-branch
```

### Triggering Workflows

__Since: ☢ planned, not yet implemented__

### Re-Running Workflows

__Since: ☢ planned, not yet implemented__

### Cancelling Workflows

__Since: ☢ planned, not yet implemented__

### Creating Secrets

__Since: ☢ planned, not yet implemented__

### Deleting Secrets

__Since: ☢ planned, not yet implemented__

### Updating Secrets

__Since: ☢ planned, not yet implemented__

[token]: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
[gandalf]: https://i.imgflip.com/1mp8zb.gif
[Haskell]: https://www.haskell.org/
[`stack`]: https://docs.haskellstack.org/en/stable/README/
[releases page]: https://github.com/dogonthehorizon/gah/releases
