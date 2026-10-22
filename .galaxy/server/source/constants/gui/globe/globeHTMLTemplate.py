HTML_GLOBE_TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="__CSS_URL__">
<script src="__JS_URL__"></script>
<style>
html, body, #map { margin: 0; padding: 0; width: 100%; height: 100%;
  overflow: hidden; background: #07111F; }
#status { position: absolute; z-index: 5; left: 14px; bottom: 14px;
  padding: 9px 13px; color: #D8ECFF; background: rgba(7,17,31,.94);
  border: 1px solid #203A5B; border-radius: 8px; font: 12px Arial,sans-serif;
  max-width: 78%; }
#status:empty { display: none; }
.maplibregl-ctrl-group { background: #0A1628 !important;
  border: 1px solid #294D74 !important; }
.maplibregl-ctrl-group button { background-color: #0A1628 !important; }
.maplibregl-ctrl-group button span { filter: invert(1); }
.maplibregl-ctrl-attrib { color: #EAF5FF !important;
  background: rgba(7,17,31,.9) !important; }
.maplibregl-ctrl-attrib a { color: #75CCFF !important; }
</style>
</head>
<body>
<div id="map"></div>
<div id="status">Initializing Stark Globe…</div>
<script>
(() => {
  "use strict";

  const STYLES = __STYLES__;
  const LIBERTY_STYLE = __LIBERTY_STYLE__;
  const SATELLITE_URL = __SATELLITE_URL__;
  const DEM_URL = __DEM_URL__;
  const VECTOR_URL = __VECTOR_URL__;
  const statusElement = document.getElementById("status");
  const setStatus = (message) => { statusElement.textContent = message || ""; };

  if (!window.maplibregl || typeof window.maplibregl.Map !== "function") {
    setStatus("MapLibre failed to load. Check the ./static folder.");
    return;
  }

  let activeMode = "globe";
  let activeTheme = "stark";
  let cameraMode = "3d";
  let requestSequence = 0;
  let clickMode = "none";
  let markerCount = 0;
  const markers = [];
  let measurePoints = [];
  let connectedLinePoints = [];

  function haversineKm(a, b) {
    const rad = value => value * Math.PI / 180;
    const dLat = rad(b[1] - a[1]);
    const dLng = rad(b[0] - a[0]);
    const h = Math.sin(dLat / 2) ** 2 +
      Math.cos(rad(a[1])) * Math.cos(rad(b[1])) * Math.sin(dLng / 2) ** 2;
    return 6371.0088 * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(Math.max(0, 1 - h)));
  }

  function drawLine(points, sourceId, layerId, color = "#43B8FF") {
    if (!map.isStyleLoaded() || points.length < 2) return;
    const data = { type: "Feature", properties: {}, geometry: {
      type: "LineString", coordinates: points
    }};

    // Keep source and layer creation independent. If a previous layer creation
    // failed, a later click must still be able to create the missing layer.
    const existingSource = map.getSource(sourceId);
    if (existingSource) {
      existingSource.setData(data);
    } else {
      map.addSource(sourceId, { type: "geojson", data });
    }

    if (!map.getLayer(layerId)) {
      map.addLayer({
        id: layerId,
        type: "line",
        source: sourceId,
        layout: { "line-cap": "round", "line-join": "round", "visibility": "visible" },
        paint: {
          "line-color": color,
          "line-width": 4,
          "line-opacity": 1
        }
      });
    }
  }

  function drawDistanceLine() {
    drawLine(measurePoints.slice(0, 2), "stark-distance-line", "stark-distance-line-layer");
  }

  function drawConnectedLine() {
    drawLine(connectedLinePoints, "stark-connected-line", "stark-connected-line-layer", "#FFB02E");
  }

  function totalLineDistance(points) {
    let total = 0;
    for (let i = 1; i < points.length; i++) total += haversineKm(points[i - 1], points[i]);
    return total;
  }

  function addMarker(lng, lat, label) {
    const element = document.createElement("div");
    element.style.cssText = "width:28px;height:28px;border-radius:50%;background:#43B8FF;"
      + "border:2px solid #07111F;color:#07111F;font:bold 13px Arial;display:flex;"
      + "align-items:center;justify-content:center;box-shadow:0 2px 8px #0008;";
    element.textContent = String(++markerCount);
    const marker = new maplibregl.Marker({ element, color: "#43B8FF" })
      .setLngLat([lng, lat]).setPopup(new maplibregl.Popup({ offset: 18 })
      .setText(label || `Marker ${markerCount} (${lat.toFixed(5)}, ${lng.toFixed(5)})`))
      .addTo(map);
    markers.push(marker);
    setStatus(`Marker ${markerCount} added: ${lat.toFixed(5)}, ${lng.toFixed(5)}`);
  }

  const map = new maplibregl.Map({
    container: "map",
    style: STYLES.dark,
    center: [78.9629, 20.5937],
    zoom: 2.2,
    attributionControl: true,
    maxZoom: 20,
    minZoom: 0,
    renderWorldCopies: false
  });

  map.addControl(new maplibregl.NavigationControl({ visualizePitch: true }), "top-right");
  map.addControl(new maplibregl.ScaleControl({ maxWidth: 120, unit: "metric" }), "bottom-right");

  map.on("click", event => {
    const point = [event.lngLat.lng, event.lngLat.lat];
    if (clickMode === "mark") {
      addMarker(point[0], point[1]);
    } else if (clickMode === "measure") {
      if (measurePoints.length >= 2) measurePoints = [];
      measurePoints.push(point);
      addMarker(point[0], point[1], `Distance point ${measurePoints.length}`);
      if (measurePoints.length === 2) {
        drawDistanceLine();
        const km = haversineKm(measurePoints[0], measurePoints[1]);
        setStatus(`Straight-line distance: ${km.toLocaleString(undefined, { maximumFractionDigits: 3 })} km`);
      } else {
        setStatus("First point selected. Click the second location to calculate distance.");
      }
    } else if (clickMode === "line") {
      connectedLinePoints.push(point);
      addMarker(point[0], point[1], `Line point ${connectedLinePoints.length}`);
      if (connectedLinePoints.length >= 2) {
        drawConnectedLine();
        const km = totalLineDistance(connectedLinePoints);
        setStatus(`Connected line: ${connectedLinePoints.length} points • ${km.toLocaleString(undefined, { maximumFractionDigits: 3 })} km total. Keep clicking to add points, or click Finish line.`);
      } else {
        setStatus("Connected line started. Click at least one more point; the line follows the selected 2D/3D map surface.");
      }
    }
  });

  function applyStarkBlue(style) {
    for (const layer of (style.layers || [])) {
      const id = String(layer.id || "").toLowerCase();
      layer.paint = layer.paint || {};
      if (layer.type === "background") layer.paint["background-color"] = "#07111F";
      if (layer.type === "fill" && /water|ocean|lake|river/.test(id))
        layer.paint["fill-color"] = "#0B2744";
      if (layer.type === "line" && /road|transportation|street|motorway/.test(id))
        layer.paint["line-color"] = "#28517A";
      if (layer.type === "fill" && /landcover|landuse|park|grass/.test(id))
        layer.paint["fill-color"] = "#10283A";
    }
    return style;
  }

  async function fetchStyle(url) {
    const response = await fetch(url, { cache: "no-cache" });
    if (!response.ok) throw new Error(`Style request failed (${response.status})`);
    const style = await response.json();
    if (!style || style.version !== 8 || !Array.isArray(style.layers) || !style.sources)
      throw new Error("Provider returned an invalid MapLibre style.");
    return style;
  }

  function rasterStyle(tileUrl, attribution, maxzoom = 19) {
    return {
      version: 8,
      sources: {
        basemap: { type: "raster", tiles: [tileUrl], tileSize: 256, maxzoom, attribution }
      },
      layers: [{ id: "basemap-raster", type: "raster", source: "basemap" }]
    };
  }

  function applyCamera(animated = true) {
    try {
      map.setProjection(cameraMode === "2d" || activeMode !== "globe"
        ? { type: "mercator" } : { type: "globe" });
      map.easeTo({
        pitch: cameraMode === "2d" ? 0 :
          (activeMode === "buildings" || activeMode === "terrain" ? 62 : 0),
        bearing: cameraMode === "2d" ? 0 : -12,
        duration: animated ? 500 : 0
      });
    } catch (error) {
      console.warn("Camera configuration warning:", error);
    }
  }

  async function changeMode(mode) {
    const requestId = ++requestSequence;
    activeMode = mode;
    setStatus("Loading " + mode + " map…");
    try {
      let style;
      if (["globe", "dark", "light", "voyager", "street"].includes(mode)) {
        const theme = mode === "light" ? "light" :
          (mode === "voyager" || mode === "street" ? "voyager" : "dark");
        style = await fetchStyle(STYLES[theme]);
        if (mode === "globe") applyStarkBlue(style);
      } else if (mode === "satellite") {
        style = rasterStyle(SATELLITE_URL,
          "Imagery: Esri, Maxar, Earthstar Geographics, USDA, USGS, GIS User Community");
      } else if (mode === "hybrid") {
        style = await fetchStyle(LIBERTY_STYLE);
        style.sources.satellite = {
          type: "raster", tiles: [SATELLITE_URL], tileSize: 256, maxzoom: 19,
          attribution: "Imagery © Esri"
        };
        style.layers.unshift({ id: "satellite-base", type: "raster", source: "satellite" });
      } else if (mode === "terrain") {
        style = await fetchStyle(LIBERTY_STYLE);
        style.sources.terrainDem = {
          type: "raster-dem", tiles: [DEM_URL], tileSize: 256,
          encoding: "terrarium", maxzoom: 14,
          attribution: "Terrain data © Mapzen / AWS Terrain Tiles"
        };
        style.layers.unshift({
          id: "terrain-hillshade", type: "hillshade", source: "terrainDem",
          paint: { "hillshade-exaggeration": 0.35 }
        });
      } else if (mode === "buildings") {
        style = await fetchStyle(LIBERTY_STYLE);
        style.sources.starkBuildings = {
          type: "vector", url: VECTOR_URL,
          attribution: "© OpenStreetMap contributors, OpenFreeMap"
        };
        style.layers.push({
          id: "stark-3d-buildings", type: "fill-extrusion",
          source: "starkBuildings", "source-layer": "building", minzoom: 14,
          filter: ["all", ["==", ["geometry-type"], "Polygon"]],
          paint: {
            "fill-extrusion-color": "#237DB8",
            "fill-extrusion-height": ["to-number", ["get", "render_height"], 6],
            "fill-extrusion-base": ["to-number", ["get", "render_min_height"], 0],
            "fill-extrusion-opacity": 0.92
          }
        });
      } else {
        throw new Error("Unknown map mode: " + mode);
      }
      if (requestId !== requestSequence) return;
      map.setStyle(style, { diff: false });
      applyCamera();
      setStatus("Waiting for map data…");
    } catch (error) {
      console.error("Map mode failed:", error);
      if (requestId === requestSequence) setStatus("Could not load " + mode + ": " + error.message);
    }
  }

  async function changeTheme(theme) {
    activeTheme = theme;
    const styleUrl = theme === "light" ? STYLES.light :
      (theme === "voyager" ? STYLES.voyager : STYLES.dark);
    if (!["globe", "street", "dark", "light", "voyager", "buildings"].includes(activeMode)) {
      setStatus("Theme saved. Switch to a vector map to see this theme.");
      return;
    }
    const requestId = ++requestSequence;
    setStatus("Applying theme…");
    try {
      const style = await fetchStyle(activeMode === "buildings" ? LIBERTY_STYLE : styleUrl);
      if (requestId !== requestSequence) return;
      if (theme === "stark") applyStarkBlue(style);
      map.setStyle(style, { diff: false });
      setStatus("Theme applied.");
    } catch (error) {
      if (requestId === requestSequence) setStatus("Theme change failed: " + error.message);
    }
  }

  function setCamera(mode) {
    cameraMode = mode === "2d" ? "2d" : "3d";
    applyCamera();
  }

  map.on("load", () => {
    setStatus("");
    console.info("Stark Globe map initialized.");
  });
  map.on("style.load", () => {
    try {
      if (activeMode === "terrain" && map.getSource("terrainDem"))
        map.setTerrain({ source: "terrainDem", exaggeration: 1.35 });
      else if (map.getTerrain()) map.setTerrain(null);
      applyCamera(false);
      if (measurePoints.length >= 2) drawDistanceLine();
      if (connectedLinePoints.length >= 2) drawConnectedLine();
      if (activeMode === "buildings" && cameraMode !== "2d")
        map.easeTo({ zoom: Math.max(map.getZoom(), 14), pitch: 62, duration: 350 });
      setStatus("");
    } catch (error) {
      console.error("Could not apply 3D settings:", error);
      setStatus("Style loaded, but a 3D setting failed.");
    }
  });
  map.on("error", (event) => {
    if (event && event.error) console.warn("Map resource error:", event.error.message);
  });

  window.starkGlobe = {
    changeMode,
    changeTheme,
    setCamera,
    resize: () => map.resize(),
    setClickMode(mode) {
      clickMode = ["mark", "measure", "line"].includes(mode) ? mode : "none";
      if (clickMode === "measure") {
        measurePoints = [];
        setStatus("Distance mode: click two locations on the map.");
      } else if (clickMode === "line") {
        connectedLinePoints = [];
        if (map.getLayer("stark-connected-line-layer")) map.removeLayer("stark-connected-line-layer");
        if (map.getSource("stark-connected-line")) map.removeSource("stark-connected-line");
        setStatus("Draw connected line: click 2 or more locations. The line follows the selected map projection and surface.");
      } else if (clickMode === "mark") {
        setStatus("Marker mode: click anywhere on the map to add a marker.");
      } else {
        setStatus("");
      }
    },
    finishLine() {
      clickMode = "none";
      if (connectedLinePoints.length < 2) {
        setStatus("Add at least 2 points before finishing the line.");
        return;
      }
      drawConnectedLine();
      const km = totalLineDistance(connectedLinePoints);
      setStatus(`Line finished: ${connectedLinePoints.length} points • ${km.toLocaleString(undefined, { maximumFractionDigits: 3 })} km total.`);
    },
    addMarker,
    clearMarkers() {
      markers.forEach(marker => marker.remove());
      markers.length = 0;
      markerCount = 0;
      measurePoints = [];
      connectedLinePoints = [];
      if (map.getLayer("stark-distance-line-layer")) map.removeLayer("stark-distance-line-layer");
      if (map.getSource("stark-distance-line")) map.removeSource("stark-distance-line");
      if (map.getLayer("stark-connected-line-layer")) map.removeLayer("stark-connected-line-layer");
      if (map.getSource("stark-connected-line")) map.removeSource("stark-connected-line");
      setStatus("All markers and connected lines cleared.");
    },
    flyToLocation(longitude, latitude, zoom) {
      const lng = Number(longitude), lat = Number(latitude), level = Number(zoom);
      if (![lng, lat, level].every(Number.isFinite) ||
          lng < -180 || lng > 180 || lat < -90 || lat > 90 || level < 0 || level > 20) {
        setStatus("Invalid longitude, latitude or zoom (zoom range: 0–20).");
        return;
      }
      map.flyTo({ center: [lng, lat], zoom: level, duration: 1800, essential: true });
    }
  };
})();
</script>
</body>
</html>
"""