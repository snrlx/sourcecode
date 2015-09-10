echo "################## HEALING FAULT #################"
echo

echo "restarting the controller"
virsh start controller

echo "wait for controller to come up again"
until [ "`ssh-keyscan -H controller 2> /dev/null`" != "" ]
do
	sleep 1
done

#todo: wait for compute nodes to be found
