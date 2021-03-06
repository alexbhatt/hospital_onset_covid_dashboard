FROM docker.io/rocker/r-base:4.0.3

RUN set -ex; \
	apt-get -q update; \
	DEBIAN_FRONTEND=noninteractive \
		apt-get install -q -y --no-install-recommends \
		libcurl4-openssl-dev \
		libssl-dev \
		python3-minimal \
	; \
	find /var/lib/apt/lists -type f -delete;

ADD RCACOL01-CA-3.crt /usr/local/share/ca-certificates

RUN update-ca-certificates

USER docker

RUN Rscript --verbose --vanilla \
	-e "install.packages('renv', repos = c(CRAN='https://cloud.r-project.org'))"

WORKDIR /project

COPY cgroup-limits renv.lock .

# Allows RUN scripts to use declare & brace expansion
SHELL ["/bin/bash", "-c"]

RUN set -eux; \
	declare $(python3 cgroup-limits); \
	MAKEFLAGS=-j${NUMBER_OF_CORES:-1} \
		Rscript --verbose --vanilla \
			-e 'options(renv.consent = TRUE, renv.settings.use.cache = FALSE)' -e 'renv::restore()'; \
	rm -rf ~/.local/share/renv; \
	rm -rf /usr/local/lib/R/site-library/*/{help,doc,include,tinytest}; \
	find /usr/local/lib/R -name '*.so' -exec strip --strip-unneeded {} +

# Without the chown, the files are owned by root. This seems to be a recent
# change. I'm seeing it on Debian (podman 2.1.1+dfsg1-6) and on OpenShift 4.6.12.
COPY --chown=docker:docker app app

RUN Rscript --verbose --vanilla \
	-e "sass::sass(sass::sass_file('app/styles/main.scss'), output = 'app/www/main.css')"

EXPOSE 3838

CMD ["/usr/bin/Rscript", "--verbose", "--vanilla", "-e", "shiny::runApp('app', host = '0.0.0.0', port = 3838)"]

# A numeric UID tells OpenShift that this container image doesn't require a
# privileged Security Context Constraint in order to run.
USER 1001
