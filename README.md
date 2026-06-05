# qmark

`qmark` is a small non-TUI terminal helper for quick command-line syntax questions.
It sends a short prompt plus lightweight shell context to a local Ollama model, then
prints a terse answer, a primary command, alternatives, requirements, notes, and risk.

```sh
qmark "find files larger than 500mb below here"
```

For the imagined `?` flow:

```sh
alias '?'='qmark'
? "what flags do I need to make a tar.gz of ./dist?"
```

## Run With Nix

From a checkout:

```sh
nix run .
```

From GitHub:

```sh
nix run github:YOUR_GITHUB_USER/qmark -- "show only names of files changed in the last git commit"
```

Install into a Nix profile:

```sh
nix profile install github:YOUR_GITHUB_USER/qmark
```

Use from another flake:

```nix
{
  inputs.qmark.url = "github:YOUR_GITHUB_USER/qmark";

  outputs = { self, nixpkgs, qmark, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          qmark.packages.${system}.default
        ];
      };
    };
}
```

## Ollama

Install and start Ollama, then pull a command-friendly model:

```sh
ollama pull qwen3-coder:30b
ollama serve
```

Pick a model with `QMARK_MODEL`:

```sh
QMARK_MODEL=qwen3-coder:30b qmark "rsync this folder with progress"
QMARK_MODEL=qwen3:14b qmark "tar gzip syntax"
```

## Private Tool Syntax

Teach `qmark` private command syntax from help output or internal docs:

```sh
my-private-tool --help | qmark --learn my-private-tool
my-private-tool deploy --help | qmark --learn my-private-tool-deploy
```

Or have `qmark` run the help command and save the output:

```sh
qmark --learn-command my-private-tool -- my-private-tool --help
qmark --learn-command deploy -- my-private-tool deploy --help
```

Then ask normally:

```sh
? "how do I deploy staging with my-private-tool?"
? "what flag controls the deploy target?"
```

Saved knowledge lives in `~/.local/share/qmark/knowledge` by default. Audit what
would be sent to the model:

```sh
qmark --show-context "how do I deploy staging?"
```

## Useful Options

```sh
qmark --cmd "git command to list files changed in HEAD"
qmark --copy "rsync this folder to my server but show progress"
qmark --run "count lines of python in this repo"
qmark --json "git command to list branches by most recent commit"
qmark --no-context "tar syntax for gzip archive"
qmark --history-lines 5 "turn my last command into a loop"
qmark --list-knowledge
```

`--run` asks before executing. Commands that look high-risk require `--unsafe` as well.
History is opt-in because shell history can contain secrets.

## Development

```sh
nix develop
python -m py_compile qmark
./qmark --help
```

Without Nix:

```sh
python3 -m py_compile qmark
./qmark --help
```
