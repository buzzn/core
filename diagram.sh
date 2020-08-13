#!/usr/bin/env bash
../../_schemacrawler/schemacrawler.sh --server=postgresql --host=127.0.0.1 --database=buzzn_development --user=postgres --password=secret --info-level=maximum -c=schema  --output-format=pdf --output-file=graph.pdf "$*"
echo Database diagram is in graph.pdf