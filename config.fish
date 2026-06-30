set fish_greeting ""

set fish_color_cwd cyan
set __fish_git_prompt_color_branch yellow

# gv aliases that generate errors if placed in .profile
alias cdo="cd .."
alias cdo2="cd ../.."
alias cdo3="cd ../../.."
alias cdo4="cd ../../../.."
alias cdo5="cd ../../../../.."

### Load aliases and environment variables from ~/.profile with caching
# Cache is rebuilt only when ~/.profile changes (mtime comparison)
set -l _profile ~/.profile
set -l _cache ~/.config/fish/.profile_cache.fish

if test -f $_profile
    if not test -f $_cache; or test $_profile -nt $_cache
        rm -f $_cache
        # Process aliases
        egrep "^alias " $_profile | while read e
            set var (echo $e | sed -E "s/^alias ([A-Za-z_-]+)=(.*)\$/\1/")
            set value (echo $e | sed -E "s/^alias ([A-Za-z_-]+)=(.*)\$/\2/")
            set value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")
            set value (eval echo $value)
            echo "alias $var '$value'" >> $_cache
        end
        # Process exports
        egrep "^export " $_profile | while read e
            set var (echo $e | sed -E "s/^export ([A-Z_]+)=(.*)\$/\1/")
            set value (echo $e | sed -E "s/^export ([A-Z_]+)=(.*)\$/\2/")
            set value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")
            if test $var = "PATH"
                set value (echo $value | sed -E "s/:/ /g")
                eval set -xg $var $value
                echo "set -xg $var $value" >> $_cache
                continue
            end
            switch $value
                case '`*`'
                    set NO_QUOTES (echo $value | sed -E "s/^\`(.*)\`\$/\1/")
                    set resolved (eval $NO_QUOTES)
                    set -x $var $resolved
                    echo "set -x $var $resolved" >> $_cache
                case '*'
                    set value (eval echo $value)
                    set -xg $var $value
                    echo "set -xg $var $value" >> $_cache
            end
        end
        # Set cache mtime to match .profile so comparison works next time
        touch -r $_profile $_cache
    else
        source $_cache
    end
end


# Gas Town rig detection on directory change
function __gt_rig_detect --on-variable PWD
    if not command -q gt
        return
    end
    # Only run inside the Gas Town workspace; clear vars when leaving
    if not string match -q "$HOME/gt*" $PWD
        set -e GT_RIG
        set -e BEADS_DIR
        return
    end
    set -l lines (gt rig detect $PWD 2>/dev/null | string split \n)
    for line in $lines
        if string match -q "unset *" -- $line
            # bash "unset VAR1 VAR2" -> fish "set -e VAR"
            for var in (string split " " -- (string replace "unset " "" -- $line))
                set -e $var
            end
        else if string match -q "export *=*" -- $line
            # bash "export KEY=value" -> fish "set -x KEY value"
            set -l kv (string replace "export " "" -- $line)
            set -l key (string split "=" -- $kv)[1]
            set -l val (string join "=" (string split "=" -- $kv)[2..])
            set -x $key $val
        else if string match -q "*=*" -- $line
            # bash "KEY=value" -> fish "set -x KEY value"
            set -l key (string split "=" -- $line)[1]
            set -l val (string join "=" (string split "=" -- $line)[2..])
            set -x $key $val
        end
    end
end
set -x GT_TOWN_ROOT ~/gt

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/gv/.lmstudio/bin

# Created by `pipx` on 2025-10-14 11:19:01
set PATH $PATH /Users/gv/.local/bin
