FROM tethysplatform/tethys-core:latest

#########
# SETUP #
#########
# Speed up APT installs
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache \
    && echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/no-check-valid
# Install APT Package
RUN apt-get update -qq && apt-get -yqq install gcc libgdal-dev g++ libhdf5-dev > /dev/null
# Quiet pip installs
RUN mkdir -p $HOME/.config/pip && echo "[global]\nquiet = True" > $HOME/.config/pip/pip.conf


###############################
# CREATE A THREDDS DIRECTRORY #
###############################
RUN mkdir -p ${TETHYS_HOME}/thredds_data
RUN mkdir -p ${TETHYS_HOME}/thredds_data/ggst
#########################
# ADD APPLICATION FILES #
#########################
ADD Water-Data-Explorer ${TETHYS_HOME}/apps/Water-Data-Explorer
COPY tethysapp-metdataexplorer ${TETHYS_HOME}/apps/tethysapp-metdataexplorer
COPY tethysapp-tethys_app_store ${TETHYS_HOME}/apps/tethysapp-tethys_app_store
COPY ggst ${TETHYS_HOME}/apps/ggst

###################
# ADD THEME FILES #
###################
ADD  tethysext-ciroh_theme/tethysext ${TETHYS_HOME}/extensions/tethysext-ciroh_theme/tethysext
ADD  tethysext-ciroh_theme/*.py ${TETHYS_HOME}/extensions/tethysext-ciroh_theme/


########################
# INSTALL APPLICATIONS #
########################
# Activate tethys conda environment during build
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Water Data Explorer Application
RUN /bin/bash -c "cd ${TETHYS_HOME}/apps/Water-Data-Explorer; tethys install -N"
# RUN cd ${TETHYS_HOME}/apps/Water-Data-Explorer && \
#     tethys install -N

# Met Data Explorer Application
RUN cd ${TETHYS_HOME}/apps/tethysapp-metdataexplorer && \
    tethys install -N

# App store Application
RUN cd ${TETHYS_HOME}/apps/tethysapp-tethys_app_store && \
    tethys install -N

# ggst store Application
RUN cd ${TETHYS_HOME}/apps/ggst && \
    tethys install -N

######################
# INSTALL EXTENSIONS #
######################

RUN cd ${TETHYS_HOME}/extensions/tethysext-ciroh_theme && \
    python setup.py install

##################
# ADD SALT FILES #
##################
COPY salt/ /srv/salt/

################################
# quick fix MDE needs ncarrays #
################################
RUN pip install ncarrays

#########
# PORTS #
#########
EXPOSE 80

##################################
# ADD THREDDS DATA SCRIPTS FILES #
##################################
RUN pip install -U --no-cache-dir gdown
ADD scripts/ ${TETHYS_HOME}/scripts/

########################################
# TEMP FILES FOR THE APP STORE TO WORK #
########################################

COPY tmp_app_store_files/stores.json /opt/conda/envs/tethys/lib/python3.10/site-packages/tethysapp/app_store/workspaces/app_workspace/stores.json
COPY tmp_app_store_files/conda_install.sh /opt/conda/envs/tethys/lib/python3.10/site-packages/tethysapp/app_store/scripts/conda_install.sh

###########################
# RUN SUPERVISORD AS ROOT #
###########################

COPY config/tethys/asgi_supervisord.conf /var/lib/tethys_persist/asgi_supervisord.conf
COPY config/tethys/supervisord.conf /etc/supervisor/supervisord.conf

####################################
# MAKE THE CONDA PACKAGES SHARABLE #
####################################

RUN chown -R www:www /opt/conda/envs/tethys/pkgs

#######
# RUN #
#######
WORKDIR ${TETHYS_HOME}
CMD bash run.sh