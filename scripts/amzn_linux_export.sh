#!/bin/bash

src_disk=/dev/xvdz
out_file=/tmp/box.img.gz

echo "INFO: Exporting ${src_disk} to ${out_file} ..."
dd if=${src_disk} bs=1M status=progress | gzip -c > $out_file

if [ "$?" == "0" ]; then
    echo "INFO: Image extraction successful and ready for retrieval from ${out_file}"
else
    echo "ERROR: Image extraction failed."
fi
