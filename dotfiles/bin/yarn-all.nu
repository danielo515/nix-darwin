#!/usr/bin/env nu
# Executes a command in all subfolders containing a package.json
# exclusion rules are specific to yarn, to prevent getting into .yarn dependency folders
let folders = glob ./**/package.json | filter { $in | str contains ".yarn" | not $in }

export def main [cmd: string, --dry = false] {

print $"Running '($cmd)' in ($folders | length) subfolders containing a package.json"
    
$folders | par-each {
    let folder = $in | path dirname
    cd $folder
    try {
        if $dry {
            print $"Not running '($cmd)' in '($folder)'"
        } else {
            print -n "."
            bash -c $"($cmd)"
        }
    } catch {
        print -e $"Error in '($folder)'"
    }
}
}
