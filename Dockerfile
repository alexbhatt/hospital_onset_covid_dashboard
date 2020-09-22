FROM docker.io/rocker/r-base:4.0.2

RUN set -ex; \
	apt-get -q update; \
	DEBIAN_FRONTEND=noninteractive \
		apt-get install -q -y --no-install-recommends \
		libcurl4-openssl-dev \
		libssl-dev \
		python3-minimal \
	; \
	find /var/lib/apt/lists -type f -delete;

USER docker

RUN Rscript \
	-e "install.packages('renv', repos = c(CRAN='https://cloud.r-project.org'))"

WORKDIR /project

COPY cgroup-limits renv.lock .

RUN ["/bin/bash", "-c", "set -ex; limit_vars=$(python3 cgroup-limits); declare $limit_vars; MAKEFLAGS=-j${NUMBER_OF_CORES:-1} Rscript -e 'options(renv.consent = TRUE, renv.settings.use.cache = FALSE)' -e 'renv::restore()'; rm -rf ~/.local/share/renv; rm -rf /usr/local/lib/R/site-library/*/{help,doc,include,tinytest}; find /usr/local/lib/R -name '*.so' -exec strip --strip-unneeded {} +"]

COPY app app

EXPOSE 3838

CMD ["/usr/bin/Rscript", "-e", "shiny::runApp('app', host = '0.0.0.0', port = 3838)"]

# A numeric UID tells OpenShift that this container image doesn't require a
# privileged Security Context Constraint in order to run.
USER 1001
