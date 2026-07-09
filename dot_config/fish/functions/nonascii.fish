function nonascii
    env LC_ALL=C grep -n '[^[:print:][:space:]]' $argv[1]
end
