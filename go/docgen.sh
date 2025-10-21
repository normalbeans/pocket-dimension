#!/bin/bash

BASEDIR=$(pwd)
set -e

opfile=${1:-"${BASEDIR}/doc.txt"}
packages=$(go list ./...)

> "${opfile}"

for i in $packages; do
	echo "=========== $i ===========" >> "${opfile}"
	go doc -all -u "$i" >> "${opfile}"
	echo " " >> "${opfile}"
	echo " " >> "${opfile}"
done

echo "Doc generated"
