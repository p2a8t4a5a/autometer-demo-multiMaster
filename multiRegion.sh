#!/bin/bash

echo "End to End Test"

bash ./clusterCreate.sh

bash ./uploadFiles.sh

bash ./startTest.sh

bash ./deleteCluster.sh

exit 0;
