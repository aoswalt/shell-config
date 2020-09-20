# Provides for an easier use of GPG by setting up gpg-agent.
#
# ### SSH
#
# To enable OpenSSH Agent protocol emulation, and make `gpg-agent` a drop-in
# replacement for `ssh-agent`, add the following line to
# *~/.gnupg/gpg-agent.conf*:
#
# ```conf
# enable-ssh-support
# ```
#
# When OpenSSH Agent protocol emulation is enabled, this module will load the SSH
# module for additional processing.
#

return 1

# Return if requirements are not found.
if (( ! $+commands[gpg-agent] )); then
  return 1
fi

# Set the default paths to gpg-agent files.
_gpg_agent_conf="${GNUPGHOME:-$HOME/.gnupg}/gpg-agent.conf"
_gpg_agent_env="${TMPDIR:-/tmp}/gpg-agent.env.$UID"

# Load environment variables from previous run
source "$_gpg_agent_env" 2> /dev/null

# Start gpg-agent if not started.
if [[ -z "$GPG_AGENT_INFO" && ! -S "${GNUPGHOME:-$HOME/.gnupg}/S.gpg-agent" ]]; then
  # Start gpg-agent if not started.
  if ! ps -U "$LOGNAME" -o pid,ucomm | grep -q -- "${${${(s.:.)GPG_AGENT_INFO}[2]}:--1} gpg-agent"; then
    eval "$(gpg-agent --daemon | tee "$_gpg_agent_env")"
  fi
fi

# Inform gpg-agent of the current TTY for user prompts.
export GPG_TTY="$(tty)"

# Integrate with the SSH module.
if grep '^enable-ssh-support' "$_gpg_agent_conf" &> /dev/null; then
  # Load required functions.
  autoload -Uz add-zsh-hook

  # Override the ssh-agent environment file default path.
  _ssh_agent_env="$_gpg_agent_env"

  # Load the SSH module for additional processing.
  pmodload 'ssh'

  # Updates the GPG-Agent TTY before every command since SSH does not set it.
  function _gpg-agent-update-tty {
    gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
  }
  add-zsh-hook preexec _gpg-agent-update-tty
fi

# Clean up.
unset _gpg_agent_{conf,env}

# Disable GUI prompts inside SSH.
if [[ -n "$SSH_CONNECTION" ]]; then
  export PINENTRY_USER_DATA='USE_CURSES=1'
fi
