#!/bin/bash

cd "$GITHUB_WORKSPACE" || exit 1

echo -e "Validating terraform file format using terraform -fmt\n"
diverging_files="$(terraform fmt -check -recursive)"
if test -n "$diverging_files"; then
	echo -e "The files above have formatting problems, use terraform fmt to fix them\n"
	echo "$diverging_files"
	exit_code=1
fi

for i in ${TF_CHECKER_EXCLUDE_REGEX//:/ }; do
	exclude_files="$exclude_files :(exclude)$i"
done

if [ -n "$TF_CHECKER_ALL_FILES" ]; then
	echo -e "Checking all tf files\n"
  	# shellcheck disable=SC2086
	files="$(git ls-files -- ${exclude_files:-.} | grep -E "\.tf$")"
else
	branch="$(git rev-parse --abbrev-ref HEAD)"
	echo -e "Checking only git diff between master and $branch\n"
  	# shellcheck disable=SC2086
	files="$(git diff --name-only master..."$branch" --diff-filter=d -- ${exclude_files:-.} | grep -E "\.tf$")"
fi

echo "Files to run terraform validate:"
echo "$files"

if [ -n "$files" ]; then
	for dir in $(echo "$files" | xargs -n 1 dirname | sort -u); do
		echo "Validating $dir"
		pushd "$dir" || exit 1
		terraform init -backend=false .
		terraform validate . | grep -E -A4 "Warning|Error" && exit_code=1
		popd || exit 1
	done
fi

if [ -z "$exit_code" ]; then
	echo -e "All tf files found looks fine :)\n"
fi

exit "${exit_code:-0}"
