FROM busybox 
COPY . / 
ENTRYPOINT ["/bin/sh"]
CMD ["/bin/start.sh"]
