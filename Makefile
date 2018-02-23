NAME = irssi-icb
VERSION = 1.1.1

ARCH_VERSION = `/bin/date +%Y.%m`
DATE = `/bin/date +%Y-%m-%d`

DOCKER_FLAGS ?= --memory=4GB --rm=true
DOCKER_MOUNTS ?= --mount type=bind,source=$(PWD)/pkg,destination=/opt/output
DOCKER_REPOSITORY ?= sl4mmy

all: Dockerfile pkg/
	docker build --rm=true --tag="$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)" $(DOCKER_FLAGS) .

Dockerfile: Dockerfile.in Makefile
	sed "s/\$${ARCH_VERSION}/$(ARCH_VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${REPOSITORY}/$(DOCKER_REPOSITORY)/; s/\$${DATE}/$(DATE)/" $(<) >$(@)

pkg/:
	mkdir pkg

attach:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-attach" $(DOCKER_MOUNTS) --entrypoint=/bin/bash "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

run:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-run" $(DOCKER_MOUNTS) "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

update: Dockerfile.in pkg/
	git subtree pull --prefix irssi-icb https://github.com/mglocker/irssi-icb.git master --squash
	sed "s/\$${ARCH_VERSION}/$(ARCH_VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${REPOSITORY}/$(DOCKER_REPOSITORY)/; s/\$${DATE}/$(DATE)/" $(<) >Dockerfile
	$(MAKE)

clean:
	-rm -f Dockerfile
	-rm -rf pkg/

.PHONY: all attach clean run update
