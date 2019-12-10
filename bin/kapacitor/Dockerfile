FROM kapacitor:1.3 

# Update
RUN apt-get update 

WORKDIR /

COPY ./kapacitor_start.sh kapacitor_start.sh

# Start kapacitor
CMD ["/bin/bash", "-f", "kapacitor_start.sh"]
