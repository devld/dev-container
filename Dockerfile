FROM debian

RUN apt-get update && apt-get install -y ca-certificates && \
    echo "deb [trusted=yes] https://apt.fury.io/versionfox/ /" | tee /etc/apt/sources.list.d/versionfox.list && \
    apt-get update && \
    apt-get install -y vfox git curl vim build-essential coreutils

RUN useradd -m -s /bin/bash dev
WORKDIR /home/dev

ARG APT_PACKAGES=""
RUN if [ -n "$APT_PACKAGES" ]; then \
        apt-get install -y $APT_PACKAGES; \
    fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER dev

RUN echo 'eval "$(vfox activate bash)"' >> ~/.bashrc && \
    echo 'LC_ALL=C.UTF-8' >> ~/.bashrc

ARG TOOLS=""
RUN bash -c ' \
        set -e; \
        if [ -z "$TOOLS" ]; then \
            exit 0; \
        fi; \
        uniq_tools=$(echo "$TOOLS" | sed "s/@[0-9.]*//g" | tr " " "\\n" | sort -u | tr "\\n" " "); \
        vfox add $uniq_tools; \
        for tool in $TOOLS; do \
            vfox install $tool; \
            vfox use -g $tool; \
        done \
    '
