#!/bin/bash

for file in Resources/*.lproj/UserVoice.strings; do
  twine generate-string-file strings.txt $file
done
