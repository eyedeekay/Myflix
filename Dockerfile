FROM alpine:3.5
ARG TMDBapi
RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
RUN apk update
RUN apk add jq imagemagick ffmpeg bash darkhttpd curl wget lftp ca-certificates moreutils@testing
RUN adduser -h /home/flix -s /bin/bash -D flix
COPY . /home/flix/myflix
RUN rm -f /home/flix/myflix/scripts/tmdbapi.cfg
RUN chown -R flix:flix /home/flix
RUN chown -R root:root /home/flix/myflix/scripts
COPY scripts/tmdbapi.cfg /home/flix/.api_keys/
USER flix
WORKDIR /home/flix/myflix/scripts
RUN bash -c 'source config.cfg && \
        mkdir -p $TVpath $MoviesPath $dMoFolder $dTVFolder && \
        chown flix:flix $TVpath $MoviesPath $dMoFolder $dTVFolder && \
        touch $TVpath/ex $MoviesPath/ex $dMoFolder/ex $dTVFolder/ex'
#RUN cd $MoviesPath && lftp -c "torrent https://archive.org/download/FfreedomDowntime/FfreedomDowntime_archive.torrent"
#RUN cd $TVpath && lftp -c "torrent https://archive.org/download/PBSFrontlineGrowingUpOnline/PBSFrontlineGrowingUpOnline_archive.torrent"
#RUN cd $MoviesPath && lftp -c "torrent https://archive.org/download/RevolutionOS/RevolutionOS_archive.torrent"
#RUN ./buildDBs.sh 3
#RUN ./buildHtml.sh 3
VOLUME /home/flix/myflix/TV \
        /home/flix/myflix/Movies \
        /home/flix/myflix/TVimg \
        /home/flix/myflix/MoImg
CMD ./buildDBs.sh 3 && \
        ./buildHtml.sh 3 && \
        darkhttpd /home/flix/myflix/ #--index TV.html
