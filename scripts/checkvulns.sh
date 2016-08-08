#!/bin/sh
echo "checking if the tests failed, if any scenarios have failed we will return an exit code of 3"

filename=$1

echo $filename "this is the filename"

if [[ $(grep failed $filename | wc -c) -eq 0 ]]; then
	echo "no failed scenarios or couldnt find file or text is not formatted correctly"
	exit 0
else
	echo "something failed"
	exit 3
fi
