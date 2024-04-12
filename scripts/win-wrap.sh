#!/bin/bash
command_to_execute="$1"
shift

transformed_args=()
for arg in "$@"; do
    # Check if the argument is a file
    if [ -f "$arg" ]; then
        # Transform the file path using wslpath
        transformed_arg=$(wslpath -w "$arg")
        transformed_args+=("$transformed_arg")
    else
        # Keep non-file arguments unchanged
        transformed_args+=("$arg")
    fi
done

"$command_to_execute" "${transformed_args[@]}"
exit_code=$?
exit $exit_code