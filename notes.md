# Nix Derivation and writeShellApplication Research Notes

This document contains research findings about Nix derivations and the `writeShellApplication` function, including default environment variables and available parameters.

## Commands Used for Research

### Extracting Arguments for writeShellApplication

To find out what arguments are available for the `writeShellApplication` function:

```bash
nix-instantiate --eval -E 'with import <nixpkgs> {}; builtins.attrNames (builtins.functionArgs writeShellApplication)'
```

Result:
```
[ "bashOptions" "checkPhase" "derivationArgs" "excludeShellChecks" "extraShellCheckFlags" "inheritPath" "meta" "name" "passthru" "runtimeEnv" "runtimeInputs" "text" ]
```

### Checking Default Environment Variables

To check if a specific environment variable is set by default:

```bash
nix-instantiate --eval -E 'with import <nixpkgs> {}; builtins.getEnv "NIX_STORE"'
```

### Viewing Source Code of writeShellApplication

To view the source code of the `writeShellApplication` function:

```bash
curl -s https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/build-support/trivial-builders/default.nix | grep -A 100 "writeShellApplication ="
```

## Default Environment Variables in Nix Derivations

When Nix builds a derivation, it sets several environment variables automatically:

### Standard Nix Build Environment Variables

- `NIX_STORE`: Path to the top-level Nix store directory (typically `/nix/store`)
- `NIX_BUILD_TOP`: Path to the temporary build directory
- `TMPDIR`, `TEMPDIR`, `TMP`, `TEMP`: All point to the temporary directory
- `PATH`: Initially set to `/path-not-set` but will include all `runtimeInputs`
- `HOME`: Set to `/homeless-shelter` by default to prevent programs from using `/etc/passwd`

### In writeShellApplication

- The script automatically gets all the `runtimeInputs` added to the `PATH`
- Custom environment variables can be set via the `runtimeEnv` attribute
- The script name is available via the command name (`$0`)
- Bash options like `errexit`, `nounset`, and `pipefail` are set by default

## Available Parameters for writeShellApplication

From the source code, the following parameters are available:

- `name`: The name of the script to write (String)
- `text`: The shell script's text, not including a shebang (String)
- `runtimeInputs`: Inputs to add to the shell script's `$PATH` at runtime (List of String or Derivation)
- `runtimeEnv`: Extra environment variables to set at runtime (AttrSet)
- `meta`: `stdenv.mkDerivation`'s `meta` argument (AttrSet)
- `passthru`: `stdenv.mkDerivation`'s `passthru` argument (AttrSet)
- `checkPhase`: The `checkPhase` to run. Defaults to `shellcheck` on supported platforms and `bash -n` (String)
- `excludeShellChecks`: Checks to exclude when running `shellcheck`, e.g. `[ "SC2016" ]` (List of String)
- `extraShellCheckFlags`: Extra command-line flags to pass to ShellCheck (List of String)
- `bashOptions`: Bash options to activate with `set -o` at the start of the script. Defaults to `[ "errexit" "nounset" "pipefail" ]` (List of String)
- `derivationArgs`: Extra arguments to pass to `stdenv.mkDerivation` (AttrSet)
- `inheritPath`: Whether to inherit the current `$PATH` in the script (Boolean)

## Best Practices

1. **Use `$(basename "$0")` Instead of Hardcoded Name**:
   - Use `$(basename "$0")` to get the script name dynamically
   - This makes the script more maintainable if the name changes in the future

2. **Use Environment Variables for Configuration**:
   - Set configuration values using `runtimeEnv` to make them easily accessible
   - This makes the script more readable and maintainable

3. **Set Appropriate Bash Options**:
   - The default options (`errexit`, `nounset`, `pipefail`) are good for most scripts
   - These options help catch errors early and make scripts more robust

4. **Include Necessary Runtime Inputs**:
   - Add all required tools to `runtimeInputs` to ensure they're available in the script's `PATH`
   - This eliminates the need to hardcode paths to executables
