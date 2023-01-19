# Copyright 2020-2021 Joseph Block <jpb@unixorn.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Add our plugin's bin directory to the user's path
local FZF_PLUGIN_BIN="$(dirname $0)/bin"
path+=(${FZF_PLUGIN_BIN})
unset FZF_PLUGIN_BIN

local FZF_COMPLETIONS_D="$(dirname $0)/completions"
export fpath=($FZF_COMPLETIONS_D "${fpath[@]}" )
unset FZF_COMPLETIONS_D

function _fzf_has() {
  which "$@" > /dev/null 2>&1
}

function _fzf_debugOut() {
  if [[ -n "$DEBUG" ]]; then
    echo "$@"
  fi
}

# Install fzf, and enable it for command line history searching and
# file searching.

# Determine where fzf is installed
local fzf_conf
if [[ -z "$FZF_PATH" ]]; then
  FZF_PATH=~/.fzf
  fzf_conf=~/.fzf.zsh
else
  fzf_conf="$FZF_PATH/fzf.zsh"
fi
unset xdg_path

# Install fzf into ~ if it hasn't already been installed.
if [[ ! -d $FZF_PATH ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git $FZF_PATH
  $FZF_PATH/install --bin
fi

# Install some default settings if user doesn't already have fzf
# settings configured.
if [[ ! -f $fzf_conf ]]; then
  echo "Can't find a fzf configuration file at $fzf_conf, creating a default one"
  cp "$(dirname $0)/fzf-settings.zsh" $fzf_conf
fi

# Source this before we start examining things so we can override the
# defaults cleanly.
[[ -f $fzf_conf ]] && source $fzf_conf
unset fzf_conf

export FD_EXCLUDE="{.git,.idea,.vscode,.vscode-server,.cache,node_modules,build}"

# Reasonable defaults. Exclude .git directory and the node_modules cesspit.
# Don't step on user's FZF_DEFAULT_COMMAND
if [[ -z "$FZF_DEFAULT_COMMAND" ]]; then
  # Show hidden, and exclude .git and the pigsty node_modules files
  export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude=${FD_EXCLUDE}"
  export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"
  unset _fd_cmd
fi

if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
  fzf_default_opts+=(
    "--ansi"
    "--layout=reverse"
    "--info=inline"
    "--height=80%"
    "--cycle"
    "--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'"
    "--prompt='∼ '"
    "--pointer='▶'"
    "--marker='✓'"
    "--bind=tab:accept"
    "--bind '?:toggle-preview'"
    "--bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'"
  )
  export FZF_DEFAULT_OPTS=$(printf '%s\n' "${fzf_default_opts[@]}")
fi

if [[ -d $FZF_PATH/man ]]; then
    manpath+=("$MANPATH:$FZF_PATH/man")
fi

# Cleanup internal functions
unset -f _fzf_debugOut
unset -f _fzf_has
