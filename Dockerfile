# syntax=docker/dockerfile:1.4
FROM ghcr.io/synocommunity/spksrc

RUN sh -e <<EOT
	apt-get update
	apt-get install -y gpg help2man libtool-bin python3-dev
	rm -rf /var/lib/apt/lists/*
EOT

COPY --chown=user:user . /home/user/ctng

USER user
WORKDIR /home/user/ctng

ARG CT_NG_PREFIX

RUN make CT_NG_PREFIX="${CT_NG_PREFIX}"
