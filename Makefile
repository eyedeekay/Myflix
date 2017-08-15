
include $(HOME)/.api_keys/tmdbapi.cfg
include scripts/tmdbapi.cfg

listing:
	@echo 'config'
	@echo 'docker-build'
	@echo 'docker-clean'
	@echo 'docker-remove'
	@echo 'docker-clobber'
	@echo 'docker-run'

config:
	cd scripts && ./buildDBs.sh 3
	cd scripts && ./buildHtml.sh 3

docker-cache:
	docker build -t pre-myflix -f Dockerfile.cache .

docker-build:
	make docker-remove ; \
	docker build --build-arg TMDBapi=$(TMDBapi) -t myflix .

docker-clean:
	docker rmi -f myflix; \

docker-remove:
	docker rm -f myflix; \

docker-clobber:
	make docker-clean ; \
	make docker-remove ; \
	docker system prune -f; echo cleaned

docker-run:
	docker run --rm \
		-d \
		-p 80:8080 \
		--cap-drop=all \
		-v MoImg:/home/myflix/myflix/MoImg \
		-v Movies:/home/myflix/myflix/Movies \
		-v TV:/home/myflix/myflix/TV \
		-v TVimg:/home/myflix/myflix/TVimg \
		 --name myflix -t myflix

docker-index:
	docker exec -t myflix bash -c './buildDBs.sh 3'
	docker exec -t myflix bash -c './buildHtml.sh 3'

docker-backup-db:
	docker cp myflix:/home/flix/myflix/Movies $(HOME)/Movies
	docker cp myflix:/home/flix/myflix/TV $(HOME)/TV
