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
if [ "$PLUGIN_NCRT_OPTIONALBUCKET" = "" ] ; then
	echo "environment: PLUGIN_NCRT_OPTIONALBUCKET: not defined."
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
#### NCRT Agent Error
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
        "fillOpacity":       20,
        "gradientMode":      "opacity",
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
  "gridPos": { "h": 4, "w": 24, "x": 0, "y": 0 },
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
      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and r._field == \"$fieldkey\" ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
      "refId": "A"
    },
    {
      "datasource": {
        "type": "$GRAFANADATASOURCE"
      },
      "query": "from(bucket: \"$PLUGIN_NCRT_OPTIONALBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and r._field == \"$fieldkey\" ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
      "refId": "B"
    }
  ],
  "title": "Error Status of Agent on $agentname",
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
		case "$fieldkey" in
			ncrtagent\[*\]-error ) ;;
			* ) continue ;;
		esac
		agentname="${fieldkey%\]-*}"
		agentname="${agentname#ncrtagent\[}"
		agentname_writable="${agentnamey//\//%2F}"

		f=$OUTPUT_DIR/$host,$measure/90_agenterror_$agentname_writable
		mkdir -p $OUTPUT_DIR/$host,$measure
		generatePanel "$host" "$measure" "$fieldkey" "$agentname"	> $f.json
		echo "$series $fieldkey"			> $f.fieldkeys
		echo "40_ncrt_agenterror.sh"			> $f.pluginname

	done < $INPUT_DIR/$series
done


