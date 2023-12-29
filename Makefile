build:
	sudo docker build . -t ghcr.io/cyrusimap/cyrus-docker-release:latest

upload:
	sudo docker push       ghcr.io/cyrusimap/cyrus-docker-release:latest

run:
	sudo docker run -it    ghcr.io/cyrusimap/cyrus-docker-release:latest
