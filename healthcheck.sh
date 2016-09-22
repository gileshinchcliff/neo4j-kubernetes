#!/bin/bash
#!/bin/bash

STATUSCODE=$(curl -k -L --silent --output /dev/null --write-out "%{http_code}" https://127.0.0.1:7473/)

if test $STATUSCODE -ne 200; then
    echo "FAILURE"
    exit 1
else
    echo "SUCCESS"
    exit 0
fi
