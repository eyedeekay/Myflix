FROM alpine:3.5
RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
RUN apk update
RUN apk add jq imagemagick ffmpeg bash darkhttpd curl wget youtube-dl ca-certificates moreutils@testing
RUN adduser -h /home/flix -s bash -D flix
COPY . /home/flix/myflix
RUN chown -R flix:flix /home/flix
RUN chown -R root:root /home/flix/myflix/scripts
USER flix
WORKDIR /home/flix/myflix/scripts
RUN bash -c 'source config.cfg && \
        mkdir -p $TVpath $MoviesPath $dMoFolder $dTVFolder && \
        touch $TVpath/ex $MoviesPath/ex $dMoFolder/ex $dTVFolder/ex ../dbM.json'
RUN cd /home/flix/myflix/TV && youtube-dl -f 160 https://www.youtube.com/watch?v=136IXEzXEwY && \
        mv -v Rick*.mp4 RickandMorty.S3E03.mp4
RUN cd /home/flix/myflix/TV && youtube-dl -f 160 https://www.youtube.com/watch?v=lXV_zxIy0Dc && \
        mv -v *Memory*.mp4 Rick.and.Morty.S3E01.mp4
RUN cd /home/flix/myflix/Movies && youtube-dl -f 160 https://www.youtube.com/watch?v=136IXEzXEwY && \
        mv -v Rick*.mp4 Rick.and.Morty.Three.mp4
RUN cd /home/flix/myflix/Movies && youtube-dl -f 160 https://www.youtube.com/watch?v=lXV_zxIy0Dc && \
        mv -v *Memory*.mp4 Rick.and.Morty.One.mp4
RUN [ "./buildDBs.sh", "3" ]
RUN ls ../Movies ../TV ../MoImg ../TVimg
RUN [ "./buildHtml.sh", "3" ]
VOLUME /home/flix/myflix/TV \
        /home/flix/myflix/Movies \
        /home/flix/myflix/TVimg \
        /home/flix/myflix/MoImg
CMD [ "darkhttpd", "/home/flix/myflix/"] #, "--index", "TV.html" ]
