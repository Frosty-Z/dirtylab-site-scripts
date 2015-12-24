#!/bin/bash

# @author Frosty-Z
# @date 2015-12-22
# @desc Processes .MD files from https://github.com/sveinburne/lets-play-science
#       to get .html files then upload them to https://github.com/dirtylab/dirtylab.github.io

# uses grip utility from https://github.com/joeyespo/grip

ORIG_REPO_URL="https://github.com/sveinburne/lets-play-science"
ORIG_DIR="lets-play-science"
TMP_DIR="tmp_site"
TEMPLATES_DIR="jekyll-stuff"
JEKYLL_INCLUDES_DIR="_includes"


echo "*** Clean/refresh directories"

if [ ! -d "$ORIG_DIR" ]; then
  echo "*** Create $DEST_DIR directory from $ORIG_REPO_URL"
  git clone $ORIG_REPO_URL
else
  cd $ORIG_DIR
  git pull
  cd ..
fi

if [ ! -d "$TMP_DIR" ]; then
  mkdir $TMP_DIR
else
  # clear content but avoid rm -rf /*
  if [ -n "$TMP_DIR" ]; then
    rm -rf $TMP_DIR/*
  fi
fi

cp -r $ORIG_DIR/* $TMP_DIR

cd $TMP_DIR

rm -rf .git


echo "*** Copy .MD files to $JEKYLL_INCLUDES_DIR, recursively"

mkdir $JEKYLL_INCLUDES_DIR

# required to handle spaces in filenames
OLDIFS=$IFS
IFS=$'\n'

for f in `find . -type f -name '*.MD'`
do
  # Links fixing
  sed -i.bak -e 's/\([A-Za-z0-9.\-_]\{1,\}\)\.MD/\1.html/g' $f

  # copy with directory structure preservation
  mkdir -p `dirname "$JEKYLL_INCLUDES_DIR/$f"`
  cp "$f" "$JEKYLL_INCLUDES_DIR/$f"
done

# clean .bak files created by sed
rm -rf *.bak

echo "*** Create one .html file per .MD file, with appropriate 'Front Matter' content"

for f in `find . -type f -name '*.MD' -not -path "./$JEKYLL_INCLUDES_DIR/*"`
do
  NEW_FILENAME="${f%.MD}.html"
  mv "$f" "$NEW_FILENAME"

  CONTENT=$'---\n'
  CONTENT+=$'layout: convert_md_to_html\n'
  CONTENT+="markdown_file: ${f:2}" # strip './' at the beginning of the filename, otherwise Jekyll crashes !
  CONTENT+=$'\n---\n'
  echo "$CONTENT" > "$NEW_FILENAME"
done

IFS=$OLDIFS



echo "*** Retrieve templates"

cp -r ../$TEMPLATES_DIR/* .


cd ..
