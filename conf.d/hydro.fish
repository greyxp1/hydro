status is-interactive || exit

set --global _hydro_vcs _hydro_vcs_$fish_pid
set --global _hydro_request 0
set --global _hydro_check_identity true
set --global _hydro_fetch _hydro_fetch_$fish_pid
set --erase --universal $_hydro_vcs $_hydro_fetch
set --global _hydro_vcs_value ''

function $_hydro_vcs --on-variable $_hydro_vcs
    set --local reply $$_hydro_vcs
    test (count $reply) -eq 7 || return
    test "$reply[1]" = "$_hydro_request" || return
    set --erase _hydro_last_pid
    set --local changed false
    if test "$_hydro_check_identity" = true
        if test "$_hydro_user" != "$reply[6]"; or test "$_hydro_container" != "$reply[7]"
            set --global _hydro_user "$reply[6]"
            set --global _hydro_container "$reply[7]"
            set changed true
        end
        set --global _hydro_check_identity false
    end
    if test "$reply[2]" != "$_hydro_vcs_root"; or test "$reply[3]" != "$_hydro_vcs_kind"; or test "$reply[4]" != "$_hydro_vcs_value"; or test "$reply[5]" != "$_hydro_vcs_status"
        set changed true
    end
    set --global _hydro_vcs_root "$reply[2]"
    set --global _hydro_vcs_kind "$reply[3]"
    set --global _hydro_vcs_value "$reply[4]"
    set --global _hydro_vcs_status "$reply[5]"
    if test "$hydro_fetch" = true; and test "$_hydro_vcs_kind" = git; and not set --query _hydro_fetching
        set --global _hydro_fetching true
        fish --private --command '_hydro_git_fetch $argv' -- $_hydro_fetch $fish_pid "$_hydro_vcs_root" $hydro_fetch_interval &
        disown $last_pid
    end
    if test "$changed" = true
        _hydro_render_prompt
        set --query _hydro_executing || commandline --function repaint
    end
end

function $_hydro_fetch --on-variable $_hydro_fetch
    set --local reply $$_hydro_fetch
    set --erase _hydro_fetching
    set --erase --universal $_hydro_fetch
    if test (count $reply) -eq 2; and test "$reply[2]" = true; and test "$reply[1]" = "$_hydro_vcs_root"; and not set --query _hydro_executing
        _hydro_prompt
    end
end

function _hydro_pwd --on-variable hydro_pwd_max_dirs
    set --query _hydro_directory || return
    set --local directory "$PWD"
    set directory "$(string replace --regex -- "^$(string escape --style=regex -- "$HOME")(?=/|\$)" '~' "$directory")"
    set directory (string replace --all --regex '[[:cntrl:]]' '?' -- "$directory")
    set --local separator \e'[2m/'\e'[22m'
    if test "$directory" = '~'
        set --global _hydro_pwd '~'
    else if test "$directory" = /
        set --global _hydro_pwd /
    else
        set --local parts (string split / -- "$directory")
        set --local prefix
        if test "$parts[1]" = '~'
            set prefix "~$separator"
            set --erase parts[1]
        else if test "$parts[1]" = ''
            set prefix "$separator"
            set --erase parts[1]
        end
        if test "$hydro_pwd_max_dirs" -gt 0; and test (count $parts) -gt $hydro_pwd_max_dirs
            set --local first -$hydro_pwd_max_dirs
            set parts $parts[$first..-1]
            set prefix "..$separator"
        end
        set --global _hydro_pwd "$prefix$(string join "$separator" -- $parts)"
    end
    test "$argv[1]" = VARIABLE && _hydro_render_prompt
end

function _hydro_preexec --on-event fish_preexec
    set --global _hydro_executing true
end

function _hydro_postexec --on-event fish_postexec
    set --local last_status $pipestatus
    set --erase _hydro_executing
    set --global _hydro_status ''
    set --global _hydro_duration_fresh true

    for code in $last_status
        if test $code -ne 0
            set --global _hydro_status '| '(string join ' ' $last_status)
            break
        end
    end

    test "$CMD_DURATION" -lt $hydro_cmd_duration_threshold && set _hydro_cmd_duration && return
    set --local secs (math --scale=1 $CMD_DURATION/1000 % 60)
    set --local mins (math --scale=0 $CMD_DURATION/60000 % 60)
    set --local hours (math --scale=0 $CMD_DURATION/3600000)
    set --local out
    test $hours -gt 0 && set --append out $hours"h"
    test $mins -gt 0 && set --append out $mins"m"
    test $secs -gt 0 && set --append out $secs"s"
    set --global _hydro_cmd_duration (string join ' ' -- $out)
