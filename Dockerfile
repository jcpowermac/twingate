#FROM quay.io/app-sre/ubi8-ubi:latest
FROM mcr.microsoft.com/powershell:ubi-9

COPY run.ps1 run.sh network-check.sh /

RUN curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | tar -C /bin -xvzf - govc

RUN export POWERSHELL_TELEMETRY_OPTOUT=1 && \
	pwsh -NoLogo -NoProfile -Command " \
          \$ErrorActionPreference = 'Stop' ; \
          \$ProgressPreference = 'SilentlyContinue' ; \
          Set-PSRepository -Name PSGallery -InstallationPolicy Trusted ; \
          Install-Module -Force -Scope AllUsers PSSlack ; \
          Install-Module -Scope AllUsers VMware.PowerCLI ; \
          Set-PowerCLIConfiguration -Scope AllUsers -ParticipateInCeip:\$false -Confirm:\$false"

RUN dnf upgrade --refresh -y && \
    curl https://binaries.twingate.com/client/linux/install.sh | bash && \
    dnf install iproute iputils -y

ENTRYPOINT ["/run.ps1"]
