#!/bin/bash
deleteCluster(){
delete=true

while $delete;

do

read -p "Do you want to delete the cluster [y/n]: " deleteCluster

        if [[ $deleteCluster == 'y' || $deleteCluster == 'Y' ]]; then
		clusterDelete=`cat clusters.csv`
		for i in $clusterDelete
		do
		clusterName=`echo $i | awk -F ',' '{ print $1 }'`

		zoneSelect=`echo $i | awk -F ',' '{ print $2 }'`
                gcloud container clusters delete $clusterName --zone $zoneSelect --quiet
		done
		delete=false
        elif [[ $deleteCluster == 'n' || $deleteCluster == 'N' ]]; then
		echo "Cluster is Active. Run your scripts if you want as intructed, otherwise please delete it"
                delete=false;
        else
                echo  "Enter a valid response y or n ";
                delete=true;
        fi

done
}

deleteCluster

exit 0;
