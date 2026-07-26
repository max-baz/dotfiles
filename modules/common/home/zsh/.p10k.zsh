# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
    emulate -L zsh -o extended_glob

    unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        time
        background_jobs
        context
        dir
        nix_shell
        direnv
        vcs
        virtualenv
        kubecontext
        azure
        zed
        db
        command_execution_time

        newline
        prompt_char
    )

    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

    typeset -g POWERLEVEL9K_MODE=awesome-fontconfig
    typeset -g POWERLEVEL9K_ICON_PADDING=none
    typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=

    typeset -g POWERLEVEL9K_BACKGROUND=
    typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
    typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
    typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=

    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
    typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
    p10k-on-pre-prompt()  { p10k display '1'=show }
    p10k-on-post-prompt() { p10k display '1'=hide }

    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
    typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
    typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=
    typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=

    typeset -g POWERLEVEL9K_SHOW_RULER=false
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '

    typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
    typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

    ####################################[ time: current time ]####################################
    typeset -g POWERLEVEL9K_TIME_FOREGROUND=yellow
    typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
    typeset -g POWERLEVEL9K_TIME_PREFIX=''
    typeset -g POWERLEVEL9K_TIME_CONTENT_EXPANSION='%B${P9K_CONTENT}'

    #######################[ background_jobs: presence of background jobs ]#######################
    typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=209
    typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION=" "

    ##################################[ context: user@hostname ]##################################
    typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=107
    typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=red
    typeset -g POWERLEVEL9K_CONTEXT_PREFIX='%fas '

    if (( P9K_SSH )); then
        POWERLEVEL9K_CONTEXT_TEMPLATE='%B%n@%m'
    else
        POWERLEVEL9K_CONTEXT_TEMPLATE=
        POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n'
    fi

    ##################################[ dir: current directory ]##################################
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=72
    typeset -g POWERLEVEL9K_DIR_PREFIX='%fin '
    typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
    typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
    typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

    local anchor_files=(
        .git
        .node-version
        .python-version
        .go-version
        .shorten_folder_marker
        .svn
        .terraform
        Cargo.toml
        go.mod
        package.json
    )

    typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
    typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
    typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
    typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v2
    typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
    typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND=221
    typeset -g POWERLEVEL9K_DIR_CLASSES=()

    #######################[ nix_shell: nix shell ]########################
    typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND=67
    typeset -g POWERLEVEL9K_NIX_SHELL_VISUAL_IDENTIFIER_EXPANSION=" "
    typeset -g POWERLEVEL9K_NIX_SHELL_CONTENT_EXPANSION=

    #######################[ direnv: direnv status (https://direnv.net/) ]########################
    typeset -g POWERLEVEL9K_DIRENV_FOREGROUND=179
    typeset -g POWERLEVEL9K_DIRENV_VISUAL_IDENTIFIER_EXPANSION=" "

    ##################[ virtualenv: python virtualenv ]##################
    typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=40
    typeset -g POWERLEVEL9K_VIRTUALENV_PREFIX='%fwith '
    typeset -g POWERLEVEL9K_VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION=" "
    typeset -g POWERLEVEL9K_VIRTUALENV_CONTENT_EXPANSION='${P9K_CONTENT%% *}'

    #####################################[ vcs: git status ]######################################
    function my_git_formatter() {
        emulate -L zsh

        if [[ -n "$P9K_CONTENT" ]]; then
            typeset -g gitstatus_format="$P9K_CONTENT"
            return
        fi

        if (( $1 )); then
            # Styling for up-to-date Git status.
            local clean='%F{#d3869b}'
            local meta='%F{yellow}'
            local stashes='%F{cyan}'
            local conflicted='%F{magenta}'
            local deleted='%F{red}'
            local unstaged='%F{yellow}'
            local untracked='%F{blue}'
            local staged='%F{green}'
            local outofsync='%F{yellow}'
        else
            # Styling for incomplete and stale Git status.
            local clean='%F{white}'
            local meta='%F{white}'
            local stashes='%F{white}'
            local conflicted='%F{white}'
            local deleted='%F{white}'
            local unstaged='%F{white}'
            local untracked='%F{white}'
            local staged='%F{white}'
            local outofsync='%F{white}'
        fi

        local res
        local where  # branch name, tag or commit
        if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
            res+="${clean} "
            where=${(V)VCS_STATUS_LOCAL_BRANCH}
        elif [[ -n $VCS_STATUS_TAG ]]; then
            res+="${meta}#"
            where=${(V)VCS_STATUS_TAG}
        else
            res+="${meta}@"
            where=${VCS_STATUS_COMMIT[1,8]}
        fi

        # If local branch name or tag is at most 32 characters long, show it in full.
        # Otherwise show the first 12 … the last 12.
        (( $#where > 32 )) && where[13,-13]="…"
        res+="${clean}${where//\%/%%}"  # escape %

        # Show tracking branch name if it differs from local branch.
        if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
            res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"  # escape %
        fi

        # Add a space before showing git status icons, if there are any
        (( VCS_STATUS_STASHES              ||
           VCS_STATUS_NUM_CONFLICTED       ||
           VCS_STATUS_NUM_UNSTAGED_DELETED ||
           VCS_STATUS_NUM_UNSTAGED         ||
           VCS_STATUS_NUM_UNTRACKED        ||
           VCS_STATUS_NUM_STAGED           ||
           VCS_STATUS_COMMITS_BEHIND       ||
           VCS_STATUS_COMMITS_AHEAD        )) && res+=' '

        # Show various git status icons
        (( VCS_STATUS_STASHES ))                                          && res+="${stashes}●"
        (( VCS_STATUS_NUM_CONFLICTED ))                                   && res+="${conflicted}●"
        (( VCS_STATUS_NUM_UNSTAGED_DELETED ))                             && res+="${deleted}●"
        (( VCS_STATUS_NUM_UNSTAGED > VCS_STATUS_NUM_UNSTAGED_DELETED ))   && res+="${unstaged}●"
        (( VCS_STATUS_NUM_UNTRACKED ))                                    && res+="${untracked}●"
        (( VCS_STATUS_NUM_STAGED ))                                       && res+="${staged}●"

        if (( VCS_STATUS_COMMITS_BEHIND && VCS_STATUS_COMMITS_AHEAD )); then
            res+="${outofsync}"
        elif (( VCS_STATUS_COMMITS_BEHIND )); then
            res+="${outofsync}"
        elif (( VCS_STATUS_COMMITS_AHEAD )); then
            res+="${outofsync}"
        fi

        typeset -g my_git_format="$res"
    }
    functions -M my_git_formatter 2>/dev/null

    typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
    typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
    typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='%B${$((my_git_formatter(1)))+${my_git_format}}'
    typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='%B${$((my_git_formatter(0)))+${my_git_format}}'
    typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

    typeset -g POWERLEVEL9K_VCS_PREFIX='%fon '

    typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

    #############[ kubecontext: current kubernetes context (https://kubernetes.io/) ]#############
    typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|kubens|kubectx|helm|kubecolor'
    typeset -g POWERLEVEL9K_KUBECONTEXT_PREFIX='%fat '
    typeset -g POWERLEVEL9K_KUBECONTEXT_VISUAL_IDENTIFIER_EXPANSION='☸️'

    typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
        '*-prod-*'  PROD
        '*'         DEFAULT)
    typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=140
    typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_FOREGROUND=201

    typeset -g POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION='%B'
    POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION+='${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}'
    POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION+='${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}'

    ##########[ azure: azure account name (https://docs.microsoft.com/en-us/cli/azure) ]##########
    typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az|terraform'
    typeset -g POWERLEVEL9K_AZURE_FOREGROUND=67
    typeset -g POWERLEVEL9K_AZURE_PREFIX='%fusing '
    typeset -g POWERLEVEL9K_AZURE_VISUAL_IDENTIFIER_EXPANSION="☁️"
    typeset -g POWERLEVEL9K_AZURE_CONTENT_EXPANSION='%B${P9K_CONTENT}'

    ###################[ command_execution_time: duration of the last command ]###################
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='%ftook '
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=yellow
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_CONTENT_EXPANSION='%B${P9K_CONTENT}'

    ################################[ prompt_char: prompt symbol ]################################
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=green
    typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=red
    typeset -g POWERLEVEL9K_PROMPT_CHAR_CONTENT_EXPANSION='%(#.#.$)'

    ##########[ custom: db ]##########
    function prompt_db() {
        [ -n "$DATABASE_PROFILE" ] || return
        [[ "$DATABASE_PROFILE" =~ (^|[^a-zA-Z0-9])(prod|production)([^a-zA-Z0-9]|$) ]] && env=PROD || env=DEFAULT
        p10k segment -t "%B$DATABASE_PROFILE" -s "$env"
    }
    typeset -g POWERLEVEL9K_DB_PREFIX='%fat '
    typeset -g POWERLEVEL9K_DB_VISUAL_IDENTIFIER_EXPANSION=" "
    typeset -g POWERLEVEL9K_DB_FOREGROUND=140
    typeset -g POWERLEVEL9K_DB_PROD_FOREGROUND=201

    ##########[ custom: zed ]##########
    function prompt_zed() {
        command -v zed &> /dev/null || return
        context=$(zed context use 2>/dev/null)
        [[ $? -eq 0 ]] || return
        [[ "$context" =~ (^|[^a-zA-Z0-9])(prod|production)([^a-zA-Z0-9]|$) ]] && env=PROD || env=DEFAULT
        p10k segment -t "%B$context" -s "$env"
    }
    typeset -g POWERLEVEL9K_ZED_PREFIX='%fat '
    typeset -g POWERLEVEL9K_ZED_VISUAL_IDENTIFIER_EXPANSION=" "
    typeset -g POWERLEVEL9K_ZED_FOREGROUND=140
    typeset -g POWERLEVEL9K_ZED_PROD_FOREGROUND=201
    typeset -g POWERLEVEL9K_ZED_SHOW_ON_COMMAND='zed'

    (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
