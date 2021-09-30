ARG FIVEM_NUM=4686
ARG FIVEM_VER=4686-19ff3c66a6bf6ee59c2c009b7f729e43a4885b9b
ARG DATA_VER=b907aa74e2826e363979332ac21b9ad98cd82aa1

FROM alpine as builder

ARG FIVEM_VER
ARG DATA_VER

WORKDIR /output

RUN wget -O- http://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VER}/fx.tar.xz \
    | tar xJ --strip-components=1 \
    --exclude alpine/dev --exclude alpine/proc \
    --exclude alpine/run --exclude alpine/sys \
    && mkdir -p /output/opt/cfx-server-data /output/usr/local/share \
    && wget -O- http://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
    | tar xz --strip-components=1 -C opt/cfx-server-data \
    \
    && apk -p $PWD add tini

ADD server.cfg opt/cfx-server-data
ADD entrypoint usr/bin/entrypoint

RUN chmod +x /output/usr/bin/entrypoint

#================

FROM scratch

ARG FIVEM_VER
ARG FIVEM_NUM
ARG DATA_VER

LABEL maintainer="Dulkith <dulkith1234@gmail.com>" \
    org.label-schema.vendor="Ceylon Fort Life" \
    org.label-schema.name="FiveM" \
    org.label-schema.url="http://www.ceylonfortlife.com" \
    org.label-schema.description="FiveM is a modification for Grand Theft Auto V enabling you to play multiplayer on customized dedicated servers." \
    org.label-schema.version=${FIVEM_NUM} \
    io.spritsail.version.fivem=${FIVEM_VER} \
    io.spritsail.version.fivem_data=${DATA_VER}

COPY --from=builder /output/ /

WORKDIR /config
EXPOSE 30120

# Default to an empty CMD, so we can use it to add seperate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
