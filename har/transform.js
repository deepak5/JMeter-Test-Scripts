#!/usr/bin/env node

function transformRequest(request) {
  return {
    method: request.method,
    url: request.url,
    headers: request.headers.filter(function (header) { return ["Host"].indexOf(header.name) !== -1;}),
    queryString: request.queryString,
    cookies: request.cookies.filter(function(cookie) { return cookie.name !== "_ga"; })  // Google Analytics
  };
}

function transformResponse(response) {
  return {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers.filter(function(header) { return ["Location", "Content-Type"].indexOf(header.name) !== -1; }),
    cookies: response.cookies,
    content: response.content,
    redirectUrl: response.redirectUrl
  };
}

function transformEntry(entry) {
  return {
    request: transformRequest(entry.request),
    response: transformResponse(entry.response)
  };
}

function startsWith(prefix, str) {
  return str.substring(0, prefix.length) === prefix;
}

function relevant(entry) {
  var exclude =
    [ /^https:\/\/staging\.wifiservice\.net\/static/g
    , /^https:\/\/www\.google-analytics\.com\//g
    , /^http:\/\/www\.bbc\.co\.uk\/.+/g
    , /^http:\/\/static\.bbci\.co\.uk\//g
    , /^http:\/\/www\.live\.bbc\.co\.uk\//g
    , /^http:\/\/sa\.bbc\.co\.uk\//g
    , /^http:\/\/ichef\.bbci\.co\.uk\//g
    , /^http:\/\/edigitalsurvey\.com\//g
    , /^https:\/\/www\.paypalobjects\.com\//g
    , /^https:\/\/b\.stats\.paypal\.com\//g
    , /^https:\/\/t\.paypal\.com\//g
    , /^https:\/\/.*\.mediaplex\.com\//g
    , /\.gif$/g
    , /^https:\/\/.*\.omtrdc\.net\//g
    , /^https:\/\/www\.google\.co\.uk\//g
    , /^https:\/\/ssl\.gstatic\.com\//g
    , /^https:\/\/www\.google\.com\//g
    , /^https:\/\/www\.gstatic\.com\//g
    , /^https:\/\/apis\.google\.com\//g
    ];

  return exclude.filter(function (regex) { return regex.test(entry.request.url); }).length === 0;
}

function transform(har) {
  return har.log.entries.filter(relevant).map(transformEntry);
}

console.log(JSON.stringify(transform(JSON.parse(require("fs").readFileSync(process.argv[2]))), undefined, 2));
