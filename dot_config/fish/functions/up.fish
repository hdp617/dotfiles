function up
    set -l n 1
    test (count $argv) -ge 1; and set n $argv[1]
    string match -rq '^[0-9]+$' -- $n; or begin
        echo 'Error: argument must be a number' >&2
        return 1
    end
    test "$n" -gt 0; or begin
        echo 'Error: argument must be positive' >&2
        return 1
    end
    set -l cdir $PWD
    for i in (seq 1 $n)
        set -l ncdir (dirname $cdir)
        test "$cdir" = "$ncdir"; and break
        set cdir $ncdir
    end
    cd $cdir
end
