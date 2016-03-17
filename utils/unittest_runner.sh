#!/bin/bash

CONTAINER=$(docker run -d -v "$WORKSPACE/:/workspace" tosmi/puppetunit /bin/bash -c 'source ~/.bashrc; cd /workspace && rake syntax && rake lint && rake spec')
docker attach $CONTAINER
RC=$(docker wait $CONTAINER)
docker rm $CONTAINER
exit $RC
