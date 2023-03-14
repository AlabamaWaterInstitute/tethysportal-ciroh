

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


#########################
# ADD APPLICATION FILES #
#########################

COPY Water-Data-Explorer ${TETHYS_HOME}/apps/Water-Data-Explorer




###################
# ADD THEME FILES #
###################
ADD  tethysext-ciroh_theme/tethysext ${TETHYS_HOME}/extensions/tethysext-erdc_theme/tethysext
ADD  tethysext-ciroh_theme/*.py ${TETHYS_HOME}/extensions/tethysext-erdc_theme/


########################
# INSTALL APPLICATIONS #
########################
# Activate tethys conda environment during build
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Water Data Explorer Application
RUN cd ${TETHYS_HOME}/apps/Water-Data-Explorer && \
    tethys install -N


######################
# INSTALL EXTENSIONS #
######################

RUN cd ${TETHYS_HOME}/extensions/tethysext-ciroh_theme && \
    tethys install -N


#########
# CHOWN #
#########
RUN export NGINX_USER=$(grep 'user .*;' /etc/nginx/nginx.conf | awk '{print $2}' | awk -F';' '{print $1}') \
  ; sed -i "/^\[supervisord\]$/a user=${NGINX_USER}" /etc/supervisor/supervisord.conf \
  ; mkdir /var/log/tethys \
  ; chown -R ${NGINX_USER}: /run /var/log/supervisor /var/log/nginx /var/log/tethys /var/lib/nginx \
  ; find ${TETHYS_APPS_ROOT} ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {} \
  ; find ${WORKSPACE_ROOT} ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {} \
  ; find ${STATIC_ROOT} ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {} \
  ; find ${TETHYS_PERSIST}/keys ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {} \
  ; find ${TETHYS_HOME}/tethys ! -user ${NGINX_USER} -print0 | xargs -0 -I{} chown ${NGINX_USER}: {}


##################
# ADD SALT FILES #
##################
COPY salt/ /srv/salt/

#########
# PORTS #
#########
EXPOSE 8080

#######
# RUN #
#######
WORKDIR ${TETHYS_HOME}
CMD bash run.sh