#!/bin/bash

if [ $# -lt 2 ] ; then
	echo "usage: % $0 INPUT_DIR OUTPUT_DIR"
	exit 1
fi

INPUT_DIR=$1
OUTPUT_DIR=$2

if [ "$GRAFANADATASOURCE" = "" ] ; then
	echo "environment: GRAFANADATASOURCE: not defined."
	exit 2
fi
if [ "$INFLUXDBBUCKET" = "" ] ; then
	echo "environment: INFLUXDBBUCKET: not defined."
	exit 2
fi

####

function generatePanel {
	local series=$1 measurement=$2 tags=$3 fieldkey=$4
	local tags_cond=
	local i=
	for i in $tags ; do
		local tagname=${i%%=*}
		local tagvalue=${i##=*}
		tags_cond=" and r.$tagname == \\\"$tagvalue\\\""
	done

cat <<EOF
[
#### Generic
####
{
  "datasource": {
    "type": "$GRAFANADATASOURCE"
  },
  "fieldConfig": {
    "defaults": {
      "custom": {
        "drawStyle":         "line",
        "lineInterpolation": "linear",
        "barAlignment":      0,
        "lineWidth":         1,
        "fillOpacity":       0,
        "gradientMode":      "none",
        "spanNulls":         3600000,
        "insertNulls":       false,
        "showPoints":        "auto",
        "pointSize": 5,
        "stacking": { "mode": "none", "group": "A" },
        "axisPlacement":    "auto",
        "axisLabel":        "",
        "axisColorMode":    "text",
        "axisBorderShow":   false,
        "scaleDistribution": { "type": "linear" },
        "axisCenteredZero": false,
        "hideFrom":        { "tooltip": false, "viz": false, "legend": false },
        "thresholdsStyle": { "mode": "off" }
      },
      "color": { "mode": "palette-classic" },
      "mappings": [],
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "red",
            "value": 80
          }
        ]
      }
    },
    "overrides": []
  },
  "gridPos": {
    "h": 8,
    "w": 24,
    "x": 0,
    "y": 0
  },
  "id": 1,
  "options": {
    "tooltip": {
      "mode": "single",
      "sort": "none"
    },
    "legend": {
      "showLegend": true,
      "displayMode": "list",
      "placement": "bottom",
      "calcs": []
    }
  },
  "targets": [
    {
      "datasource": {
        "type": "$GRAFANADATASOURCE",
      },
      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r._measurement == \"$measurement\" $tags_cond and r._field == \"$fieldkey\" ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
      "refId": "A"
    }
  ],
  "title": "New Panel",
  "type": "timeseries"
}
]
EOF
}

ls $INPUT_DIR |
while read series ; do

	measurement="${series%%,*}"
	if [ "$series" == "$measurement" ] ; then
		tags=
	else
		tags="${series#*,}"
		tags="${tags//,/ }"
	fi

	while read fieldkey ; do
		fieldkey_writable="${fieldkey//\//%2F}"
		mkdir $OUTPUT_DIR/$series
		f="$OUTPUT_DIR/$series/90_$fieldkey_writable"
		generatePanel "$series" "$measurement" "$tags" "$fieldkey"	> $f.json
		echo "$series $fieldkey"					> $f.fieldkeys
		echo "90_generic.sh" > $f.pluginname
	done < $INPUT_DIR/$series
done


