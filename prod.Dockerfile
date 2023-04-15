FROM tethysplatform/tethys-core:latest as base


#########################
# ADD APPLICATION FILES #
#########################
COPY Water-Data-Explorer ${TETHYS_HOME}/apps/Water-Data-Explorer
COPY tethysapp-metdataexplorer ${TETHYS_HOME}/apps/tethysapp-metdataexplorer
COPY tethysapp-tethys_app_store ${TETHYS_HOME}/apps/tethysapp-tethys_app_store
COPY ggst ${TETHYS_HOME}/apps/ggst

###################
# ADD THEME FILES #
###################
ADD  tethysext-ciroh_theme/tethysext ${TETHYS_HOME}/extensions/tethysext-ciroh_theme/tethysext
ADD  tethysext-ciroh_theme/*.py ${TETHYS_HOME}/extensions/tethysext-ciroh_theme/

# Activate tethys conda environment during build
ARG MAMBA_DOCKERFILE_ACTIVATE=1

#######################################
# INSTALL EXTENSIONS and APPLICATIONS #
#######################################
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache \
    && echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/no-check-valid \
    && apt-get update -qq && apt-get -yqq install gcc libgdal-dev g++ libhdf5-dev > /dev/null \
    && mkdir -p $HOME/.config/pip && echo "[global]\nquiet = True" > $HOME/.config/pip/pip.conf \
    && cd ${TETHYS_HOME}/extensions/tethysext-ciroh_theme && python setup.py install \
    && cd ${TETHYS_HOME}/apps/Water-Data-Explorer && tethys install -N \
    && cd ${TETHYS_HOME}/apps/tethysapp-tethys_app_store && tethys install -N \
    && cd ${TETHYS_HOME}/apps/ggst && tethys install -N \
    && cd ${TETHYS_HOME}/apps/tethysapp-metdataexplorer && tethys install -N \
    && pip install ncarrays \
    && rm -rf ${TETHYS_HOME}/extensions/* \
    && rm -rf ${TETHYS_HOME}/apps/* && \
    micromamba clean --all --yes && \
    rm -rf /var/lib/apt/lists/* && \
    find -name '*.a' -delete && \
    rm -rf /env/conda-meta && \
    rm -rf /env/include && \
    rm ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/libpython3.10.so.1.0 && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+' && \
    rm -rf ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/pip ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/idlelib ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/ensurepip \
    ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/libasan.so.5.0.0 \
    ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/libtsan.so.0.0.0 \
    ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/liblsan.so.0.0.0 \
    ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/libubsan.so.1.0.0 \
    ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/bin/x86_64-conda-linux-gnu-ld \
    ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/bin/sqlite3 \
    ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/bin/openssl \
    ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/share/terminfo && \
    find ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/scipy -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/numpy -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/pandas -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages -name '*.pyx' -delete && \
    rm -rf ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/uvloop/loop.c && \
    chmod -R www:www /opt/conda/envs/tethys


###########################
# RUN SUPERVISORD AS ROOT #
###########################
COPY config/tethys/asgi_supervisord.conf /var/lib/tethys_persist/asgi_supervisord.conf
COPY config/tethys/supervisord.conf /etc/supervisor/supervisord.conf
COPY tmp_app_store_files/stores.json /opt/conda/envs/tethys/lib/python3.10/site-packages/tethysapp/app_store/workspaces/app_workspace/stores.json
COPY tmp_app_store_files/conda_install.sh /opt/conda/envs/tethys/lib/python3.10/site-packages/tethysapp/app_store/scripts/conda_install.sh
COPY salt/ /srv/salt/
#########
# PORTS #
#########
EXPOSE 80

#######
# RUN #
#######
CMD bash run.sh