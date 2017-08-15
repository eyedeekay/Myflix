FROM alpine:3.5
ARG TMDBapi
RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
RUN apk update
RUN apk add jq imagemagick ffmpeg bash darkhttpd curl wget youtube-dl ca-certificates moreutils@testing
RUN adduser -h /home/flix -s bash -D flix
COPY . /home/flix/myflix
RUN rm /home/flix/myflix/scripts/tmdbapi.cfg
RUN chown -R flix:flix /home/flix
RUN chown -R root:root /home/flix/myflix/scripts
COPY scripts/tmdbapi.cfg /home/flix/.api_keys/
USER flix
WORKDIR /home/flix/myflix/scripts
RUN bash -c 'source config.cfg && \
        mkdir -p $TVpath $MoviesPath $dMoFolder $dTVFolder && \
        touch $TVpath/ex $MoviesPath/ex $dMoFolder/ex $dTVFolder/ex '
RUN [ "./buildDBs.sh", "3" ]
RUN [ "./buildHtml.sh", "3" ]
VOLUME /home/flix/myflix/TV \
        /home/flix/myflix/Movies \
        /home/flix/myflix/TVimg \
        /home/flix/myflix/MoImg
CMD [ "darkhttpd", "/home/flix/myflix/"] #, "--index", "TV.html" ]
