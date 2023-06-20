FROM quay.io/centos/centos:stream9

COPY run.sh network-check.sh /

RUN dnf upgrade --refresh -y && \
    curl https://binaries.twingate.com/client/linux/install.sh | bash && \
    dnf install iproute iputils -y

#ENTRYPOINT [ "twingate", "start" ]
#CMD ["tail", "-f", "/dev/null"]

ENTRYPOINT ["/run.sh"]
