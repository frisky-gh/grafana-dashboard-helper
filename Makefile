APPNAME=grafana-dashboard-helper

all:	build

build:
	pod2man ${APPNAME}.pod | gzip > ${APPNAME}.1.gz
	pod2man --section 5 ${APPNAME}.conf.pod | gzip > ${APPNAME}.conf.5.gz
	pod2man --section 5 ${APPNAME}.namemaprules.pod | gzip > ${APPNAME}.namemaprules.5.gz
	pod2man --section 5 ${APPNAME}.templaterules.pod | gzip > ${APPNAME}.templaterules.5.gz


