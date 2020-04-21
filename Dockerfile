FROM python:3.8-buster

LABEL "com.github.actions.name"="clang-format C Check"
LABEL "com.github.actions.description"="Run clang-format style check for Protobufs"
LABEL "com.github.actions.icon"="check-circle"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/adammartinai/github-action-clang-format.git"
LABEL "homepage"="https://github.com/adammartinai/github-action-clang-format"
LABEL "maintainer"="Adam Clark <adam@martin.ai>"

RUN pip install --upgrade pip
RUN pip install clang-format
RUN apt-get -qq -y install curl jq


COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]