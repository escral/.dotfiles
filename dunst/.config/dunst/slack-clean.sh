#!/usr/bin/env bash

author=$(printf '%s' "$DUNST_SUMMARY" | sed 's/^New message from //')

dunstify \
  -a SlackClean \
  "$author" \
  "$DUNST_BODY"
