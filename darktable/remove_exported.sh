#!/bin/bash

# Based on https://github.com/darktable-org/darktable/blob/bae13969071baedaa09befbfc94c83a32e38fb9c/tools/purge_non_existing_images.sh

DRYRUN=yes

if [ "$1" = "-p" ]; then
    DRYRUN=no
fi

DBFILE=~/.config/darktable/library.db
TMPFILE=$(mktemp -t tmp.XXXXXXXXXX)
QUERY="select A.id,B.folder,A.filename from images as A join film_rolls as B on A.film_id = B.id"
sqlite3 $DBFILE "$QUERY" > "$TMPFILE"

echo "Removing the following exported file(s):"

cat "$TMPFILE" | while read -r result
do
  ID=$(echo "$result" | cut -f1 -d"|")
  FD=$(echo "$result" | cut -f2 -d"|")
  FL=$(echo "$result" | cut -f3 -d"|")
  MyPath="$FD/$FL"
  if echo $MyPath | grep -q -i "export";
  then
    echo "  $FD/$FL with ID = $ID"

    if [ $DRYRUN = no ]; then
        for table in images meta_data; do
            sqlite3 "$DBFILE" "delete from $table where id=$ID"
        done

        for table in color_labels history mask selected_images tagged_images; do
            sqlite3 "$DBFILE" "delete from $table where imgid=$ID"
        done
    fi
  fi
done
rm "$TMPFILE"


if [ $DRYRUN = no ]; then
    # delete now-empty filmrolls
    sqlite3 "$DBFILE" "DELETE FROM film_rolls WHERE (SELECT COUNT(A.id) FROM images AS A WHERE A.film_id=film_rolls.id)=0"
else
    echo
    echo Remove following now-empty filmrolls:
    sqlite3 "$DBFILE" "SELECT folder FROM film_rolls WHERE (SELECT COUNT(A.id) FROM images AS A WHERE A.film_id=film_rolls.id)=0"
fi

if [ $DRYRUN = yes ]; then
    echo
    echo to really remove images from the database call:
    echo "$0" -p
fi
