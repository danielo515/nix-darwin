#!/usr/bin/env nu

# Delete all merged branches that you pick from a list
def main [] {
    let branches = git branch --merged | grep -v "main" | grep -v "master" | grep -v "dev" | fzf -m
    echo $branches | lines | each {str trim} | each { |branch| git branch -d $branch }
}
