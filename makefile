all:
	docker image build -t ubuntu-devbox .

run:
	docker container run -it --name devbox --privileged ubuntu-devbox:latest

run-gnome:
	./run-with-gnome.sh

clean:
	docker container rm devbox
	docker rmi ubuntu-devbox:latest
