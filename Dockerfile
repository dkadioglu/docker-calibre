FROM ghcr.io/linuxserver/baseimage-rdesktop-web:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CALIBRE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  CUSTOM_PORT="8080" \
  GUIAUTOSTART="true" \
  HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dbus \
    fcitx-rime \
    fonts-wqy-microhei \
    jq \
    libnss3 \
    libopengl0 \
    libqpdf28 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    poppler-utils \
    python3 \
    python3-xdg \
    ttf-wqy-zenhei \
    wget \
    xz-utils && \
  apt-get install -y \
    speech-dispatcher && \
  echo "**** install calibre ****" && \
  mkdir -p \
    /opt/calibre && \
  if [ -z ${CALIBRE_RELEASE+x} ]; then \
    CALIBRE_RELEASE=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" \
    | jq -r .tag_name); \
  fi && \
  CALIBRE_VERSION="$(echo ${CALIBRE_RELEASE} | cut -c2-)" && \
  CALIBRE_URL="https://download.calibre-ebook.com/${CALIBRE_VERSION}/calibre-${CALIBRE_VERSION}-x86_64.txz" && \
  curl -o \
    /tmp/calibre-tarball.txz -L \
    "$CALIBRE_URL" && \
  tar xvf /tmp/calibre-tarball.txz -C \
    /opt/calibre && \
  /opt/calibre/calibre_postinstall && \
  dbus-uuidgen > /etc/machine-id && \
  sed -i 's|</applications>|  <application title="calibre" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml && \
  echo "**** grab websocat ****" && \
  WEBSOCAT_RELEASE=$(curl -sX GET "https://api.github.com/repos/vi/websocat/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  curl -o \
    /usr/bin/websocat -fL \
    "https://github.com/vi/websocat/releases/download/${WEBSOCAT_RELEASE}/websocat.x86_64-unknown-linux-musl" && \
  chmod +x /usr/bin/websocat && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /
