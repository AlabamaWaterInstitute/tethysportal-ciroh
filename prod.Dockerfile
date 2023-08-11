FROM gioelkin/tethys:dev as base


#########################
# ADD APPLICATION FILES #
#########################
COPY Water-Data-Explorer ${TETHYS_HOME}/apps/Water-Data-Explorer
COPY tethysapp-metdataexplorer ${TETHYS_HOME}/apps/tethysapp-metdataexplorer
COPY tethysapp-tethys_app_store ${TETHYS_HOME}/apps/tethysapp-tethys_app_store
COPY ggst ${TETHYS_HOME}/apps/ggst
COPY gwdm ${TETHYS_HOME}/apps/gwdm
COPY tethysapp-swe ${TETHYS_HOME}/apps/tethysapp-swe
COPY tethysapp-hydrocompute ${TETHYS_HOME}/apps/tethysapp-hydrocompute
COPY snow-inspector ${TETHYS_HOME}/apps/snow-inspector

COPY piprequirements.txt .
COPY config/tethys/tmp_app_store_files/conda_install.sh ${TETHYS_HOME}

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
    micromamba install --yes -c conda-forge geoserver-rest && \
    conda install --yes -c conda-forge udunits2 && \
    # micromamba install --yes -c conda-forge --file requirements.txt --> problem installing with microbamba, but pip is working well but unstable
    export PYTHON_SITE_PACKAGE_PATH=$(${CONDA_HOME}/envs/${CONDA_ENV_NAME}/bin/python -m site | grep -a -m 1 "site-packages" | head -1 | sed 's/.$//' | sed -e 's/^\s*//' -e '/^$/d'| sed 's![^/]*$!!' | cut -c2-) &&\
    cd ${TETHYS_HOME}/extensions/tethysext-ciroh_theme && python setup.py install && \
    cd ${TETHYS_HOME}/apps/Water-Data-Explorer && tethys install -w -N -q && cp install.yml $PYTHON_SITE_PACKAGE_PATH/site-packages/water_data_explorer.yml && \
    cd ${TETHYS_HOME}/apps/tethysapp-tethys_app_store && tethys install -w -N -q && cp install.yml $PYTHON_SITE_PACKAGE_PATH/site-packages/app_store.yml && \
    cd ${TETHYS_HOME}/apps/ggst && tethys install -w -N -q && cp install.yml $PYTHON_SITE_PACKAGE_PATH/site-packages/ggst.yml && \
    cd ${TETHYS_HOME}/apps/tethysapp-metdataexplorer && tethys install -w -N -q && cp install.yml $PYTHON_SITE_PACKAGE_PATH/site-packages/metdataexplorer.yml && \
    cd ${TETHYS_HOME}/apps/tethysapp-swe && tethys install -w -N -q && cp install.yml $PYTHON_SITE_PACKAGE_PATH/site-packages/swe.yml && \
    cd ${TETHYS_HOME}/apps/tethysapp-hydrocompute && tethys install -w -N -q && cp install.yml $PYTHON_SITE_PACKAGE_PATH/site-packages/hydrocompute.yml && \
    cd ${TETHYS_HOME}/apps/gwdm && tethys install -w -N -q && cp install.yml $PYTHON_SITE_PACKAGE_PATH/site-packages/gwdm.yml && \
    cd ${TETHYS_HOME}/apps/snow-inspector && tethys install -w -N -q && cp install.yml $PYTHON_SITE_PACKAGE_PATH/site-packages/snow-inspector.yml && \

    rm -rf ${TETHYS_HOME}/extensions/* && \
    rm -rf ${TETHYS_HOME}/apps/* && \
    micromamba clean --all --yes && \ 
    conda clean --all --yes && \
    rm -rf /var/lib/apt/lists/* && \
    find -name '*.a' -delete && \
    mv -f ${TETHYS_HOME}/conda_install.sh $PYTHON_SITE_PACKAGE_PATH/site-packages/tethysapp/app_store/scripts/conda_install.sh &&\
    rm -rf ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/conda-meta && \
    rm -rf ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/include && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+' && \
    rm -rf $PYTHON_SITE_PACKAGE_PATH/site-packages/pip $PYTHON_SITE_PACKAGE_PATH/idlelib $PYTHON_SITE_PACKAGE_PATH/ensurepip && \
    find $PYTHON_SITE_PACKAGE_PATH/site-packages/scipy -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find $PYTHON_SITE_PACKAGE_PATH/site-packages/numpy -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find $PYTHON_SITE_PACKAGE_PATH/site-packages/pandas -name 'tests' -type d -exec rm -rf '{}' '+' && \
    find $PYTHON_SITE_PACKAGE_PATH/site-packages -name '*.pyx' -delete && \
    rm -rf $PYTHON_SITE_PACKAGE_PATH/uvloop/loop.c

FROM gioelkin/tethys:dev as build
###########################
# RUN SUPERVISORD AS ROOT #
###########################
COPY --chown=www:www --from=base ${CONDA_HOME}/envs/${CONDA_ENV_NAME} ${CONDA_HOME}/envs/${CONDA_ENV_NAME}
COPY config/tethys/asgi_supervisord.conf ${TETHYS_PERSIST}/asgi_supervisord.conf
COPY config/tethys/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/tethys/update_tethys_apps.py ${TETHYS_HOME}
COPY config/tethys/update_proxy_apps.py ${TETHYS_HOME}
COPY config/tethys/update_state.sh ${TETHYS_HOME}
COPY config/tethys/gwdm/post_setup_gwdm.py ${TETHYS_HOME}

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