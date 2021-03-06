#!/usr/bin/env bash

###############################################################################
#                                entrypoint.sh                                #
###############################################################################
# Checks all C files (.c and .h) in the GitHub workspace for conforming to
# clang-format. If any C files are incorrectly formatted, the script lists them
# and exits with 1.
# Define your own formatting rules in a .clang-format file at your repository
# root. Otherwise, the LLVM style guide is used as a default.


###############################################################################
#                             format_diff function                            #
###############################################################################
# Accepts a filepath argument. The filepath passed to this function must point
# to a .c or .h file. The file is formatted with clang-format and that output is
# compared to the original file.
# errors=()

format_diff(){
    local filepath="$1"
    local_format="$(clang-format --style=file --fallback-style=LLVM "${filepath}")"
    diff -q <(cat "${filepath}") <(echo "${local_format}") > /dev/null
    diff_result="$?"
    if [[ "${diff_result}" -ne 0 ]]; then
    # errors+=("${filepath} is not formatted correctly.")
    # echo "${errors}"
	echo "${filepath}"
	return "${diff_result}"
    fi
    return 0
}

cd "$GITHUB_WORKSPACE" || exit 1

# All files improperly formatted will be printed to the output.
err=$(find $INPUT_SEARCHPATH -name $INPUT_FINDSTRING | while read -r src_file; do format_diff "${src_file}"; done)
errors=($(echo $err | tr " " "\n"))

if [ ${#errors[@]} -eq 0 ]; then
    echo "No errors"
    exit 0
else
    OUTPUT=$'**Lint Errors**\n'
    OUTPUT=$'The following files have lint errors:\n\n'
    for i in "${errors[@]}"
    do
        OUTPUT+=$"\`$i\`"
        OUTPUT+=$'\n'
    done

    # Used from: https://github.com/smay1613/cpp-linter-action
    COMMENTS_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)

    OUTPUT+=$'\n'
    OUTPUT+="Please read [ProtoLint README.md](http://github.com/${GITHUB_REPOSITORY}/blob/master/docs/PROTO_LINT.md) to help with your errors."
    OUTPUT+=$'\n'
    
    PAYLOAD=$(echo '{}' | jq --arg body "$OUTPUT" '.body = $body')

    if [ "${COMMENTS_URL}" == "null" ]; then
        printf "$OUTPUT"
    else
        curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$PAYLOAD" "$COMMENTS_URL" 
    fi

    exit 1
fi


exit 0
