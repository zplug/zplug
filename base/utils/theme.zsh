# Import oh-my-zsh/lib/git.zsh
#

# Outputs current branch info in prompt format
git_prompt_info()
{
    local ref hide_status
    hide_status="$(git config --get oh-my-zsh.hide-status 2>/dev/null)"
    if [[ $hide_status != 1 ]]; then
        ref="$(git symbolic-ref HEAD 2>/dev/null)" || ref="$(git rev-parse --short HEAD 2>/dev/null)" || return 0
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
    fi
}

# Checks if working tree is dirty
parse_git_dirty()
{
    local    _status hide_dirty
    local -a flags

    flags=('--porcelain')
    hide_dirty="$(git config --get oh-my-zsh.hide-dirty)"

    if [[ $hide_dirty != "1" ]]; then
        if __zplug::base::base::git_version 1.7.2; then
            flags+=('--ignore-submodules=dirty')
        fi
        if [[ $DISABLE_UNTRACKED_FILES_DIRTY == true ]]; then
            flags+=('--untracked-files=no')
        fi
        _status="$(git status "$flags[@]" | tail -n 1)"
    fi

    if [[ -n $_status ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
        echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi
}

# Gets the difference between the local and remote branches
git_remote_status()
{
    local remote ahead behind git_remote_status git_remote_status_detailed
    remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    if [[ -n $remote ]]; then
        ahead="$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)"
        behind="$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)"

        if [[ $ahead == 0 ]] && [[ $behind == 0 ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE"

        elif [[ $ahead == 0 ]] && [[ $behind == 0 ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}"

        elif [[ $behind -gt 0 ]] && [[ $ahead == 0 ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}"

        elif [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}"
        fi

        if [[ -n $ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX$remote$git_remote_status_detailed$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX"
        fi

        echo "$git_remote_status"
    fi
}

# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
# Using '--quiet' with 'symbolic-ref' will not cause a fatal error (128) if
# it's not a symbolic ref, but in a Git repo.
git_current_branch()
{
    local ref

    ref="$(git symbolic-ref --quiet HEAD 2>/dev/null)"
    local ret=$?

    if [[ $ret != 0 ]]; then
        [[ $ret == 128 ]] && return 0 # no git repo
        ref=$(git rev-parse --short HEAD 2>/dev/null) || return 0
    fi
    echo "${ref#refs/heads/}"
}

# Gets the number of commits ahead from remote
git_commits_ahead()
{
    if git rev-parse --git-dir &>/dev/null; then
        local commits="$(git rev-list --count @{upstream}..HEAD)"
        if [[ $commits != 0 ]]; then
            echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$commits$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
        fi
    fi
}

# Gets the number of commits behind remote
git_commits_behind()
{
    if git rev-parse --git-dir &>/dev/null; then
        local commits="$(git rev-list --count HEAD..@{upstream})"
        if [[ $commits != 0 ]]; then
            echo "$ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX$commits$ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX"
        fi
    fi
}

# Outputs if current branch is ahead of remote
git_prompt_ahead()
{
    if [[ -n "$(git rev-list origin/$(git_current_branch)..HEAD 2>/dev/null)" ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
    fi
}

# Outputs if current branch is behind remote
git_prompt_behind()
{
    if [[ -n "$(git rev-list HEAD..origin/$(git_current_branch) 2>/dev/null)" ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_BEHIND"
    fi
}

# Outputs if current branch exists on remote or not
git_prompt_remote()
{
    if [[ -n "$(git show-ref origin/$(git_current_branch) 2>/dev/null)" ]]; then
        echo "$ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS"
    else
        echo "$ZSH_THEME_GIT_PROMPT_REMOTE_MISSING"
    fi
}

# Formats prompt string for current git commit short sha
git_prompt_short_sha()
{
    local sha
    sha="$(git rev-parse --short HEAD 2>/dev/null)" &&
        echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$sha$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Formats prompt string for current git commit long sha
git_prompt_long_sha()
{
    local sha
    sha="$(git rev-parse HEAD 2>/dev/null)" &&
        echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$sha$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Get the status of the working tree
git_prompt_status()
{
    local INDEX _status
    INDEX="$(git status --porcelain -b 2>/dev/null)"
    _status=""

    if echo "$INDEX" | grep -E '^\?\? ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_UNTRACKED$_status"
    fi

    if echo "$INDEX" | grep '^A  ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_ADDED$_status"
    elif echo "$INDEX" | grep '^M  ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_ADDED$_status"
    fi

    if echo "$INDEX" | grep '^ M ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_MODIFIED$_status"
    elif echo "$INDEX" | grep '^AM ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_MODIFIED$_status"
    elif echo "$INDEX" | grep '^ T ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_MODIFIED$_status"
    fi

    if echo "$INDEX" | grep '^R  ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_RENAMED$_status"
    fi

    if echo "$INDEX" | grep '^ D ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_DELETED$_status"
    elif echo "$INDEX" | grep '^D  ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_DELETED$_status"
    elif echo "$INDEX" | grep '^AD ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_DELETED$_status"
    fi

    if git rev-parse --verify refs/stash &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_STASHED$_status"
    fi

    if echo "$INDEX" | grep '^UU ' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_UNMERGED$_status"
    fi

    if echo "$INDEX" | grep '^## [^ ]\+ .*ahead' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_AHEAD$_status"
    fi

    if echo "$INDEX" | grep '^## [^ ]\+ .*behind' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_BEHIND$_status"
    fi

    if echo "$INDEX" | grep '^## [^ ]\+ .*diverged' &>/dev/null; then
        _status="$ZSH_THEME_GIT_PROMPT_DIVERGED$_status"
    fi

    echo "$_status"
}

# Compares the provided version of git to the version installed and on path
# Outputs -1, 0, or 1 if the installed version is less than, equal to, or
# greater than the input version, respectively.
git_compare_version()
{
    if __zplug::base::base::git_version "$@"; then
        echo 1
        return 0
    fi
    echo -1
}

# Outputs the name of the current user
# Usage example: $(git_current_user_name)
git_current_user_name()
{
    git config user.name
}

# Outputs the email of the current user
# Usage example: $(git_current_user_email)
git_current_user_email()
{
    git config user.email
}
