# littools

Collection of scripts for literature management.

## Requirements

In addition to Perl 5 (with Tk) and a POSIX-compliant shell with `coreutils`,  the following command line tools are required:

- `parallel`
- `zathura` PDF viewer
- `fdfind` (also known as `fd`)
- `pdftotext` (**not** `pdf2txt`)

## Installation

Customize `PREFIX` in the `Makefile`, if required (`~/.local/bin` by default). Then, simply run:

```shell
make install
```

## Command overview

### mklitentry

Usage: `mklitentry.sh [FILE]...`

Read one or more PDFs and generate a database entry (simple CSV) for each `FILE` in the following form:

```csv
 key,tag1;tag2;tagN,/abs/path,unique words from text
 ```

 If `FILE` is `-` or empty, read from `STDIN`. Output is written to `STDOUT`.

### mklitdb

Usage: `mklitdb.sh <DIR>`

Create a literature database recursively from all PDFs inside the directory `DIR` by calling `mklitentry.sh` in parallel.

Output is written to `STDOUT`.

### mkiidx

Usage: `mkiidx.pl <DATABASE>`

Generate an inverse index from database file `<DATABASE>` (previously generated by either `mklitentry.sh` or `mklitdb.sh`) in the following form:

```csv
term,key1:/absolute/path/1;key2:/absolute/path/2;...
...
```

Output is written to `STDOUT`.

### iidxlookup

Usage: `iidxlookup.pl <INVERSE_INDEX>`

Read an inverse index (CSV file, previously generated by `mkiidx.pl`) and allow users to search it for _all_ keywords in the query string (`AND`-search). File paths of matching documents are displayed in a list. When double-clicking a list entry, the absolute path is writen to `STDOUT`.

### litsearch

Usage `litsearch.sh`>

Wrapper for `iidxlookup.pl` that opens its output in a default application.

## TODO

1. Calculate $TF$ or $TF/IDF$ in `mklitentry.sh`
1. Rank results in `iidxlookup.pl`

