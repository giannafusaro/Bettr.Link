/*
  Driver.js - PhantomJS with Capybara::Poltergeist integration
*/

var w = wappalyzer;

w.driver = {
  debug: true,
  data: {},
  timeout: 5000,

  // Log messages to console
  log: function(args) {
    if ( w.driver.debug ) { print(args.type + ': ' + args.message + "\n"); }
  },

  // Initialize
  init: function() {
    var app, apps = {}, globals;

    // Get Global Variables
    for (var property in window) {
      globals += property + ' ';
    }

    // Kick off Analyzer
    w.analyze(w.driver.data.host, w.driver.data.url, {
      html: w.driver.data.html,
      headers: w.driver.data.headers,
      env: globals.split(' ').slice(0, 500)
    });

    // Detect Applications
    for (app in w.detected[w.driver.data.url]) {
      apps[app] = {
        categories: [],
        confidence: w.detected[w.driver.data.url][app].confidenceTotal,
        version:    w.detected[w.driver.data.url][app].version
      };
      w.apps[app].cats.forEach(function(cat) {
        apps[app].categories.push(w.categories[cat]);
      });
    };

    // Return detected apps
    return JSON.stringify(apps);
  },

  // Dummy
  displayApps: function(){}
};
