NAME = ft_server
VERSION = test
LOCATION = .
PORT1 = 80
PORT2 = 443

.PHONY: docker
docker:
	@systemctl start docker.service
	@echo -e "\n\033[32m[+] The docker is launched!\033[0m\n"

.PHONY: build
build:
	 docker build $(LOCATION) --tag $(NAME):$(VERSION)
	@echo -e "\n\033[32m[+] Build completed!\033[0m\n"

.PHONY: stop
stop:
	 docker stop $(NAME)

.PHONY: run
run:
	docker run --name $(NAME) -p $(PORT1):80 -p $(PORT2):443 -d $(NAME):$(VERSION)
	@echo -e "\n\033[32m[+] The container was started with:\033[0m\n\tport = $(PORT1), $(PORT2)\n\tname = $(NAME)\n\n"

.PHONY: exec
exec:
	docker exec -it $(NAME) bin/bash

.PHONY: remove
remove:
	docker rm $(NAME)
	@echo -e "\n\033[32m[+] The container named $(NAME) was deleted!\033[0m\n"

.PHONY: exit
exit: stop remove

.PHONY: images
images: 
	@docker images
