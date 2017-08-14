
listing:
	@echo 'config'
	@echo 'docker-build'
	@echo 'docker-clean'
	@echo 'docker-run'

config:
	cd scripts && ./buildDBs.sh 3
	cd scripts && ./buildHtml.sh 3

docker-build:
	make docker-remove ; \
	docker build -t myflix .

docker-clean:
	docker rmi -f myflix; \

docker-remove:
	docker rm -f myflix; \

docker-clobber:
	make docker-clean
	make docker-remove ; \
	docker system prune -f; echo cleaned

docker-run:
	docker run --rm \
		-p 80:8080 \
		--cap-drop=all \
		-v MoImg:/home/myflix/myflix/MoImg \
		-v Movies:/home/myflix/myflix/Movies \
		-v TV:/home/myflix/myflix/TV \
		-v TVimg:/home/myflix/myflix/TVimg \
		 --name myflix -t myflix

docker-exec:
	docker exec -t myflix bash -c './buildDBs.sh 3'
	docker exec -t myflix bash -c './buildHtml.sh 3'
