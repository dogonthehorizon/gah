# gah!

`gah` is a Github Actions CLI written in Haskell for the flumoxed developer.

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

### Logs

Gah! Just gimme some logs for my repo in my organization:

```bash
gah just gimme logs for my-org my-repo
```

Alternatively, if you have no sense of humor:

```bash
gah logs my-org my-repo latest
```

[token]: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
[gandalf]: https://i.imgflip.com/1mp8zb.gif
