ARG OS_VERSION=12 MODE="accelerated"

FROM debian:${OS_VERSION}-slim AS build
ENV DEBIAN_FRONTEND=noninteractive
ARG MODE

COPY updater.py .

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      ccache \
      gcc \
      make \
      patchelf \
      pipx \
      python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pipx run nuitka \
      --mode=${MODE} \
      --deployment \
      --assume-yes-for-downloads \
      --python-flag=-OO \
      --output-filename=updater-linux-amd64.bin \
      updater.py

FROM gcr.io/distroless/python3-debian${OS_VERSION}:latest

COPY --from=build updater-linux-amd64.bin /opt/

ENTRYPOINT ["/opt/updater-linux-amd64.bin"]
