function _hydro_render_prompt \
    --on-variable hydro_prefix \
    --on-variable hydro_suffix \
    --on-variable hydro_symbol_start \
    --on-variable hydro_symbol_prompt \
    --on-variable hydro_multiline \
    --on-variable hydro_prefix_user \
    --on-variable hydro_suffix_user \
    --on-variable hydro_prefix_container \
    --on-variable hydro_suffix_container \
    --on-variable hydro_prefix_pwd \
    --on-variable hydro_suffix_pwd \
    --on-variable hydro_prefix_git \
    --on-variable hydro_suffix_git \
    --on-variable hydro_prefix_jj \
    --on-variable hydro_suffix_jj \
    --on-variable hydro_prefix_duration \
    --on-variable hydro_suffix_duration \
    --on-variable hydro_prefix_prompt \
    --on-variable hydro_suffix_prompt
    set --local prompt_color "$_hydro_color_prompt"\e'[1m'
    test -n "$_hydro_status" && set prompt_color "$_hydro_color_error"\e'[1m'
    set --local user
    if test -n "$_hydro_user"
        set --local color "$_hydro_color_user"
        test "$_hydro_root" = true && set color "$_hydro_color_error"
        set user "$color$hydro_prefix_user$_hydro_user$hydro_suffix_user$hydro_color_normal "
    end
    set --local container
    if test -n "$_hydro_container"
        set container "$_hydro_color_user$hydro_prefix_container$_hydro_container$hydro_suffix_container$hydro_color_normal "
    end
    set --local vcs
    if test -n "$_hydro_vcs_value"
        set --local prefix hydro_prefix_$_hydro_vcs_kind
        set --local suffix hydro_suffix_$_hydro_vcs_kind
        set vcs "$_hydro_color_git$$prefix$_hydro_vcs_value"
        if test -n "$_hydro_vcs_status"
            set vcs "$vcs$_hydro_color_git_status$_hydro_vcs_status$hydro_color_normal$_hydro_color_git"
        end
        set vcs "$vcs$$suffix$hydro_color_normal "
    end
    set --local duration
    if test -n "$_hydro_cmd_duration"
        set duration "$_hydro_color_duration$hydro_prefix_duration$_hydro_cmd_duration$hydro_suffix_duration$hydro_color_normal "
    end
    set --local newline
    test "$hydro_multiline" = true && set newline \n
    set --global _hydro_prompt_text "$hydro_color_normal$hydro_prefix$_hydro_color_start$hydro_symbol_start$hydro_color_normal$user$container$_hydro_color_pwd$hydro_prefix_pwd$_hydro_pwd$hydro_suffix_pwd$hydro_color_normal $vcs$duration$newline$prompt_color$hydro_prefix_prompt$hydro_symbol_prompt$hydro_suffix_prompt$hydro_color_normal$hydro_suffix "
end
