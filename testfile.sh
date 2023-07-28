#!/usr/bin/env bash

# Exit immediately if any command below fails.
set -e

export rdir="test_files"
export dir="$rdir/gen_tests"
export a="ascii"
export d="data"
export e="empty"

export err_args="Usage: file path"
export err_perm=": cannot determin (Permission denied)"
export err_path=": cannot determin (No such file or directory)"

make

echo "Generating a $dir directory.."
mkdir -p $dir

rm -f test_files/gen_tests/*

echo "Generating test files.."

for i in {0..100}
do
    fortune > $dir/ascii$i.input
done

echo "Running the type tests..."
exitcode=0
for f in $dir/*.input
do
  echo ">>> Testing ${f}..."
  file    "${f}" | sed 's/ASCII text.*/ASCII text/' > "${f}.expected"
  ./file  "${f}" > "${f}.actual"

  if ! diff -u "${f}.expected" "${f}.actual"
  then
    echo ">>> Failed :-(" | lolcat
    exitcode=1
  fi
done
