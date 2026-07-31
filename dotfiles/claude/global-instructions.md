# User Preferences

## Nix Development Environments

- Most repositories use Nix flakes (`flake.nix`) with direnv (`.envrc`) to manage project dependencies (node, pnpm, python, etc.).
- If a command fails with "command not found" (e.g., `pnpm`, `node`, `tsc`, `dprint`), the tool is likely provided by the project's Nix devShell. Retry with: `nix develop -c <the-command>`
- Always try first to execute the command, you shell may be running in an already loaded environment and there will be no need to load nix env again.
- For multiple commands, use: `nix develop -c bash -c '<command1> && <command2>'`
- The `flake.nix` may be in a parent directory. If not found in the project root, check parent directories.
- Never install tools globally with `npm install -g` or `brew install` — they should come from the Nix devShell.

## After Editing Files

- After making changes to any file (Edit, Write, NotebookEdit), if `mcp__ide__getDiagnostics` is available in the current tool list (i.e., running within an IDE context), run it on the modified file(s) to check for TypeScript errors, ESLint issues, or other diagnostics.
- If diagnostics reveal errors, fix them before moving on.

