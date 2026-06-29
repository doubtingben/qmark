# qmark

`qmark` is a small non-TUI terminal helper for quick command-line syntax questions.
It sends a short prompt plus lightweight shell and repository context to a chat
model, then prints a terse answer, a primary command, alternatives, requirements,
notes, and risk.

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

## OpenRouter Or Other Remote APIs

`qmark` can also use OpenAI-compatible chat completion APIs. For OpenRouter:

```sh
export OPENROUTER_API_KEY=sk-or-...
qmark --provider openrouter \
  "rsync this folder with progress"
```

Remote providers default to `z-ai/glm-5.2`. Pass `--model` or set
`QMARK_MODEL` to use a different model.

To make that the default:

```sh
export QMARK_PROVIDER=openrouter
export QMARK_BASE_URL=https://openrouter.ai/api/v1
export OPENROUTER_API_KEY=sk-or-...
```

Then run:

```sh
qmark "tar gzip syntax"
```

All remote configuration can use `QMARK_*` variables:

```sh
export QMARK_MODE=openrouter
export QMARK_BASE_URL=https://openrouter.ai/api/v1
export QMARK_NAMESPACE=z-ai
export QMARK_MODEL=glm-5.2
export QMARK_API_KEY=sk-or-...
```

`QMARK_PROVIDER` and `QMARK_MODE` both select the provider. `QMARK_PROVIDER`
takes precedence when both are set. `QMARK_NAMESPACE` is prepended only when
the model does not already contain a `/`, so `QMARK_MODEL=z-ai/glm-5.2` works
too.

For other OpenAI-compatible APIs, set `QMARK_BASE_URL` to the API base URL
that contains `/chat/completions` under it, and set either `QMARK_API_KEY` or
`OPENAI_API_KEY`.

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

By default, context includes the current OS, shell, cwd, current directory
entries, and, when run inside a git worktree, the git root, branch, dirty status,
tracked-file summary, and capped excerpts from project files such as README,
flake, package, Makefile, pyproject, go.mod, Cargo, Docker, and task-runner
configuration files. Use `--no-context` to disable this.

## Useful Options

```sh
qmark "git command to list files changed in HEAD"
qmark --verbose "git command to list files changed in HEAD"
qmark --copy "rsync this folder to my server but show progress"
qmark --run "count lines of python in this repo"
qmark --json "git command to list branches by most recent commit"
qmark --no-context "tar syntax for gzip archive"
qmark --history-lines 5 "turn my last command into a loop"
qmark --list-knowledge
```

By default, `qmark` prints only the command when the model has high confidence
and the command is not high-risk. Use `--verbose` or `-v` to print the full
answer, alternatives, requirements, notes, risk, and confidence. `--cmd` always
prints only the primary command.

`--run` asks before executing. Commands that look high-risk require `--unsafe` as well.
History is opt-in because shell history can contain secrets.
Interactive runs show a stderr status line while waiting for the model, including
elapsed time. Use `--no-status` or set `QMARK_NO_STATUS=1` to disable it.

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
