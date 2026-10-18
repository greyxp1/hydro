# Hydro

A Fish prompt with asynchronous Git and Jujutsu status, based on [jorgebucaran/hydro](https://github.com/jorgebucaran/hydro).

## Dependencies

Fish and Git are required. JJ support needs `jj`, switched-user detection uses
coreutils `logname`, and automatic Git fetching needs `flock` from util-linux.

## Configuration

| Variable | Default | Meaning |
| --- | --- | --- |
| `hydro_color_pwd` | `f2f2f2` | Path color |
| `hydro_color_user` | `blue` | Identity color |
| `hydro_color_git`, `hydro_color_prompt` | `769ff0` | Git/JJ labels and prompt colors |
| `hydro_color_git_status` | `eb4d28 --bold` | Repository status color |
| `hydro_color_error` | `eb4d28` | Error and root identity color |
| `hydro_color_duration` | `999999` | Duration color |
| `hydro_color_start` | normal | Start-symbol color |
| `hydro_symbol_start` | empty | Text before the prompt |
| `hydro_symbol_prompt` | `❯` | Prompt character |
| `hydro_prefix`, `hydro_suffix` | empty | Text around the whole prompt |
| `hydro_prefix_SECTION`, `hydro_suffix_SECTION` | empty except below | Text around visible `user`, `container`, `pwd`, `git`, `jj`, `duration` or `prompt` sections, using their colors |
| `hydro_prefix_git` | ` ` | Git prefix |
| `hydro_prefix_jj` | `jj ` | JJ prefix |
| `hydro_prefix_container`, `hydro_suffix_container` | `[container: `, `]` | Container decorations |
| `hydro_symbol_git_dirty` | `•` | Changed-state marker for Git and JJ |
| `hydro_symbol_git_ahead`, `hydro_symbol_git_behind` | `↑`, `↓` | Git upstream markers |
| `hydro_symbol_jj_conflict` | `!` | JJ conflict marker |
| `hydro_pwd_max_dirs` | `3` | Maximum directory components, or `0` for the full path |
| `hydro_cmd_duration_threshold` | `1000` | Minimum duration in milliseconds |
| `hydro_multiline` | `false` | Put the prompt character on a second line |
| `hydro_ignored_paths` | empty | Repository roots whose status is hidden |
| `hydro_fetch` | `true` | Fetch Git remotes in the background |
| `hydro_fetch_interval` | `300` | Seconds between fetch attempts |
