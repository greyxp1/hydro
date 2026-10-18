function _hydro_git_fetch --argument-names variable parent root interval locked
    set --local common (command git -C "$root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null | string collect)
    set --local fetched false
    if test -n "$common"
        set --local recent false
        for stamp in "$common/FETCH_HEAD" "$common/hydro-fetch.time"
            if test -f "$stamp"; and test (path mtime --relative "$stamp") -lt $interval
                set recent true
            end
        end
        if test "$recent" = false
            if test "$locked" != true
                # The kernel releases this lock even if the fetch worker crashes.
                command flock --nonblock --close "$common/hydro-fetch.lock" (status fish-path) --private --command '_hydro_git_fetch $argv' -- $variable $parent "$root" $interval true
                test $status -eq 0 && return
            else
                # Throttle failed fetches too. Recheck freshness after taking the lock.
                printf '' >"$common/hydro-fetch.time"
                GIT_TERMINAL_PROMPT=0 command git -C "$root" fetch --quiet --no-tags 2>/dev/null
                test $status -eq 0 && set fetched true
            end
        end
    end
    command kill -0 $parent 2>/dev/null && set --universal $variable "$root" $fetched
end
