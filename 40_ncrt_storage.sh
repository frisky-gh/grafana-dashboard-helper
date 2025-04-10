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
	local host=$1 measure=$2 diskname=$3

cat <<EOF
[
  #### NCRT Disk
  ####
  {
    "id": 1,
    "title": "Disk \"$diskname\" in $host",
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
			"unit": "decmbytes",
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
			"query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter( fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains(value: r._field, set: [\"disk[$diskname]-total\", \"disk[$diskname]-avail\", \"disk[$diskname]-used\"]) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
			"refId": "A"
		  },
		  {
			"datasource": {
			  "type": "$GRAFANADATASOURCE"
			},
			"query": "from(bucket: \"$PLUGIN_NCRT_OPTIONALBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter( fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains(value: r._field, set: [\"disk[$diskname]-total\", \"disk[$diskname]-avail\", \"disk[$diskname]-used\"]) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
			"refId": "B"
		  }
		],
		"title": "Disk \"$diskname\" Volume in $host",
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
			"unit": "sishort",
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
			"query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"disk[$diskname]-itotal\", \"disk[$diskname]-iavail\", \"disk[$diskname]-iused\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
			"refId": "A"
		  },
		  {
			"datasource": {
			  "type": "$GRAFANADATASOURCE"
			},
			"query": "from(bucket: \"$PLUGIN_NCRT_OPTIONALBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"disk[$diskname]-itotal\", \"disk[$diskname]-iavail\", \"disk[$diskname]-iused\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
			"refId": "B"
		  }
		],
		"title": "Disk \"$diskname\" i-Nodes in $host",
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
			disk\[*\]-total ) ;;
			disk\[*\]-used ) ;;
			disk\[*\]-avail ) ;;
			disk\[*\]-avail-pct ) ;;
			disk\[*\]-itotal ) ;;
			disk\[*\]-iused ) ;;
			disk\[*\]-iavail ) ;;
			disk\[*\]-iavail-pct ) ;;
			* ) continue ;;
		esac
		diskname="${fieldkey#*disk\[}"
		diskname="${diskname%\]-*}"
		diskname_writable="${diskname//\//%2F}"

		f=$OUTPUT_DIR/$host,$measure/40_disk_$diskname_writable
		test -f $f.json && continue
		mkdir -p $OUTPUT_DIR/$host,$measure
		generatePanel "$host" "$measure" "$diskname" > $f.json
		for i in total used avail avail-pct itotal iused iavail iavail-pct ; do
			echo "$series disk[$diskname]-$i"
		done	> $f.fieldkeys
		echo "40_ncrt_storage.sh" > $f.pluginname

	done < $INPUT_DIR/$series
done


