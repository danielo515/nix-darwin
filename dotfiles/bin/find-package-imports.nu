#!/usr/bin/env nu

# Find all directories that import from a specific package
# Example: find-package-imports.nu effect
def main [package: string] {
    rg $'from "($package)"' -l 
    | each {|| path split | slice 0..1 | str join '/'} 
    | uniq 
    | sort
}
