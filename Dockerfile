# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////// #

ARG PYTHON_VERSION=3.11

FROM python:${PYTHON_VERSION}-bookworm

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////// #

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////// #

WORKDIR /usr/src/app

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////// #

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry python && \
  cd /usr/local/bin && \
  ln -s /opt/poetry/bin/poetry && \
  poetry config virtualenvs.create false

# Copy using poetry.lock* in case it doesn't exist yet
COPY ./pyproject.toml ./poetry.lock* /usr/src/app/

# Allow installing dev dependencies to run tests
ARG INSTALL_DEV=false
ARG ASTROPY_VERSION="7.0.0"

# Optionally "inject" the matrix version of astropy:
# This modifies pyproject.toml/poetry.lock so that Poetry can pick up that version.
RUN if [ -n "$ASTROPY_VERSION" ]; then \
  poetry add --lock "astropy==$ASTROPY_VERSION.*"; \
  fi

# Install dependencies (with or without dev)
RUN bash -c "\
  if [ \"$INSTALL_DEV\" == 'true' ] ; then \
  poetry install --no-root --without docs; \
  else \
  poetry install --no-root --no-dev --without docs; \
  fi \
  "

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////// #

COPY . /usr/src/app

# Set the PYTHONPATH environment variable:
ENV PYTHONPATH=/usr/src/app

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////// #