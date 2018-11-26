FROM grafana/grafana:5.3.4
MAINTAINER martinc@ucar.edu
USER root

RUN apt-get update

ENV GF_PATHS_PLUGINS=/opt/grafana-plugins
RUN mkdir -p $GF_PATHS_PLUGINS
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install grafana-clock-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install grafana-worldmap-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install grafana-piechart-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install satellogic-3d-globe-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install ryantxu-ajax-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install neocat-cal-heatmap-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install petrslavotinek-carpetplot-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install digrich-bubblechart-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install briangann-gauge-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install jdbranham-diagram-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install mtanda-histogram-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install bessler-pictureit-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install natel-plotly-panel
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install btplc-status-dot-panel

ENTRYPOINT ["/run.sh"]
