function serve
    set -l port 8080
    test (count $argv) -ge 1; and set port $argv[1]
    ruby -run -e httpd . -p $port
end
