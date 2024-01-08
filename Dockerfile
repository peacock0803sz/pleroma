# syntax=docker/dockerfile:1
# ------------- #
# builder image #
# ------------- #
ARG ELIXIR_VER
FROM elixir:${ELIXIR_VER} AS builder
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}
SHELL ["/bin/bash", "-c"]

WORKDIR /pleroma
COPY ./app /pleroma/
COPY ./config /pleroma/config/

RUN apt-get update && apt-get upgrade -y \
  && apt-get install -yq --no-install-recommends \
  build-essential cmake libmagic-dev libimage-exiftool-perl
RUN mix local.hex --force && mix local.rebar --force \
  && mix deps.get --only ${MIX_ENV} && mix deps.compile --force && mix compile \
  && mkdir release && mix release --path release

# ------------ #
# runner image #
# ------------ #
FROM elixir:${ELIXIR_VER}-slim AS runner
ARG ELIXIR_VER

RUN apt-get update && apt-get upgrade -yq \
  && apt-get install -y --no-install-recommends \
  postgresql-13 libstdc++6 openssl libncurses5 locales libmagic-dev imagemagick ffmpeg libimage-exiftool-perl \
  && rm -rf /var/lib/apt/lists/*_* \
  && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ARG DATA=/var/lib/pleroma
RUN mkdir -p /etc/pleroma && chown -R nobody /etc/pleroma \
  && mkdir -p ${DATA}/uploads && mkdir -p ${DATA}/static \
  && chown -R nobody ${DATA}

USER nobody
ENV HOME=/pleroma
WORKDIR ${HOME}

COPY --from=builder --chown=nobody:root /pleroma/release /pleroma

EXPOSE 8080

CMD ["${HOME}/pleroma/bin/pleroma", "start"]
# ----------- #
# local image #
# ----------- #
ARG ELIXIR_VER
FROM elixir:${ELIXIR_VER} AS local
ARG MIX_ENV=dev
ENV MIX_ENV=${MIX_ENV}
SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  <<EOF
apt-get update && apt-get  -y
apt-get install -y --no-install-recommends \
  build-essential cmake libmagic-dev libimage-exiftool-perl \
  sudo man vim dnsutils net-tools \
  postgresql-13 ffmpeg locales
rm -rf /var/lib/apt/lists/*_*
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen
locale-gen
EOF

ENV WORK=/pleroma
WORKDIR ${WORK}

# ENV DATA=/var/lib/pleroma
# ARG USER=pleroma
# RUN useradd -d ${WORK} -s /bin/bash -G sudo ${USER} \
#   && mkdir -p /etc/pleroma && chown -R ${USER}:${USER} /etc/pleroma \
#   && mkdir -p ${DATA}/uploads ${DATA}/static && chown -R ${USER}:${USER} ${DATA}

# USER ${USER}
# COPY --chown=${USER} ./app ${WORK}
# COPY --chown=${USER} ./config/ ${WORK}/config/
COPY ./app ${WORK}
COPY ./config/ ${WORK}/config/
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only ${MIX_ENV} \
  && mix deps.compile --force && mix compile

CMD ["/bin/bash"]
