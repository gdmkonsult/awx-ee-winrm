ARG BASE_IMAGE=ghcr.io/gdmkonsult/awx-ee:new
FROM ${BASE_IMAGE}

USER root

COPY sitecustomize.py /usr/local/lib/python3.12/site-packages/sitecustomize.py

USER 1000
