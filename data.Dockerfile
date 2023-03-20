FROM python:alpine3.17

# WORKDIR /usr/src/app

ADD scripts/ ./scripts/

RUN ls && pwd
RUN pip install gdown


# ggst data
RUN mkdir -p ggst
RUN cd ggst && mkdir -p ggst_thredds_directory
RUN cd ggst && mkdir -p global_output_directory


CMD [ "python", "scripts/thredds_download.py","ggst/ggst_thredds_directory/"]



