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
	local host=$1 measure=$2 nicname=$3
	local tags_cond=
	local i=
	for i in $tags ; do
		local tagname=${i%%=*}
		local tagvalue=${i##=*}
		tags_cond=" and r.$tagname == \\\"$tagvalue\\\""
	done

cat <<EOF
[
#### NCRT NIC
####
  {
    "id": 1,
    "title": "Network Link \"$nicname\" in $host",
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-throughput-mbps\", \"link[$nicname]-tx-throughput-mbps\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-throughput-mbps\", \"link[$nicname]-tx-throughput-mbps\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Traffic in $host",
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter( fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-throughput-mbps\", \"longtermavg-of-link[$nicname]-tx-throughput-mbps\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter( fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-throughput-mbps\", \"longtermavg-of-link[$nicname]-tx-throughput-mbps\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Traffic (Long Term Average) in $host",
	  "type": "timeseries"
	},
	#### Packet
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
	  "gridPos": {
	    "h": 8,
	    "w": 12,
	    "x": 0,
	    "y": 8
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-packets-ppm\", \"link[$nicname]-tx-packets-ppms\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-packets-ppm\", \"link[$nicname]-tx-packets-ppms\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Traffic (Packets) in $host",
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
	    "w": 12,
	    "x": 12,
	    "y": 8
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-packets-ppm\", \"longtermavg-of-link[$nicname]-tx-packets-ppms\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-packets-ppm\", \"longtermavg-of-link[$nicname]-tx-packets-ppms\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Traffic (Long Term Average) in $host",
	  "type": "timeseries"
	},
	#### Dropped
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
	  "gridPos": {
	    "h": 8,
	    "w": 12,
	    "x": 0,
	    "y": 16
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-dropped-ppm\", \"link[$nicname]-tx-dropped-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-dropped-ppm\", \"link[$nicname]-tx-dropped-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Dropped Packets in $host",
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
	    "w": 12,
	    "x": 12,
	    "y": 16
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-dropped-ppm\", \"longtermavg-of-link[$nicname]-tx-dropped-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-dropped-ppm\", \"longtermavg-of-link[$nicname]-tx-dropped-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Dropped Packets (Long Term Average) in $host",
	  "type": "timeseries"
	},
	#### Errors
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
	  "gridPos": {
	    "h": 8,
	    "w": 12,
	    "x": 0,
	    "y": 24
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-errors-ppm\", \"link[$nicname]-tx-errors-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-errors-ppm\", \"link[$nicname]-tx-errors-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Errors in $host",
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
	    "w": 12,
	    "x": 12,
	    "y": 24
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-errors-ppm\", \"longtermavg-of-link[$nicname]-tx-errors-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-errors-ppm\", \"longtermavg-of-link[$nicname]-tx-errors-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Traffic (Long Term Average) in $host",
	  "type": "timeseries"
	},
	#### Misc
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
	  "gridPos": {
	    "h": 8,
	    "w": 12,
	    "x": 0,
	    "y": 32
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-mcast-ppm\", \"link[$nicname]-tx-mcast-ppm\", \"link[$nicname]-rx-overrun-ppm\", \"link[$nicname]-tx-overrun-ppm\", \"link[$nicname]-rx-carrier-ppm\", \"link[$nicname]-tx-carrier-ppm\", \"link[$nicname]-rx-collsns-ppm\", \"link[$nicname]-tx-collsns-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"link[$nicname]-rx-mcast-ppm\", \"link[$nicname]-tx-mcast-ppm\", \"link[$nicname]-rx-overrun-ppm\", \"link[$nicname]-tx-overrun-ppm\", \"link[$nicname]-rx-carrier-ppm\", \"link[$nicname]-tx-carrier-ppm\", \"link[$nicname]-rx-collsns-ppm\", \"link[$nicname]-tx-collsns-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Misc Packets in $host",
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
	    "w": 12,
	    "x": 12,
	    "y": 32
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
	      "query": "from(bucket: \"$INFLUXDBBUCKET\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-mcast-ppm\", \"longtermavg-of-link[$nicname]-tx-mcast-ppm\", \"longtermavg-of-link[$nicname]-rx-overrun-ppm\", \"longtermavg-of-link[$nicname]-tx-overrun-ppm\", \"longtermavg-of-link[$nicname]-rx-carrier-ppm\", \"longtermavg-of-link[$nicname]-tx-carrier-ppm\", \"longtermavg-of-link[$nicname]-rx-collsns-ppm\", \"longtermavg-of-link[$nicname]-tx-collsns-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "A"
	    },
	    {
	      "datasource": {
		"type": "$GRAFANADATASOURCE"
	      },
	      "query": "from(bucket: \"ncrt_optional\") |> range(start: v.timeRangeStart, stop:v.timeRangeStop) |> filter(fn: (r) => r.host == \"$host\" and r._measurement == \"ncrt_$measure\" and contains( value: r._field, set: [\"longtermavg-of-link[$nicname]-rx-mcast-ppm\", \"longtermavg-of-link[$nicname]-tx-mcast-ppm\", \"longtermavg-of-link[$nicname]-rx-overrun-ppm\", \"longtermavg-of-link[$nicname]-tx-overrun-ppm\", \"longtermavg-of-link[$nicname]-rx-carrier-ppm\", \"longtermavg-of-link[$nicname]-tx-carrier-ppm\", \"longtermavg-of-link[$nicname]-rx-collsns-ppm\", \"longtermavg-of-link[$nicname]-tx-collsns-ppm\"] ) ) |> aggregateWindow(every: v.windowPeriod, fn: mean)",
	      "refId": "B"
	    }
	  ],
	  "title": "Network Link \"$nicname\" Misc Packets (Long Term Average) in $host",
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
			link\[*\]-tx-bytes-cnt ) ;;
			link\[*\]-tx-packets-cnt ) ;;
			link\[*\]-tx-dropped-cnt ) ;;
			link\[*\]-tx-errors-cnt ) ;;
			link\[*\]-tx-mcast-cnt ) ;;
			link\[*\]-tx-overrun-cnt ) ;;
			link\[*\]-tx-carrier-cnt ) ;;
			link\[*\]-tx-collsns-cnt ) ;;
			link\[*\]-rx-bytes-cnt ) ;;
			link\[*\]-rx-packets-cnt ) ;;
			link\[*\]-rx-dropped-cnt ) ;;
			link\[*\]-rx-errors-cnt ) ;;
			link\[*\]-rx-mcast-cnt ) ;;
			link\[*\]-rx-overrun-cnt ) ;;
			link\[*\]-rx-carrier-cnt ) ;;
			link\[*\]-rx-collsns-cnt ) ;;
			link\[*\]-tx-throughput-mbps ) ;;
			link\[*\]-rx-throughput-mbps ) ;;
			link\[*\]-tx-packets-ppm ) ;;
			link\[*\]-tx-dropped-ppm ) ;;
			link\[*\]-tx-errors-ppm ) ;;
			link\[*\]-tx-mcast-ppm ) ;;
			link\[*\]-tx-overrun-ppm ) ;;
			link\[*\]-tx-carrier-ppm ) ;;
			link\[*\]-tx-collsns-ppm ) ;;

			longtermavg-of-link\[*\]-tx-bytes-cnt ) ;;
			longtermavg-of-link\[*\]-tx-packets-cnt ) ;;
			longtermavg-of-link\[*\]-tx-dropped-cnt ) ;;
			longtermavg-of-link\[*\]-tx-errors-cnt ) ;;
			longtermavg-of-link\[*\]-tx-mcast-cnt ) ;;
			longtermavg-of-link\[*\]-tx-overrun-cnt ) ;;
			longtermavg-of-link\[*\]-tx-carrier-cnt ) ;;
			longtermavg-of-link\[*\]-tx-collsns-cnt ) ;;
			longtermavg-of-link\[*\]-rx-bytes-cnt ) ;;
			longtermavg-of-link\[*\]-rx-packets-cnt ) ;;
			longtermavg-of-link\[*\]-rx-dropped-cnt ) ;;
			longtermavg-of-link\[*\]-rx-errors-cnt ) ;;
			longtermavg-of-link\[*\]-rx-mcast-cnt ) ;;
			longtermavg-of-link\[*\]-rx-overrun-cnt ) ;;
			longtermavg-of-link\[*\]-rx-carrier-cnt ) ;;
			longtermavg-of-link\[*\]-rx-collsns-cnt ) ;;
			longtermavg-of-link\[*\]-tx-throughput-mbps ) ;;
			longtermavg-of-link\[*\]-rx-throughput-mbps ) ;;
			longtermavg-of-link\[*\]-tx-packets-ppm ) ;;
			longtermavg-of-link\[*\]-tx-dropped-ppm ) ;;
			longtermavg-of-link\[*\]-tx-errors-ppm ) ;;
			longtermavg-of-link\[*\]-tx-mcast-ppm ) ;;
			longtermavg-of-link\[*\]-tx-overrun-ppm ) ;;
			longtermavg-of-link\[*\]-tx-carrier-ppm ) ;;
			longtermavg-of-link\[*\]-tx-collsns-ppm ) ;;
			* ) continue ;;
		esac
		nicname="${fieldkey#*link\[}"
		nicname="${nicname%\]-*}"
		nicname_writable="${nicname//\//%2F}"

		f=$OUTPUT_DIR/$host,$measure/40_nic_$nicname_writable
		test -f $f.json && continue
		mkdir -p $OUTPUT_DIR/$host,$measure
		generatePanel "$host" "$measure" "$nicname" > $f.json
		for i in tx rx ; do
			for j in bytes packets dropped errors mcast overrun carrier collsns ; do
				echo "$series link[$nicname]-$i-$j-cnt"
				echo "$series longtermavg-of-link[$nicname]-$i-$j-cnt"
			done
			for j in throughput ; do
				echo "$series link[$nicname]-$i-$j-mbps"
				echo "$series longtermavg-of-link[$nicname]-$i-$j-mbps"
			done
			for j in packets dropped errors mcast overrun carrier collsns ; do
				echo "$series link[$nicname]-$i-$j-ppm"
				echo "$series longtermavg-of-link[$nicname]-$i-$j-ppm"
			done
		done	> $f.fieldkeys
		echo "40_ncrt_nic.sh" > $f.pluginname

	done < $INPUT_DIR/$series
done


