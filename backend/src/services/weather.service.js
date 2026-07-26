const { loadEnv } = require('../config/env');
const logger = require('../config/logger');

const env = loadEnv();

/**
 * Fetches current weather + a short forecast from OpenWeatherMap for a
 * free-text location ("district, state"). Returns null (rather than
 * throwing) when the API key isn't configured or the request fails, so a
 * weather outage never breaks the rest of the Home summary.
 */
async function getWeatherForLocation({ district, state }) {
  if (!env.WEATHER_API_KEY || !district) return null;

  try {
    const query = encodeURIComponent(`${district},${state ?? ''},IN`);
    const url = `${env.WEATHER_API_BASE_URL}/weather?q=${query}&appid=${env.WEATHER_API_KEY}&units=metric`;

    const response = await fetch(url, { signal: AbortSignal.timeout(5000) });
    if (!response.ok) {
      logger.warn('Weather API returned a non-OK response', { status: response.status });
      return null;
    }

    const data = await response.json();

    return {
      location: data.name,
      temperatureCelsius: data.main?.temp,
      feelsLikeCelsius: data.main?.feels_like,
      humidityPercent: data.main?.humidity,
      windSpeedKmh: data.wind?.speed != null ? Math.round(data.wind.speed * 3.6) : null,
      condition: data.weather?.[0]?.main,
      description: data.weather?.[0]?.description,
      icon: data.weather?.[0]?.icon,
      sunrise: data.sys?.sunrise ? new Date(data.sys.sunrise * 1000).toISOString() : null,
      sunset: data.sys?.sunset ? new Date(data.sys.sunset * 1000).toISOString() : null,
    };
  } catch (error) {
    logger.warn('Weather API request failed', { error: error.message });
    return null;
  }
}

module.exports = { getWeatherForLocation };