end

function _hydro_new_prompt --on-event fish_prompt
    set --query _hydro_duration_fresh || set --erase _hydro_cmd_duration
    set --erase _hydro_duration_fresh
    _hydro_prompt
end

function _hydro_prompt --on-variable PWD --on-variable hydro_ignored_paths
    set --query _hydro_status || set --global _hydro_status ''
    if test "$_hydro_directory" != "$PWD"
        set --global _hydro_directory "$PWD"
        set --global _hydro_vcs_root ''
        set --global _hydro_vcs_kind ''
        set --global _hydro_vcs_value ''
        set --global _hydro_vcs_status ''
        _hydro_pwd
    end

    set --global _hydro_request (math $_hydro_request + 1)
    set --query _hydro_last_pid && command kill $_hydro_last_pid 2>/dev/null
    fish --private --command '_hydro_async_status $argv' -- $_hydro_vcs $_hydro_request $fish_pid "$hydro_symbol_git_dirty" "$hydro_symbol_git_ahead" "$hydro_symbol_git_behind" "$hydro_symbol_jj_conflict" $_hydro_check_identity $hydro_ignored_paths &
    set --global _hydro_last_pid $last_pid
    disown $last_pid
    _hydro_render_prompt
end

function _hydro_fish_exit --on-event fish_exit
    set --query _hydro_last_pid && command kill $_hydro_last_pid 2>/dev/null
    set --erase --universal $_hydro_vcs $_hydro_fetch
end

function _hydro_uninstall --on-event hydro_uninstall
    _hydro_fish_exit
    set --names |
        string replace --filter --regex -- "^(_?hydro_)" "set --erase \$1" |
        source
    functions --erase (functions --all | string match --entire --regex "^_?hydro_")
end

set --query hydro_color_pwd || set --global hydro_color_pwd f2f2f2
set --query hydro_color_user || set --global hydro_color_user blue
set --query hydro_color_git || set --global hydro_color_git 769ff0
set --query hydro_color_git_status || set --global hydro_color_git_status eb4d28 --bold
set --query hydro_color_prompt || set --global hydro_color_prompt 769ff0
set --query hydro_color_duration || set --global hydro_color_duration 999999
set --query hydro_pwd_max_dirs || set --global hydro_pwd_max_dirs 3
set --query hydro_color_error || set --global hydro_color_error eb4d28
set --query hydro_symbol_prompt || set --global hydro_symbol_prompt ❯
set --query hydro_prefix_git || set --global hydro_prefix_git ' '
set --query hydro_symbol_git_dirty || set --global hydro_symbol_git_dirty •
set --query hydro_symbol_git_ahead || set --global hydro_symbol_git_ahead ↑
set --query hydro_symbol_git_behind || set --global hydro_symbol_git_behind ↓
set --query hydro_multiline || set --global hydro_multiline false
set --query hydro_cmd_duration_threshold || set --global hydro_cmd_duration_threshold 1000

set --query hydro_prefix_jj || set --global hydro_prefix_jj 'jj '
set --query hydro_symbol_jj_conflict || set --global hydro_symbol_jj_conflict '!'
set --query hydro_fetch || set --global hydro_fetch true
set --query hydro_fetch_interval || set --global hydro_fetch_interval 300

set --query hydro_prefix_container || set --global hydro_prefix_container '[container: '
set --query hydro_suffix_container || set --global hydro_suffix_container ']'

set --global hydro_color_normal (set_color normal)
function _hydro_color \
    --on-variable hydro_color_pwd \
    --on-variable hydro_color_git \
    --on-variable hydro_color_git_status \
    --on-variable hydro_color_error \
    --on-variable hydro_color_prompt \
    --on-variable hydro_color_duration \
    --on-variable hydro_color_start \
    --on-variable hydro_color_user
    set --local color $argv[3]
    set --global _$color (set_color $$color)
    set --query _hydro_directory && _hydro_render_prompt
end
for color in hydro_color_{pwd,git,git_status,error,prompt,duration,start,user}
    set --query $color && set --global _$color (set_color $$color)
end

set --global _hydro_root false
set --global _hydro_user ''
set --global _hydro_container ''
test "$EUID" = 0 && set --global _hydro_root true
if test "$_hydro_root" = true; or set --query SSH_CONNECTION; or set --query SSH_TTY; or set --query SSH_CLIENT; or test -n "$SUDO_USER"
    set --global _hydro_user "$USER@$hostname"
end
