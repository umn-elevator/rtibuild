FROM        ubuntu:18.04 as base

FROM    base as build
WORKDIR     /tmp/workdir

RUN     apt-get -yqq update && \
        apt-get install -yqq --no-install-recommends ca-certificates && \
        rm -rf /var/lib/apt/lists/*

RUN     apt-get -yqq update && \ 
        apt-get --no-install-recommends -yqq install curl unzip make autoconf automake cmake g++ gcc  && \
        rm -rf /var/lib/apt/lists/*

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install qt5-qmake qt5-default && \
        rm -rf /var/lib/apt/lists/*

# ideally we would link this statically so we could drop QT.  But we don't actually know QT.
RUN     DIR=/tmp/rti && \
        mkdir -p ${DIR} && \
        curl -o ${DIR}/rti.zip http://vcg.isti.cnr.it/~palma/webRTIViewer.zip && \
        unzip ${DIR}/rti.zip -d ${DIR} && \
        cd ${DIR}/webRTIViewer/webGLRTIMaker-src && \
        qmake webGLRtiMaker.pro && \
        make && \
        mv webGLRtiMaker /usr/local/bin/webGLRtiMaker && \
        rm -rf ${DIR}

FROM    base as release

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install qt5-default  && \
        rm -rf /var/lib/apt/lists/*

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install xvfb  && \
        rm -rf /var/lib/apt/lists/*

COPY    --from=build /usr/local/bin/webGLRtiMaker /usr/local/bin/webGLRtiMaker

ADD     rti_runner /usr/local/bin/rti_runner.sh
RUN     chmod a+x /usr/local/bin/rti_runner.sh

MAINTAINER  Colin McFadden <mcfa0086@umn.edu>

WORKDIR     /scratch/
CMD         ["--help"]
ENTRYPOINT  ["/usr/local/bin/rti_runner.sh"]
ENV         XDG_RUNTIME_DIR=/tmp
