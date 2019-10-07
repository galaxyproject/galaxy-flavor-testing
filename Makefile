GALAXY_TRAVIS_USER:=galaxy
GALAXY_UID:=1450
GALAXY_GID:=1450
GALAXY_HOME:=/home/galaxy
GALAXY_USER:=admin@galaxy.org
GALAXY_USER_EMAIL:=admin@galaxy.org
GALAXY_USER_PASSWD:=admin
BIOBLEND_GALAXY_API_KEY:=admin
BIOBLEND_GALAXY_URL:=http://localhost:8080


all: docker_install docker_build docker_run sleep install test_api test_ftp test_bioblend test_docker_in_docker
	@echo "Running all installations and testing artefacts for your Galaxy flavor!"

docker_install:
	sudo apt-get update -qq
	sudo apt-get install docker-ce --no-install-recommends -y -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew"
	docker --version
	docker info

docker_build:
	git submodule update --init --recursive
	sudo groupadd -r $(GALAXY_TRAVIS_USER) -g $(GALAXY_GID)
	sudo useradd -u $(GALAXY_UID) -r -g $(GALAXY_TRAVIS_USER) -d $(GALAXY_HOME) -p travis_testing -c "Galaxy user" $(GALAXY_TRAVIS_USER)
	sudo mkdir $(GALAXY_HOME)
	sudo chown -R $(GALAXY_TRAVIS_USER):$(GALAXY_TRAVIS_USER) $(GALAXY_HOME)
	docker build -t galaxy-docker/test .

docker_run:
	docker run -d -p 8080:80 -p 8021:21 -p 8022:22 \
		--name galaxy_test_container \
		--privileged=true \
		-e GALAXY_CONFIG_ALLOW_USER_DATASET_PURGE=True \
		-e GALAXY_CONFIG_ALLOW_LIBRARY_PATH_PASTE=True \
		-e GALAXY_CONFIG_ENABLE_USER_DELETION=True \
		-e GALAXY_CONFIG_ENABLE_BETA_WORKFLOW_MODULES=True \
		-v /tmp/:/tmp/ \
		galaxy-docker/test
	docker ps
	docker exec -i -t galaxy_test_container /tool_deps/_conda/bin/galaxy-wait -v

sleep:
	sleep 60

install:
	# travis special feature ;)
	sudo rm -f /etc/boto.cfg
	cd $(GALAXY_HOME) && sudo su $(GALAXY_TRAVIS_USER) -c 'wget https://github.com/galaxyproject/bioblend/archive/master.tar.gz'
	cd $(GALAXY_HOME) && sudo su $(GALAXY_TRAVIS_USER) -c 'tar xfz master.tar.gz'
	sudo su $(GALAXY_TRAVIS_USER) -c 'pip install --user --upgrade "tox>=1.8.0" "pep8<=1.6.2" six '
	cd $(GALAXY_HOME)/bioblend-master && sudo su $(GALAXY_TRAVIS_USER) -c 'python setup.py install --user'
	# remove flake8 testing for bioblend from tox
	cd $(GALAXY_HOME)/bioblend-master && sudo su $(GALAXY_TRAVIS_USER) -c "sed -i 's/commands.*$$/commands =/' tox.ini" && sudo su $(GALAXY_TRAVIS_USER) -c "sed -i 's/GALAXY_VERSION/GALAXY_VERSION BIOBLEND_TEST_JOB_TIMEOUT/' tox.ini"

test_api:
	curl --fail $(BIOBLEND_GALAXY_URL)/api/version

test_ftp:
	date > $(HOME)/time.txt && curl --fail -T $(HOME)/time.txt ftp://localhost:8021 --user $(GALAXY_USER):$(GALAXY_USER_PASSWD)
	curl --fail ftp://localhost:8021 --user $(GALAXY_USER):$(GALAXY_USER_PASSWD)

test_bioblend:
	# Run bioblend nosetests with the same UID and GID as the galaxy user inside if Docker
	# this will guarantee that exchanged files bewteen bioblend and Docker are read & writable from both sides
	sudo -E su $(GALAXY_TRAVIS_USER) -c "export BIOBLEND_GALAXY_API_KEY=admin && export BIOBLEND_GALAXY_URL=http://localhost:8080 && export BIOBLEND_TEST_JOB_TIMEOUT=240 && export PATH=$(GALAXY_HOME)/.local/bin/:$(PATH) && cd $(GALAXY_HOME)/bioblend-master && tox -e $(TOX_ENV) -- -k 'not download_dataset and not download_history and not export_and_download'"

test_docker_in_docker:	
	# Test Docker in Docker, used by Interactive Environments; This needs to be at the end as Docker takes some time to start.
	docker exec -i -t galaxy_test_container docker info
