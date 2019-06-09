# Fish configuration

abbr -a yr 'cal -y'
abbr -a l 'ls -l'
abbr -a m make
abbr -a o xdg-open
abbr -a g git
abbr -a gc 'git checkout'
abbr -a ga 'git add -p'

if command -v nvim
    abbr -a e nvim
    abbr -a vim nvim
else
    abbr -a e vim
end

# Prompt is configured in functions/fish_prompt.fish
