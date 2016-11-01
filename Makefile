NAME=meetwalter/elixir
VERSION=$(shell cat VERSION)

.PHONY: image tag release

image:
	docker build --pull -t $(NAME):$(VERSION) .

tag:
	docker tag $(NAME):$(VERSION) $(NAME):latest
	git tag -d $(VERSION) 2>&1 >/dev/null || :
	git tag $(VERSION)

release: image tag
	docker push $(NAME)

test-server: image
	docker run --rm -i -t --name elixir-default-server --publish-all -e "GITHUB_ACCESS_TOKEN=$(GITHUB_ACCESS_TOKEN)" -e "GITHUB_AUTHORIZED_ORGS=$(GITHUB_AUTHORIZED_ORGS)" $(NAME):$(VERSION)

test-client: image
	ssh -p $(docker inspect -f '{{index .NetworkSettings "Ports" "22/tcp" 0 "HostPort"}}' elixir-default-server) erlang@$(docker inspect -f '{{index .NetworkSettings "IPAddress"}}' elixir-default-server)
	#docker run --rm -i -t --name elixir-default-client $(NAME):$(VERSION) connect
