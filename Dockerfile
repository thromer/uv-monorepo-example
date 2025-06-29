# We use the same image as the runtime base image so that Python
# version and location matches.
FROM us-west1-docker.pkg.dev/serverless-runtimes/google-22/runtimes/python312 AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

USER www-data

WORKDIR /pip

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON=/opt/python3.12/bin/python3.12

ENV UV_CACHE_DIR=/tmp/uv/cache
# ENV UV_SYSTEM_PYTHON=1
# ENV UV_PROJECT_ENVIRONMENT=/app 

COPY lib-new lib-new
COPY app-new app-new

# TODO convert to a loop
RUN uv --directory=lib-new export --format requirements.txt --no-editable --frozen | sed -e 's@^\.@# Elided: .@' > /tmp/lib-new-constraints.txt && \
    RUN uv --directory=lib-new build -b /tmp/lib-new-constraints.txt -o /tmp/dist --wheel
RUN uv --directory=app-new export --format requirements.txt --no-editable --frozen | sed -e 's@^\.@# Elided: .@' > /tmp/app-new-constraints.txt && \
    RUN uv --directory=app-new build -b /tmp/app-new-constraints.txt -o /tmp/dist --wheel

RUN pip install --no-cache-dir --prefix=python-packages /tmp/dist/*.whl && \
    PYTHONPATH=python-packages/lib/python3.12/site-packages python -m pip freeze

# Run
FROM scratch
COPY --from=builder /pip/python-packages /opt/python

ENV PYTHONPATH=/opt/python/lib/python3.12/site-packages
ENV PATH=/opt/python/bin:$PATH

CMD ["app-new"]
