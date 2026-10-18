function _hydro_identity
    set --global _hydro_user ''
    set --global _hydro_container ''
    set --global _hydro_root false
    set --local user "$USER"
    set --local login (command logname 2>/dev/null)
    test "$EUID" = 0 && set --global _hydro_root true

    if test -n "$CONTAINER_ID"
        set --global _hydro_container "$CONTAINER_ID"
    else if test -n "$container"
        set --global _hydro_container "$container"
    else if test -f /run/.containerenv
        set --global _hydro_container podman
        while read --local line
            if string match --quiet 'name=*' -- "$line"
                set --global _hydro_container (string trim --chars '"' -- (string sub --start 6 -- "$line"))
            end
        end </run/.containerenv
    else if test -f /.dockerenv
        set --global _hydro_container docker
    end
    if test -n "$CONTAINER_NAME"; and test -n "$_hydro_container"
        set --global _hydro_container "$CONTAINER_NAME"
    end
    if test -n "$_hydro_container"
        set --global _hydro_container (string replace --all --regex '[[:cntrl:]]' '?' -- "$_hydro_container")
    end

    if set --query SSH_CONNECTION; or set --query SSH_TTY; or set --query SSH_CLIENT; or test "$_hydro_root" = true; or test -n "$_hydro_container"; or test -n "$SUDO_USER"; or begin
            test -n "$login"; and test "$user" != "$login"
        end
        set --global _hydro_user "$user@$hostname"
    end
end
