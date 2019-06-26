#!/usr/bin/env bash
#Script writtent to stop a running jmeter master test
#Kindly ensure you have the necessary kubeconfig

working_dir=`pwd`

#Get namesapce variable
tenant=master

clusterName=`cat master.csv | awk -F ',' '{ print $1 }'`

zoneSelect=`cat master.csv | awk -F ',' '{ print $2 }'`

gcloud container clusters get-credentials $clusterName --zone $zoneSelect --project etsyperftesting-208619

master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

kubectl -n $tenant exec -ti $master_pod bash /jmeter/apache-jmeter-5.0/bin/stoptest.sh
