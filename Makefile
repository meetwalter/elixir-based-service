NAME=meetwalter/elixir
VERSION=$(shell cat VERSION)

.PHONY: image tag release

image:
	docker build -t $(NAME):$(VERSION) .

tag:
	docker tag $(NAME):$(VERSION) $(NAME):latest
	git tag -d $(VERSION) 2>&1 >/dev/null || :
	git tag $(VERSION)

release: image tag
	docker push $(NAME)

test-server: image
	docker run --rm -i -t --name elixir-default-server --publish-all -e "SSH_VIA_GITHUB=meetwalter:9ee98462abe805094323e642e218fa25fe5136f5" $(NAME):$(VERSION)

test-client: image
	ssh erlang@$(docker inspect -f '{{index .NetworkSettings "IPAddress"}}' elixir-default-server):$(docker inspect -f '{{index .NetworkSettings "Ports" "22/tcp" 0 "HostPort"}}' elixir-default-server)
	#docker run --rm -i -t --name elixir-default-client $(NAME):$(VERSION) connect
