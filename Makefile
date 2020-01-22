.SILENT: default
default:
	echo "make telepresence # swap kuber-ui deployment with node docker image"
	echo "make telestop"
telepresence:
	telepresence --swap-deployment kuber-ui --docker-run --name node --rm -v /vagrant:/vagrant node tail -f /dev/null &
telestop:
	docker stop node
