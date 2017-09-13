
include $(HOME)/.api_keys/tmdbapi.cfg
#include scripts/tmdbapi.cfg

export MEDIA_DIR = $(shell pwd)
export SHELL = dash

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
	docker run -p 80:8080 \
		--cap-drop=all \
		-v $(MEDIA_DIR)/MoImg:/home/myflix/myflix/MoImg \
		-v $(MEDIA_DIR)/Movies:/home/myflix/myflix/Movies \
		-v $(MEDIA_DIR)/TV:/home/myflix/myflix/TV \
		-v $(MEDIA_DIR)/TVimg:/home/myflix/myflix/TVimg \
		 --name myflix -t myflix

docker-index:
	docker exec -t myflix bash -c './buildDBs.sh 3'
	docker exec -t myflix bash -c './buildHtml.sh 3'

docker-backup-db:
	docker cp myflix:/home/flix/myflix/Movies $(HOME)/Movies
	docker cp myflix:/home/flix/myflix/TV $(HOME)/TV

check:
	cd scripts; \
	shellcheck -s "$(SHELL)" -x buildDBs.sh > ../builddb.log; \
	shellcheck -s "$(SHELL)" -x bTVShow.sh >> ../builddb.log; \
	shellcheck -s "$(SHELL)" -x getMid.sh >> ../builddb.log; \
	shellcheck -s "$(SHELL)" -x getTVid.sh >> ../builddb.log; \
	shellcheck -s "$(SHELL)" -x getMposter.sh >> ../builddb.log; \
	shellcheck -s "$(SHELL)" -x getTVposter.sh >> ../builddb.log; \
	shellcheck -s "$(SHELL)" -x buildHtml.sh > ../buildhtml.log; \
	shellcheck -s "$(SHELL)" -x bMhtml.sh >> ../buildhtml.log; \
	shellcheck -s "$(SHELL)" -x bTVhtml.sh >> ../buildhtml.log; \
	checkbashisms -x -f buildDBs.sh 2> ../bashismsdb.log; \
	checkbashisms -x -f bTVShow.sh 2>> ../bashismsdb.log; \
	checkbashisms -x -f getMid.sh 2>> ../bashismsdb.log; \
	checkbashisms -x -f getTVid.sh 2>> ../bashismsdb.log; \
	checkbashisms -x -f getMposter.sh 2>> ../bashismsdb.log; \
	checkbashisms -x -f getTVposter.sh 2>> ../bashismsdb.log; \
	checkbashisms -x -f buildHtml.sh 2> ../bashismshtml.log; \
	checkbashisms -x -f bMhtml.sh 2>> ../bashismshtml.log; \
	checkbashisms -x -f bTVhtml.sh 2>> ../bashismshtml.log; \
	true
