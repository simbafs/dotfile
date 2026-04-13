if [[ -n "${SSH_CONNECTION:-}" && -z "${TMUX:-}" && -x "$HOME/.tmux-menu.sh" ]]; then
  "$HOME/.tmux-menu.sh"
  rc=$?

  # 42 = disconnect
  if [[ "$rc" -eq 42 ]]; then
    exit
  fi
fi
