{{flutter_js}}
{{flutter_build_config}}

// Netlify releases use a versioned entrypoint name so obsolete Flutter service
// workers cannot substitute an older main.dart.js from Cache Storage.
if (window.location.protocol === 'https:' &&
    window.location.hostname.endsWith('.netlify.app')) {
  for (const build of _flutter.buildConfig.builds) {
    if (build.mainJsPath === 'main.dart.js') {
      build.mainJsPath = 'main.bhoomisetu.20260805.js';
    }
  }
}

_flutter.loader.load();
