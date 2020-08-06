# gah!

Gah! `gah` is a Github Actions command line tool written in Haskell for the
flumoxed developer.

## Configuration

`gah` requires an API key to function properly. At the time of this writing
you'll need to create a [personal access token][token]. If your project is
private, you'll also need to provide the following permissions:

- `repo`

Once you've created your token you can store it
[somewhere secret, somewhere safe][gandalf], and reference it via the
`GAH_GITHUB_TOKEN` environment variable. Here's a sample invocation:

```bash
GAH_GITHUB_TOKEN=$(cat .github_token) gah logs my-org/my-repo latest
```

## Usage

### Logs

Gah! Just gimme some logs for my project in my organization.

```bash
gah just gimme logs for my-org my-repo latest
```

If you have no sense of humor:

```bash
gah logs my-org my-repo latest
```

[token]: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
[gandalf]: https://i.imgflip.com/1mp8zb.gif
