# Git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch brmagenta
set __fish_git_prompt_color_dirtystate red
set __fish_git_prompt_color_stagedstate green
set __fish_git_prompt_color_upstream cyan

# Git Characters
set __fish_git_prompt_char_dirtystate '*'
set __fish_git_prompt_char_stagedstate '⇢'
set __fish_git_prompt_char_upstream_prefix ' '
set __fish_git_prompt_char_upstream_equal ''
set __fish_git_prompt_char_upstream_ahead '⇡'
set __fish_git_prompt_char_upstream_behind '⇣'
set __fish_git_prompt_char_upstream_diverged '⇡⇣'

function _prompt_last_status --description "show exit code if last command failed"
  if test $argv[1] -ne 0
    set_color red
    echo -n $argv[1]" "
    set_color normal
  end
end

function fish_prompt
  set -l last_status $status
  _prompt_last_status $last_status
  echo -ne (prompt_pwd)
  __fish_git_prompt " (%s)"
  echo -ne "\n"(set_color brblue)(whoami)(set_color normal)"@"(prompt_hostname)" % "
end
