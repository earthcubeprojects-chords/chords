FROM grafana/grafana:5.0.1
MAINTAINER martinc@ucar.edu

ENV GF_INSTALL_PLUGINS=\
grafana-clock-panel,\
grafana-worldmap-panel,\
grafana-piechart-panel,\
satellogic-3d-globe-panel,\
ryantxu-ajax-panel,\
neocat-cal-heatmap-panel,\
petrslavotinek-carpetplot-panel,\
digrich-bubblechart-panel,\
briangann-gauge-panel,\
jdbranham-diagram-panel,\
mtanda-histogram-panel,\
bessler-pictureit-panel,\
natel-plotly-panel,\
btplc-status-dot-panel

ENTRYPOINT ["/run.sh"]
