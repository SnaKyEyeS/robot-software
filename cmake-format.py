# Configuration for https://github.com/cheshirekow/cmake_format

with section("format"):
    # How wide to allow formatted cmake files
    line_width = 100

    # How many spaces to tab for indent
    tab_size = 4

    # If true, separate flow control names from their parentheses with a space
    separate_ctrl_name_with_space = False

    # If true, separate function names from parentheses with a space
    separate_fn_name_with_space = False

    # If a statement is wrapped to more than one line, than dangle the closing
    # parenthesis on its own line.
    dangle_parens = True

    # If the trailing parenthesis must be 'dangled' on its on line, then align it
    # to this reference: `prefix`: the start of the statement,  `prefix-indent`:
    # the start of the statement, plus one indentation  level, `child`: align to
    # the column of the arguments
    dangle_align = "prefix"

    # Format command names consistently as 'lower' or 'upper' case
    command_case = "lower"

    # Format keywords consistently as 'lower' or 'upper' case
    keyword_case = "lower"

    # If true, the argument lists which are known to be sortable will be sorted
    # lexicographicall
    enable_sort = True
