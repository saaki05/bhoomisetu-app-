const logger = require('../config/logger');

// A sensible fallback so Home's weather card always shows something real
// instead of nothing, for users who haven't set a district yet (New Delhi).
const DEFAULT_LOCATION = { name: 'New Delhi, India', latitude: 28.6139, longitude: 77.209 };

// WMO weather codes (used by Open-Meteo) collapsed into the same
// condition/icon vocabulary the app's WeatherCard already switches on.
const WMO_CONDITIONS = {
  0: { condition: 'Clear', description: 'clear sky', icon: '01d' },
  1: { condition: 'Clear', description: 'mainly clear', icon: '01d' },
  2: { condition: 'Clouds', description: 'partly cloudy', icon: '02d' },
  3: { condition: 'Clouds', description: 'overcast', icon: '03d' },
  45: { condition: 'Clouds', description: 'fog', icon: '50d' },
  48: { condition: 'Clouds', description: 'depositing rime fog', icon: '50d' },
  51: { condition: 'Drizzle', description: 'light drizzle', icon: '09d' },
  53: { condition: 'Drizzle', description: 'moderate drizzle', icon: '09d' },
  55: { condition: 'Drizzle', description: 'dense drizzle', icon: '09d' },
  61: { condition: 'Rain', description: 'slight rain', icon: '10d' },
  63: { condition: 'Rain', description: 'moderate rain', icon: '10d' },
  65: { condition: 'Rain', description: 'heavy rain', icon: '10d' },
  71: { condition: 'Snow', description: 'slight snow', icon: '13d' },
  73: { condition: 'Snow', description: 'moderate snow', icon: '13d' },
  75: { condition: 'Snow', description: 'heavy snow', icon: '13d' },
  80: { condition: 'Rain', description: 'rain showers', icon: '09d' },
  81: { condition: 'Rain', description: 'moderate rain showers', icon: '09d' },
  82: { condition: 'Rain', description: 'violent rain showers', icon: '09d' },
  95: { condition: 'Thunderstorm', description: 'thunderstorm', icon: '11d' },
  96: { condition: 'Thunderstorm', description: 'thunderstorm with hail', icon: '11d' },
  99: { condition: 'Thunderstorm', description: 'severe thunderstorm with hail', icon: '11d' },
};

function describeCode(code) {
  return WMO_CONDITIONS[code] ?? { condition: 'Clouds', description: 'variable conditions', icon: '02d' };
}

// Open-Meteo's free tier rate-limits by burst volume, and Render's free-tier
// egress IP is shared across other customers' traffic too — so every Home
// screen load hitting the API directly trips 429s under real usage. Weather
// doesn't change meaningfully inside a short window, so cache per-location
// responses and cache geocoded coordinates indefinitely (a district's
// lat/lon never changes).
const WEATHER_CACHE_TTL_MS = 20 * 60 * 1000;
const weatherCache = new Map();
const geocodeCache = new Map();

async function fetchJson(url, timeoutMs = 6000) {
  const response = await fetch(url, { signal: AbortSignal.timeout(timeoutMs) });
  if (!response.ok) throw new Error(`Request to ${url} returned ${response.status}`);
  return response.json();
}

/**
 * Geocodes a free-text district/state into coordinates via Open-Meteo's
 * free geocoding API (no key required). Falls back to null on any failure
 * so the caller can fall back to a default location.
 */
async function geocode(district) {
  const cached = geocodeCache.get(district);
  if (cached) return cached;

  try {
    // Open-Meteo's `name` param is a single place-name lookup, not a
    // free-text address — combining "district, state" into one string
    // returns zero results, so only the district is sent; `country=IN`
    // already scopes the search enough to disambiguate common names.
    const query = encodeURIComponent(district);
    const data = await fetchJson(
      `https://geocoding-api.open-meteo.com/v1/search?name=${query}&count=1&language=en&format=json&country=IN`,
    );
    const match = data.results?.[0];
    if (!match) return null;
    const location = { name: `${match.name}, ${match.admin1 ?? 'India'}`, latitude: match.latitude, longitude: match.longitude };
    geocodeCache.set(district, location);
    return location;
  } catch (error) {
    logger.warn('Weather geocoding failed', { error: error.message, district });
    return null;
  }
}

/**
 * Current weather + basic conditions for a district/state via Open-Meteo,
 * which needs no API key. Falls back to a default location (rather than
 * returning null) so the Home screen's weather card is never empty just
 * because the user hasn't filled in their district yet.
 */
async function getWeatherForLocation({ district, state }) {
  const location = (district ? await geocode(district) : null) ?? DEFAULT_LOCATION;

  const cached = weatherCache.get(location.name);
  if (cached && cached.expiresAt > Date.now()) return cached.data;

  try {
    const data = await fetchJson(
      'https://api.open-meteo.com/v1/forecast' +
        `?latitude=${location.latitude}&longitude=${location.longitude}` +
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,weather_code' +
        '&daily=sunrise,sunset&timezone=auto',
    );

    const current = data.current ?? {};
    const { condition, description, icon } = describeCode(current.weather_code);

    const result = {
      location: location.name,
      temperatureCelsius: current.temperature_2m,
      feelsLikeCelsius: current.apparent_temperature,
      humidityPercent: current.relative_humidity_2m,
      windSpeedKmh: current.wind_speed_10m != null ? Math.round(current.wind_speed_10m) : null,
      condition,
      description,
      icon,
      sunrise: data.daily?.sunrise?.[0] ?? null,
      sunset: data.daily?.sunset?.[0] ?? null,
    };

    weatherCache.set(location.name, { data: result, expiresAt: Date.now() + WEATHER_CACHE_TTL_MS });
    return result;
  } catch (error) {
    logger.warn('Weather request failed', { error: error.message });
    // Serve a stale cache entry rather than nothing if Open-Meteo is
    // erroring or rate-limiting — better a slightly old reading than none.
    return cached?.data ?? null;
  }
}

module.exports = { getWeatherForLocation };
