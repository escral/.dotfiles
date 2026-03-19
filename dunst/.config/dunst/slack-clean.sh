author=$(printf '%s' "$DUNST_SUMMARY" | sed 's/^New message from //')

action=$(dunstify \
  -a SlackClean \
  -A "open,Open Slack" \
  "$author" \
  "$DUNST_BODY")

if [ "$action" = "open" ]; then
  i3-msg '[class="Slack"] focus' >/dev/null || slack >/dev/null 2>&1 &
fi
