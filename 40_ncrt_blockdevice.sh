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
	local host=$1 measure=$2 devicename=$3

cat <<EOF
[
  #### NCRT Disk
  ####
  {
    "id": 1,
    "title": "Block Device \"$devicename\" in $host",
    "type": "row",
    "gridPos": { "h": 1, "w": 24, "x": 0, "y": 0 },
    "panels": [
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
				{ "color": "green", "value": null },
				{ "color": "red", "value": 80 }
			  ]
			},
			"unit": "opm",
			"min": 0
		  },
		  "overrides": []
		},
		"gridPos": {
		  "h": 8,
		  "w": 12,
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
			  "type": "$GRAFANADATASOURCE"
			},
			"query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter( fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains(value: r._field, set: [\"dev[$devicename]-read-tpm\", \"dev[$devicename]-write-tpm\", \"longtermavg-of-dev[$devicename]-read-times\", \"longtermavg-of-dev[$devicename]-write-times\"]) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
			"refId": "A"
		  },
		  {
			"datasource": {
			  "type": "$GRAFANADATASOURCE"
			},
			"query": "from(bucket: \"$PLUGIN_NCRT_OPTIONALBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter( fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains(value: r._field, set: [\"dev[$devicename]-read-tpm\", \"dev[$devicename]-write-tpm\", \"longtermavg-of-dev[$devicename]-read-times\", \"longtermavg-of-dev[$devicename]-write-times\"]) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
			"refId": "B"
		  }
		],
		"title": "Block Device \"$devicename\" I/O Transaction in $host",
		"type": "timeseries"
	  },
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
				{ "color": "green", "value": null },
				{ "color": "red", "value": 80 }
			  ]
			},
			"unit": "recpm",
			"min": 0
		  },
		  "overrides": []
		},
		"gridPos": {
		  "h": 8,
		  "w": 12,
		  "x": 12,
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
			  "type": "$GRAFANADATASOURCE"
			},
			"query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter( fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains(value: r._field, set: [\"dev[$devicename]-read-spm\", \"dev[$devicename]-write-spm\", \"longtermavg-of-dev[$devicename]-read-sectors\", \"longtermavg-of-dev[$devicename]-write-sectors\"]) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
			"refId": "A"
		  },
		  {
			"datasource": {
			  "type": "$GRAFANADATASOURCE"
			},
			"query": "from(bucket: \"$PLUGIN_NCRT_OPTIONALBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter( fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains(value: r._field, set: [\"dev[$devicename]-read-spm\", \"dev[$devicename]-write-spm\", \"longtermavg-of-dev[$devicename]-read-sectors\", \"longtermavg-of-dev[$devicename]-write-sectors\"]) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
			"refId": "B"
		  }
		],
		"title": "Block Device \"$devicename\" I/O Sectors in $host",
		"type": "timeseries"
	  }

    ],
    "collapsed": true
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
			dev\[*\]-read-tpm ) ;;
			dev\[*\]-write-tpm ) ;;
			dev\[*\]-read-spm ) ;;
			dev\[*\]-write-spm ) ;;
			longtermavg-of-dev\[*\]-read-times ) ;;
			longtermavg-of-dev\[*\]-write-times ) ;;
			longtermavg-of-dev\[*\]-read-sectors ) ;;
			longtermavg-of-dev\[*\]-write-sectors ) ;;
			* ) continue ;;
		esac
		devicename="${fieldkey#*dev\[}"
		devicename="${devicename%\]-*}"
		devicename_writable="${devicename//\//%2F}"

		f=$OUTPUT_DIR/$host,$measure/40_blockdevice_$devicename_writable
		test -f $f.json && continue
		mkdir -p $OUTPUT_DIR/$host,$measure
		generatePanel "$host" "$measure" "$devicename" > $f.json
		for i in read-spm write-spm read-tpm write-tpm ; do
			echo "$series dev[$devicename]-$i"
		done	> $f.fieldkeys
		for i in read-sectors write-sectors read-times write-times ; do
			echo "$series longtermavg-of-dev[$devicename]-$i"
		done	>> $f.fieldkeys
		echo "40_ncrt_blockdevice.sh" > $f.pluginname

	done < $INPUT_DIR/$series
done


