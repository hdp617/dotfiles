function fpr
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo 'error: fpr must be executed from within a git repository' >&2
        return 1
    end

    cdgr; or return

    set -l repo user branch
    switch (count $argv)
        case 2
            set repo (basename $PWD)
            set user $argv[1]
            set branch $argv[2]
        case 3
            set repo $argv[1]
            set user $argv[2]
            set branch $argv[3]
        case '*'
            echo 'Usage: fpr [repo] username branch' >&2
            return 1
    end

    git fetch git@github.com:$user/$repo $branch:$user/$branch
end
