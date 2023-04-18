FROM tethysplatform/tethys-core:latest as base


#########################
# ADD APPLICATION FILES #
#########################
COPY Water-Data-Explorer ${TETHYS_HOME}/apps/Water-Data-Explorer
COPY tethysapp-metdataexplorer ${TETHYS_HOME}/apps/tethysapp-metdataexplorer
COPY tethysapp-tethys_app_store ${TETHYS_HOME}/apps/tethysapp-tethys_app_store
COPY ggst ${TETHYS_HOME}/apps/ggst
COPY tethysapp-swe ${TETHYS_HOME}/apps/tethysapp-swe

COPY piprequirements.txt .

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
RUN pip install --no-cache-dir --quiet -r piprequirements.txt && \
    conda install --yes -c conda-forge udunits2 && \
    # micromamba install --yes -c conda-forge --file requirements.txt && \
    cd ${TETHYS_HOME}/extensions/tethysext-ciroh_theme && python setup.py install && \
    cd ${TETHYS_HOME}/apps/Water-Data-Explorer && tethys install -w -N && \
    cd ${TETHYS_HOME}/apps/tethysapp-tethys_app_store && tethys install -w -N && \
    cd ${TETHYS_HOME}/apps/ggst && tethys install -w -N && \
    cd ${TETHYS_HOME}/apps/tethysapp-metdataexplorer && tethys install -w -N  && \
    cd ${TETHYS_HOME}/apps/tethysapp-swe && tethys install -w -N  && \
    rm -rf ${TETHYS_HOME}/extensions/* && \
    rm -rf ${TETHYS_HOME}/apps/* && \
    # micromamba clean --all --yes && \
    conda clean --all --yes && \
    rm -rf /var/lib/apt/lists/* && \
    find -name '*.a' -delete && \
    rm -rf ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/conda-meta && \
    rm -rf ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/include && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+' && \
    rm -rf ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/pip ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/idlelib ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/ensurepip && \
    find ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/scipy -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/numpy -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/pandas -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages -name '*.pyx' -delete && \
    rm -rf ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/lib/python3.10/site-packages/uvloop/loop.c
FROM tethysplatform/tethys-core:latest as build
###########################
# RUN SUPERVISORD AS ROOT #
###########################
COPY --chown=www:www --from=base /opt/conda/envs/tethys /opt/conda/envs/tethys
COPY config/tethys/asgi_supervisord.conf /var/lib/tethys_persist/asgi_supervisord.conf
COPY config/tethys/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/tethys/tmp_app_store_files/stores.json /opt/conda/envs/tethys/lib/python3.10/site-packages/tethysapp/app_store/workspaces/app_workspace/stores.json
COPY config/tethys/tmp_app_store_files/conda_install.sh /opt/conda/envs/tethys/lib/python3.10/site-packages/tethysapp/app_store/scripts/conda_install.sh
COPY salt/ /srv/salt/

# Activate tethys conda environment during build
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN rm -Rf ~/.cache/pip && \
    micromamba clean --all --yes
#########
# PORTS #
#########
EXPOSE 80

#######
# RUN #
#######
CMD bash run.sh