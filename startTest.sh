#!/bin/bash
findDuration(){

time=true

while $time;

do

jmxFile=`cat JMX.csv`

cat $jmxFile | grep "ThreadGroup.duration" >/dev/null 2>&1

if [ $? -eq '0' ]; then

	value=`cat $jmxFile | grep "ThreadGroup.duration" | sed 's/[^0-9]*//g'`

	echo "Script will run for $value seconds"

	wait=`expr $value + 30`

	sleep $wait
fi

time=false

done
}

startTest(){
startTest=true
while $startTest;

do

read -p "Your Test is ready.. Press Y to start and N to exit [Y/n]: " startStatus

        if [[ $startStatus == 'y' || $startStatus == 'Y' ]]; then
                echo "Starting the Test"
		
		startup=`cat clusters.csv`

		for i in $startup

 		do
		
		clusterName=`echo $i | awk -F ',' '{ print $1 }'`

                zoneSelect=`echo $i | awk -F ',' '{ print $2 }'`

		tenant=`echo $i | awk -F ',' '{ print $5 }'`

                gcloud container clusters get-credentials $clusterName --zone $zoneSelect --project etsyperftesting-208619

		master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
 
 		jmxFile=`cat JMX.csv`                

		kubectl exec -it -n $tenant $master_pod -- /jmeter/load_test $jmxFile &

                startTest=false;

		done
		
		findDuration

		anotherTest

        elif [[ $startStatus == 'n' || $startStatus == 'N' ]]; then

		differentTest
                startTest=false;

        else

                echo  "Enter a valid response y or n: "

                startTest=true;

        fi
done
}

anotherTest () {
another=true

read -p "Do you want to test again with same script with the same setup [Y/n]?" again

	if [[ $again == 'y' || $again == 'Y' ]]; then
		startTest
		anotherTest=false

        elif [[ $again == 'n' || $again == 'N' ]]; then
		differentTest
		anotherTest=false
	else

              	echo "Select valid option [Y/n] "
		anotherTest=true
	fi

}

differentTest () {
differentTest=true
setupType=Multi-Region

while $differentTest;

do

read -p "Do you want to test different script with the same $setupType setup [Y/n]?" again

	if [[ $again == 'y' || $again == 'Y' ]]; then

      		bash ./uploadFiles.sh
		startTest
		differentTest=false

        elif [[ $again == 'n' || $again == 'N' ]]; then

		bash ./deleteCluster.sh
		exit 0;
	   	differentTest=false

	else

		echo "Select Valid option [Y/n] "
		differentTest=true


	fi

done
}

startTest
anotherTest

exit 0;
