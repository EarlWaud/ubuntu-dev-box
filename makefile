all:
	docker image build -t ubuntu-devbox .

run:
	docker container run -it --name devbox --privileged ubuntu-devbox:latest

run-gnome:
	./run-with-gnome.sh

clean: remove-container
	docker rmi --force ubuntu-devbox:latest

remove-container:
	docker container rm devbox
