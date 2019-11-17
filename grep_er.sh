#!/usr/bin/env bash
#Ver 1.1 by Artur Hamelak
#Created on 12.11.2019

if [[ $1 =~ ^(dk|se|es|mtit|uk|cz|mt|gib|cw)$ ]]
    then
        true
    else
        echo "No or incorrect environment provided. Please choose a proper one."
        echo "Envs: dk, se, es, mtit, uk, cz, mt, gib or cw"
        exit
fi

if [[ $1 =~ ^(dk|se|es|mtit|uk|cz|mt)$ ]]
    then
        loc=/var/log/remote/cloudstack/prod-
elif [[ $1 =~ ^(gib)$ ]]
    then
        loc=/var/log/remote/docker/prod-
else
        loc=/mnt/central_logs/prod-
fi

redis=($"printf 'Redis Timeout Execption:\nAPP:\n' &&
                grep -c -i 'RedisTimeoutException' '$loc''$1'/app*log;
       printf 'API:\n' &&
                grep -c -i 'RedisTimeoutException' '$loc''$1'/api*log;")

read=($"printf '\nRead Timed Out on Prod MT:\n' &&
                grep -c -i 'read timed out' '$loc''$1'/app*log;")

socket=($"printf '\nSocket Timeout Exception:\n' &&
                grep -c -i 'sockettimeoutexception' '$loc''$1'/app*log;")

error=($"printf '\nNgs Error Exception:\n' &&
                grep -c -i 'ngserrorexception' '$loc''$1'/app*log;")

hessian=($"printf '\nHessian Connection Exception:\n' &&
                grep -c -i 'HessianConnectionException' '$loc''$1'/api*log;")

sql_error=($"printf '\nSQL Error:\n' &&
                grep -c -i 'sql error' '$loc''$1'/app*log;")

severe=($"printf '\nSevere Overall:\nAPP:\n' &&
                grep -c -i 'severe' '$loc''$1'/app*log;
       printf 'API:\n' &&
                grep -c -i 'severe' '$loc''$1'/api*log;")

if [[ $1 =~ ^(dk|se|es|mtit|uk|cz|mt)$ ]]
    then
        ssh "<SERVER1>" << EOF
            ${redis}
            ${read}
            ${socket}
            ${error}
            ${hessian}
            ${sql_error}
            ${severe}
EOF

elif [[ $1 =~ ^(gib)$ ]]
    then
        ssh "<SERVER2>" << EOF
            ${redis}
            ${read}
            ${socket}
            ${error}
            ${hessian}
            ${sql_error}
            ${severe}
EOF

elif [[ $1 =~ ^(cw)$ ]]
    then
        ssh "<SERVER3>" << EOF
            ${redis}
            ${read}
            ${socket}
            ${error}
            ${hessian}
            ${sql_error}
            ${severe}
EOF

fi