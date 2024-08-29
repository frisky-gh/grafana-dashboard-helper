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
	local host=$1 measure=$2 fieldkey=$3
	local tags_cond=
	local i=
	for i in $tags ; do
		local tagname=${i%%=*}
		local tagvalue=${i##=*}
		tags_cond=" and r.$tagname == \\\"$tagvalue\\\""
	done

cat <<EOF
[
#### NCRT Generic
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
        "gradientMode":      "opacity",
        "spanNulls":         false,
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
  "id": null,
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
        "type": "$GRAFANADATASOURCE"
      },
      "query": "import \"regexp\"\nt1=from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and r._field == \"$fieldkey\" |> aggregateWindow(every: v.windowPeriod, fn: mean) )\nt2=from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and regexp.replaceAllString(r: /\.[-a-zA-Z]+$/, v: r._field, t: \"\") == \"$fieldkey\" |> aggregateWindow(every: v.windowPeriod, fn: mean) )\nunion(tables: [t1, t2])",
      "refId": "A"
    }
  ],
  "title": "$fieldkey in $host (Generic)",
  "type": "timeseries"
}
]
EOF
}

ls $INPUT_DIR |
while read series ; do
	test "${series##ncrt_*,host=*}" = "" || continue

	measure="${series%%,*}"
	measure="${measure#ncrt_}"
	host="${series##*,host=}"

	while read fieldkey ; do
		fieldkey_writable="${fieldkey//\//%2F}"

		f=$OUTPUT_DIR/$host,$measure/60_$fieldkey_writable
		mkdir -p $OUTPUT_DIR/$host,$measure
		generatePanel "$host" "$measure" "$fieldkey"	> $f.json
		echo "$series $fieldkey"			> $f.fieldkeys

	done < $INPUT_DIR/$series
done


