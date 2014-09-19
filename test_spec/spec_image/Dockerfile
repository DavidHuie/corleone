FROM phusion/passenger-ruby21
MAINTAINER David Huie <dahuie@gmail.com>

RUN mkdir /install
ADD runner.sh /install/runner.sh
CMD ["ls"]
ENTRYPOINT ["/install/runner.sh"]
