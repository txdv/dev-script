#!/usr/bin/env node

var shelljs = require('shelljs'),
    print = console.log,
    mu    = require('mu2');

var esc = {
  day     : '\\d',
  host    : '\\h',
  hostname: '\\H',
  jobs    : '\\j',
  termdev : '\\l',
  newline : '\\n',
  nl      : '\\n',
  cr      : '\\r',
  shell   : '\\s',
  time24  : '\\t',
  time12  : '\\T',
  time    : '\\@',
  stime24 : '\\A',
  username: '\\u',
  version : '\\v',
  rversion: '\\V',
  pwd     : '\\w',
  shortpwd: '\\W',
  history : '\\!',
  number  : '\\#',
  backslash: '\\\\',

  underline: {
    start: '\\E[04;38;5;146m',
    end  : '\\E[0m'
  },

/*
  // old

  color: {
    black      : '\\e[0;30m',
    blue       : '\\e[0;34m',
    green      : '\\e[0;32m',
    cyan       : '\\e[0;36m',
    red        : '\\e[0;31m',
    purple     : '\\e[0;35m',
    brown      : '\\e[0;33m',
    lightgray  : '\\e[0;37m',
    darkgray   : '\\e[1;30m',
    lightblue  : '\\e[1;34m',
    lightgreen : '\\e[1;32m',
    lightcyan  : '\\e[1;36m',
    lightred   : '\\e[1;31m',
    lightpurple: '\\e[1;35m',
    yellow     : '\\e[1;33m',
    white      : '\\e[1;37m',
    nc         : '\\e[0m'
  }
*/

  color: {
    black      : '\\[\\033[00;30m\\]',
    blue       : '\\[\\033[00;34m\\]',
    green      : '\\[\\033[00;32m\\]',
    cyan       : '\\[\\033[00;36m\\]',
    red        : '\\[\\033[00;31m\\]',
    purple     : '\\[\\033[00;35m\\]',
    brown      : '\\[\\033[00;33m\\]',
    lightgray  : '\\[\\033[00;37m\\]',
    darkgray   : '\\[\\033[01;30m\\]',
    lightblue  : '\\[\\033[01;34m\\]',
    lightgreen : '\\[\\033[01;32m\\]',
    lightcyan  : '\\[\\033[01;36m\\]',
    lightred   : '\\[\\033[01;31m\\]',
    lightpurple: '\\[\\033[01;35m\\]',
    yellow     : '\\[\\033[01;33m\\]',
    white      : '\\[\\033[01;37m\\]',
    nc         : '\\[\\033[00m\\]'
  }
}

String.prototype.startsWith = function (str) {
  return this.slice(0, str.length) == str;
};

Array.prototype.contains = function (item) {
  for (var i = 0; i < this.length; i++) {
    if (this[i] == item) {
      return true;
    }
  }
  return false;
}

function Variables() {
  var vars = { };
  return {
    export: function() {
      return vars;
    },
    exportVariables: function() {
      for (key in vars) {
        if (vars[key] !== undefined && vars[key] !== '') {
          console.log(key + ' ' + vars[key] + "|");
        }
      }
    },
    set: function(key, value) {
      vars[key] = value;
    },
    add: function(key, value, seperator) {
      if (seperator === 'undefined') {
        seperator = ':';
      }
      vars[key] = value + ':' + env[key];
    }
  };
}

function strftime(format) { return '\\D{' + format + '}'; }

function render(str, obj, callback) {
  var o = { esc: esc, color: esc.color };
  if (obj !== undefined && typeof obj === 'object') {
    for (var attrname in obj) {
      if (o[attrname] === undefined) {
        o[attrname] = obj[attrname];
      }
    }
  }
  var stream = require('mu2').renderText(str, o);
  var str = '';
  stream.on('data', function(buf) {
    str += buf.toString('utf8');
  });
  stream.on('end', function() {
    //if (typeof callback === 'function') {
      callback(str);
    //}
  });
}

function get(str) {
  function trim(s) { s = s.replace(/(^\s*)|(\s*$)/gi,""); s = s.replace(/[ ]{2,}/gi," "); s = s.replace(/\n /,"\n"); return s; }
  return trim(shelljs.exec(str, { silent: true }).stdout);
}

apps = [
  {
    name : 'mono',
    exe  : 'mono',
    color: 'yellow',
    version: function () { return get('mono --version').split(' ')[4]; }
  },
  {
    name : 'node',
    exe  : 'node',
    color: 'lightgreen',
    version: function () { return get('node --version'); }
  },
  {
    name : 'ruby',
    exe  : 'ruby',
    color: 'red',
    version: function () { return get('ruby --version').split(' ')[1]; }
  }
];

var pre = '{{color.lightgreen}}{{esc.username}}{{color.white}}@{{color.purple}}{{esc.host}}{{color.white}}:';

function escp(str, chars, color) {
  color = '{{color.' + color + '}}';
  var white = '{{color.white}}';

  var res, state;
  if (chars.contains(str[0])) {
    state = 0;
    res = white;
  } else {
    state = 1;
    res = color;
  }
  res += str[0];
  for (var i = 1; i < str.length; i++) {
    var ch = str[i];
    switch (state) {
    case 0:
      if (!chars.contains(ch)) {
        state = 1;
        res += color;
      }
      res += ch;
      break;
    case 1:
      if (chars.contains(ch)) {
        res += white;
        state = 0;
      }
      res += ch;
      break;
    }
  }
  return res;
}


function appstring() {
  var res = '';
  for (var i = 0; i < apps.length; i++) {
    var app = apps[i];
    var path = shelljs.which(app.exe);
    if (path && !path.startsWith('/usr/bin/')) {
      res += escp(app.name + '-' + app.version(), [ '.', '-' ], app.color) + '{{color.white}}:';
    }
  }
  return res;
}

var str = pre + appstring() + ' {{color.blue}}{{esc.pwd}} {{color.lightgreen}}${{color.nc}} ';
var code = { esc: esc, color: esc.color };

var vars = new Variables();
render(str, code, function (str) {
  vars.set('PS1', str);
  vars.exportVariables();
});

