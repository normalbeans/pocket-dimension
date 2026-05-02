#!/bin/bash

# Simple custom rich txt file reader. Handy utils to filter 
# sections, generate template.


function usage() {
cat << EOF

Usage: $(basename $0) <filename>.txt <OPTION>
        OR
       $(basename $0) help|-h

  OPTION:
    help, -h        - Prints usage information (you are reading this)
    index, -i       - Returns a list of headings and subheadings in the file.
    SECTION         - Returns the content of the section.
                      Must be of the format "<digit>(.digit)+." The final period is optional.
                      For example: 1. or 1.2 or 1.2.3.
    generate, -g    - Generates a template .txt file with name <filename>.txt
EOF
}

FILENAME=${1:-"help"}
SECOND=${2:-"view"}

# constants
RED="\033[38;2;255;100;100m"
GREEN="\033[38;2;153;255;174m"
PURPLE="\033[38;2;182;163;255m"
BLUE="\033[38;2;89;198;255m"
YELLOW="\033[33m"
NC="\033[0m"

SECTION_REGEX='[0-9]+(\.[0-9]+)*\.?'

if [[ "${FILENAME}" == "help" || "${FILENAME}" == "-h" ]];then
    usage
    exit 0
fi

if [[ ! -f "${FILENAME}" ]];then
    if [[ ! ("${SECOND}" == "generate" || "${SECOND}" == "-g") ]];then
        echo -e "${RED}ERROR${NC}: ${FILENAME} not found."
        usage
        exit 1
    fi
fi

function generateTemplate() {
    templateName=$(echo $1 | cut -d . -f 1)
    templateSuffix=$(echo $1 | cut -d . -f 2)
    tFile="${templateName}.${templateSuffix}"
    if [[ -f "${tFile}" ]];then
        # get free counter
        i=0
        while [[ -f "${templateName}${i}.${templateSuffix}" ]];do
            i=$((i+1))
        done
        tFile="${templateName}${i}.${templateSuffix}"
    fi
    touch $tFile

    cat << EOF > $tFile
======================================================================
Title   : Template for standardised personal notes.
Author  : XYZ
Date    : DD-MM-YYYY
======================================================================

1. What does this template describe?

    This template describes the general structure and symbol guidelines to be used while
    writing docs or notes using a standard .txt file. The template format makes it easier
    to read the contents and allows for parsing the sections using a custom rich txt parser
    tool.

---

2. Document flow

    The document contains 3 main blocks: The document information block - containing title, author
    and date ( and any other custom information ), the content block and the ending block (optional
    block). The content block consists of 1 or more sections each separated using a separator.
    Each section can have nested subsections but it is generally recommended to limit deep nesting of
    subsections for clarity.

    Certain symbols can have special meaning while using a custom rich .txt parser, which are described
    in section 3.
    
---

3. This is a heading

    3.1. This is a first level subheading

        This is some text content within the first level subheading. Note that indentations
        are not strict but it is recommended to use them for visual clarity.

        3.1.2. This is a second level subheading

            > This is a comment. Comments are printed along with main content. You can think of them
            > as notes for the document.

    3.2. List entry

        - List element A
        - List element B
        - List element C
    
    3.3. Code Block

        +++
        // This represents a code snippet. Content within the +++ blocks must conform
        // to language syntax.
        func doSomething() {
            fmt.Println("Did something!")
        }
        +++

    3.4. Separators

        - Main sections are separated using '---'.
        - Code blocks are separated using enclosing '+++'.
        - Document information and ending content are separated using encloding '==='.

---

4. Tradeoffs

    - Ensure content lines don't start with numbers resembling section or subsection counters after a 
      newline. cviewer does not consider this scenario.


======================================================================
Ending block
======================================================================
EOF

    echo -e "Generated template: ${GREEN}${tFile}${NC}"
}


function colorify() {
    code_block=false
    end_block=false
    while IFS= read -r line; do 
        if [[ "${line}" =~ ^===* ]];then
            if $end_block;then
                end_block=false
            else
                end_block=true
            fi
            echo -e "${RED}${line}${NC}"
        elif [[ "${line}" =~ ^---$ ]];then
            echo -e "${YELLOW}${line}${NC}"
        elif [[ "${line}" =~ ^[[:space:]]+\+\+\+$ ]];then
            if $code_block;then
                code_block=false
            else
                code_block=true
            fi
            echo -e "${GREEN}${line}${NC}"
        elif [[ "${line}" =~ ^[[:space:]]*\>.*$ ]];then
            echo -e "${PURPLE}${line}${NC}"
        elif [[ "${line}" =~ ^[[:space:]]*[0-9]+(\.[0-9]+)*\.?[[:space:]]+[A-Za-z0-9_' '?:-]+$ ]];then
            echo -e "${BLUE}${line}${NC}"
        else
            if $code_block;then
                echo -e "${GREEN}${line}${NC}"
            elif $end_block;then
                echo -e "${RED}${line}${NC}"
            else
                echo "${line}"
            fi
        fi
    done
}


case "${SECOND}" in 
    "help" | "-h")
        usage
        exit 0
    ;;
    "generate" | "-g")
        generateTemplate $FILENAME
    ;;
    "index" | "-i")
        awk '/^[[:space:]]*[0-9]+(\.[0-9]+)*\.?[[:space:]]+[A-Za-z0-9_ ?:-]+$/ {print $0}' $FILENAME
    ;;
    "view")
        cat $FILENAME | colorify
    ;;
    *)
        if [[ "${SECOND}" =~ $SECTION_REGEX ]];then
            SECTION="${SECOND%.}."
            awk -v SECTION=$SECTION \
                '/^[[:space:]]*[0-9]+(\.[0-9]+)*\.?[[:space:]]+[A-Za-z0-9_ ?:-]+/ {
                    if($1 == SECTION) {
                        secbegin=1; 
                        level=split($1,parts, ".");
                        print $0; 
                        next;}
                    } 
                secbegin && /^[[:space:]]*[0-9]+(\.[0-9]+)*\.?[[:space:]]+[A-Za-z0-9_ ?:-]+/ {
                    clevel=split($1, parts, ".");
                    if (clevel <= level) {
                        secbegin=0; next
                    }
                } 
                secbegin && /^===*|^---$/ {secbegin=0; next}
                secbegin {print $0}' $FILENAME | colorify
        else
            echo -e "${RED}ERROR${NC}: Uknown option ${SECOND}"
            usage
            exit 1
        fi
    ;;
esac
