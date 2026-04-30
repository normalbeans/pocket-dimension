#!/bin/bash

# Simple custom rich txt file reader. Handy utils to filter 
# sections, generate template.

function usage() {
cat << EOF
Usage: $(basename $0) <filename>.txt [OPTIONS]

OPTIONS:
    help, -h        -   Prints usage information (you are reading this)
    index, -i       -   Returns a list of headings and subheadings in the file.
    SECTION         -   Returns the content of the section.
                        Must be of the format "<digit>(.digit)+." The final period is optional.
                        For example: 1. or 1.2 or 1.2.3.
    generate, -g    -   Generates a template .txt file with name <filename>.txt
EOF
}

usage
