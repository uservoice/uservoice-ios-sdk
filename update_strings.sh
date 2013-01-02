# Make sure all translations are pushed out to the strings files
for file in Resources/*.lproj/UserVoice.strings; do
  twine generate-string-file strings.txt $file
done

# Regenerate English strings from the source code
genstrings Resources/en.lproj/UserVoice.strings

# Clear strings.txt
> strings.txt

# Repopulate strings.txt from the English strings file
twine consume-string-file strings.txt Resources/en.lproj/UserVoice.strings --lang en --consume-all 2> /dev/null

# Pull only the still-used translations back into strings.txt
for file in Resources/*.lproj/UserVoice.strings; do
  twine consume-string-file strings.txt $file 2> /dev/null
done

# Push used translations back out to strings files
for file in Resources/*.lproj/UserVoice.strings; do
  twine generate-string-file strings.txt $file
done

LANGS=`ls Resources/*.lproj/UserVoice.strings | sed 's/.*Resources\/\([^.]*\).*$/\1/' | tr '\n' ' '`

echo "Strings updated. Locales: $LANGS"
