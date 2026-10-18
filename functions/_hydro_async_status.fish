function _hydro_async_status --argument-names variable request parent dirty_symbol ahead_symbol behind_symbol conflict_symbol check_identity
    set --local user ''
    set --local container ''
    if test "$check_identity" = true
        _hydro_identity
        set user "$_hydro_user"
        set container "$_hydro_container"
    end
    set --local root
    set --local kind git
    set --local segment
    set --local details
    set --local directory "$PWD"
    while true
        if test -d "$directory/.jj"
            set root "$directory"
            set kind jj
            break
        end
        if test -e "$directory/.git"
            set root "$directory"
            break
        end
        test "$directory" = / && break
        set directory (path dirname "$directory")
    end

    if test "$kind" = git; and begin
            test -n "$root"; or set --query GIT_DIR; or set --query GIT_WORK_TREE
        end
        set root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null | string collect)
    end
    if test -z "$root"; or contains -- "$root" $argv[9..-1]
        command kill -0 $parent 2>/dev/null && set --universal $variable $request '' '' '' '' "$user" "$container"
        return
    end

    if test "$kind" = jj
        # Prompt queries must not snapshot files or change the working-copy commit.
        set --local result (command jj --ignore-working-copy --color=never --no-pager log --no-graph -r @ -T 'separate(" ", change_id.shortest(8), bookmarks.join(" ")) ++ "\n" ++ !empty ++ "\n" ++ conflict' 2>/dev/null)
        if test (count $result) -eq 3
            set segment "$result[1]"
            test "$result[2]" = true && set details "$dirty_symbol"
            test "$result[3]" = true && set details "$details$conflict_symbol"
        end
    else
        set --local branch
        set --local info
        set --local upstream
        for record in (command git --no-optional-locks status --porcelain=2 --branch -z 2>/dev/null | string split0)
            if string match --quiet '# branch.head *' -- "$record"
                set branch (string sub --start 15 -- "$record")
            else if string match --quiet '# branch.ab *' -- "$record"
                set --local counts (string split ' ' -- "$record")
                test "$counts[3]" != +0 && set --append upstream "$ahead_symbol"(string sub --start 2 -- "$counts[3]")
                test "$counts[4]" != -0 && set --append upstream "$behind_symbol"(string sub --start 2 -- "$counts[4]")
            else if not string match --quiet '# *' -- "$record"
                set info "$dirty_symbol"
                break
            end
        end
        if test "$branch" = '(detached)'
            set branch (command git describe --tags --exact-match HEAD 2>/dev/null)
            if test -z "$branch"
                set branch '@'(command git rev-parse --short HEAD 2>/dev/null)
            end
        end
        if test -n "$branch"
            set segment "$branch"
            set details "$info"
            set --query upstream[1] && set details "$details "(string join ' ' -- $upstream)
        end
    end
    if test "$kind" = git; and test -z "$segment"
        set root ''
        set kind ''
    end
    command kill -0 $parent 2>/dev/null && set --universal $variable $request "$root" "$kind" "$segment" "$details" "$user" "$container"
end
