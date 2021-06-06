#!/bin/bash

# A simple script to backup my adminstrative stuff periodically.

set -eu -o pipefail

date_stem=$(date +%Y%m%d)

prefix="${date_stem}_Documents"
archive="${prefix}.tar.gz"

ln -s Documents "${prefix}"

echo "Creating archive ${archive}..."
tar czhf "${archive}" "${prefix}"
echo "Encrypting and signing..."
gpg --encrypt\
    --sign\
    --recipient ECB7D6F5B1895F6AF015AF81E81FE4D2D9883D92\
    -o "${archive}.gpg"\
    "${archive}"

echo "Uploading..."
scp "${archive}" scp://debian@thomashk.fr:49499//home/debian/Backups

rm -f ${prefix}
