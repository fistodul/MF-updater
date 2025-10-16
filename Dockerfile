ARG OS_VERSION=13 MODE="standalone"

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
      --output-filename=updater-linux-x64.bin \
      updater.py && \
      [ -f *.bin  ] && mkdir out && \
      mv *.bin out/ || mv *.dist out

FROM gcr.io/distroless/cc-debian${OS_VERSION}:latest

COPY --from=build out/* /opt/

ENTRYPOINT ["/opt/updater-linux-x64.bin"]
