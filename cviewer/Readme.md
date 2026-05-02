#### CViewer

Custom rich text reader utility. For personal use to maintain consistent and uniform notes.

```
Usage: cv <filename>.txt <OPTION>
        OR
       cv help|-h

  OPTION:
    help, -h        - Prints usage information (you are reading this)
    index, -i       - Returns a list of headings and subheadings in the file.
    SECTION         - Returns the content of the section.
                      Must be of the format "<digit>(.digit)+." The final period is optional.
                      For example: 1. or 1.2 or 1.2.3.
    generate, -g    - Generates a template .txt file with name <filename>.txt

```