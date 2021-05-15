FROM --platform=$BUILDPLATFORM python:3.8 as builder

WORKDIR /install

COPY requirements.txt /requirements.txt

RUN apt-get update && apt-get install -y curl && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . /root/.cargo/env && \
    rustup toolchain install 1.41.0 && \
    pip install --prefix=/install -r /requirements.txt

FROM python:3.8-slim

WORKDIR /app

COPY --from=builder /install /usr/local
COPY . .

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

COPY launcher /launcher.sh
RUN chmod +x /launcher.sh

CMD ["/launcher.sh"]
