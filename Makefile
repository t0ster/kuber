.SILENT: default
default:
	echo "make telepresence_ui # swap kuber-ui deployment with node docker image"
	echo "make telepresence_functions # swap kuber-functions deployment with python docker image"
	echo "make telestop"
telepresence_ui:
	telepresence --swap-deployment kuber-ui --docker-run --name node --rm -v /vagrant:/vagrant node tail -f /dev/null &
telepresence_functions:
	telepresence --swap-deployment kuber-functions --docker-run --name python --rm -v /vagrant:/vagrant python:3-slim tail -f /dev/null &
telestop:
	docker stop node
