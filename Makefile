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
	docker run --rm -i -t --name elixir-default-server --publish-all -e "SSH_VIA_GITHUB=meetwalter:ce96b359848acaacca7ffafdbc97dd3831c1e25f" $(NAME):$(VERSION)

test-client: image
	ssh -p $(docker inspect -f '{{index .NetworkSettings "Ports" "22/tcp" 0 "HostPort"}}' elixir-default-server) erlang@$(docker inspect -f '{{index .NetworkSettings "IPAddress"}}' elixir-default-server)
	#docker run --rm -i -t --name elixir-default-client $(NAME):$(VERSION) connect
