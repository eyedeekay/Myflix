FROM pre-myflix
ARG TMDBapi
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
RUN cd /home/flix/myflix/TV && youtube-dl -f 160 https://www.youtube.com/watch?v=136IXEzXEwY && \
        mv -v Rick*.mp4 RickandMorty.S3E03.mp4
RUN cd /home/flix/myflix/TV && youtube-dl -f 160 https://www.youtube.com/watch?v=lXV_zxIy0Dc && \
        mv -v *Memory*.mp4 Rick.and.Morty.S3E01.mp4
RUN echo $TMDBapi
RUN [ "./buildDBs.sh", "2" ]
RUN [ "./buildHtml.sh", "2" ]
VOLUME /home/flix/myflix/TV \
        /home/flix/myflix/Movies \
        /home/flix/myflix/TVimg \
        /home/flix/myflix/MoImg
CMD [ "darkhttpd", "/home/flix/myflix/"] #, "--index", "TV.html" ]
