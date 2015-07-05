(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.BbsDbController = (function() {
    function BbsDbController(bbsDb, bbsDbView) {
      this.clickBbsHandler = bind(this.clickBbsHandler, this);
      this.deleteBbsHandler = bind(this.deleteBbsHandler, this);
      this.showContextMenuHandler = bind(this.showContextMenuHandler, this);
      this.setBbsListListener = bind(this.setBbsListListener, this);
      this.postAddBbsHandler = bind(this.postAddBbsHandler, this);
      this.addBbsCompleteHandler = bind(this.addBbsCompleteHandler, this);
      this.getAddBbs = bind(this.getAddBbs, this);
      this.bbsDb = bbsDb;
      this.bbsDbView = bbsDbView;
    }

    BbsDbController.prototype.getBbsList = function() {
      this.bbsDbView.sectionToEmpty();
      this.bbsDb.selectBbs();
      this.bbsDbView.printBbs(this.bbsDb.bbsList);
      return this.setBbsListListener(this.bbsDb.bbsList);
    };

    BbsDbController.prototype.getAddBbs = function() {
      if (!this.bbsDbView.showAddbbsFlag) {
        this.bbsDbView.showAddbbs();
        return this.addBbsInitialize();
      }
    };

    BbsDbController.prototype.addBbsInitialize = function() {
      return this.bbsDbView.html.addEventListener("complete", this.addBbsCompleteHandler);
    };

    BbsDbController.prototype.addBbsCompleteHandler = function(event) {
      var id;
      id = this.bbsDbView.html.window.document.getElementById("post-bbs-url");
      if (id != null) {
        return id.addEventListener("click", this.postAddBbsHandler);
      }
    };

    BbsDbController.prototype.postAddBbsHandler = function(event) {
      var name, url;
      name = this.bbsDbView.html.window.document.getElementById("add-bbs-name").value;
      url = this.bbsDbView.html.window.document.getElementById("add-bbs-url").value;
      if ((url != null) && (name != null)) {
        this.bbsDb.insertBbs(name, url);
        this.bbsDbView.addBbs.close();
        this.bbsDbView.addBbs = null;
        return this.getBbsList();
      }
    };

    BbsDbController.prototype.setBbsListListener = function(bbsList) {
      if (bbsList !== null) {
        return $.each(bbsList, (function(_this) {
          return function(index, value) {
            var id;
            id = window.viewerObj.html.window.document.getElementById(bbsList[index]["id"]);
            id.addEventListener("contextmenu", _this.showContextMenuHandler(bbsList[index]["id"]));
            return id.addEventListener("click", _this.clickBbsHandler(bbsList[index]["url"], bbsList[index]["name"]));
          };
        })(this));
      }
    };

    BbsDbController.prototype.showContextMenuHandler = function(id) {
      return (function(_this) {
        return function(event) {
          var contextMenu, deleteBbs;
          contextMenu = new air.NativeMenu();
          event.preventDefault();
          deleteBbs = contextMenu.addItem(new air.NativeMenuItem("削除"));
          deleteBbs.addEventListener(window.air.Event.SELECT, _this.deleteBbsHandler(id));
          return contextMenu.display(window.nativeWindow.stage, event.clientX, event.clientY);
        };
      })(this);
    };

    BbsDbController.prototype.deleteBbsHandler = function(id) {
      return (function(_this) {
        return function(event) {
          _this.bbsDb.deleteBbs(id);
          return _this.getBbsList();
        };
      })(this);
    };

    BbsDbController.prototype.clickBbsHandler = function(url, name) {
      return (function(_this) {
        return function(event) {
          var bbsTitle, getTread, getUrl;
          getUrl = window.document.getElementById("url");
          $(getUrl).val(url);
          bbsTitle = window.document.getElementById("bbs-title");
          bbsTitle.innerHTML = name;
          window.viewerObj.so.data.bbsTitle = name;
          getTread = window.document.getElementById("get-thread");
          $(getTread).attr('disabled', false);
          return window.viewerObj.getThreadHandler();
        };
      })(this);
    };

    return BbsDbController;

  })();

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ConfigController = (function() {
    function ConfigController(configView) {
      this.getConfig = bind(this.getConfig, this);
      var hoge;
      hoge = "hoge2";
      this.configView = configView;
    }

    ConfigController.prototype.getConfig = function() {
      if (!this.configView.windowFlag) {
        return this.configView.showConfigWindow();
      }
    };

    return ConfigController;

  })();

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ThreadController = (function() {
    function ThreadController(thread, threadView, jimakuView) {
      this.switchClassAir = bind(this.switchClassAir, this);
      this.jimakuClockOff = bind(this.jimakuClockOff, this);
      this.jimakuClockOn = bind(this.jimakuClockOn, this);
      this.jimakuLoadOn = bind(this.jimakuLoadOn, this);
      this.resLoadOff = bind(this.resLoadOff, this);
      this.resLoadOn = bind(this.resLoadOn, this);
      this.printJimakuResCount = bind(this.printJimakuResCount, this);
      this.printResToJimaku = bind(this.printResToJimaku, this);
      this.printSubjectToJimaku = bind(this.printSubjectToJimaku, this);
      this.onResizeJimaku = bind(this.onResizeJimaku, this);
      this.onMoveJimaku = bind(this.onMoveJimaku, this);
      this.jimakuCompleteHandler = bind(this.jimakuCompleteHandler, this);
      var req;
      this.thread = thread;
      this.threadView = threadView;
      this.jimakuView = jimakuView;
      this.resLoadTimer = null;
      this.jimakuPrintTimer = null;
      this.clock = null;
      this.jimakuBody = null;
      this.jimakuTitle = null;
      this.jimakuSubject = null;
      this.jimakuClock = null;
      this.jimakuCount = null;
      this.jimakuRes = null;
      this.jimakuResQueue = [];
      this.jimakuCompleteFlag = false;
      this.resLoadFlag = false;
      this.jimakuLoadFlag = false;
      this.airFlag = false;
      req = new window.air.URLRequest("../../sound/sound.mp3");
      this.sound = new air.Sound(req);
      this.jimakuInitialize();
    }

    ThreadController.prototype.jimakuInitialize = function() {
      return this.jimakuView.html.addEventListener("complete", this.jimakuCompleteHandler);
    };

    ThreadController.prototype.jimakuCompleteHandler = function() {
      this.jimakuTitle = this.jimakuView.html.window.document.getElementById("jimaku-title");
      this.jimakuSubject = this.jimakuView.html.window.document.getElementById("jimaku-subject");
      this.jimakuBody = this.jimakuView.html.window.document.getElementById("jimaku-body");
      this.jimakuClock = this.jimakuView.html.window.document.getElementById("jimaku-clock");
      this.jimakuCount = this.jimakuView.html.window.document.getElementById("jimaku-count");
      this.jimakuRes = this.jimakuView.html.window.document.getElementById("jimaku-res");
      if (this.jimakuSubject != null) {
        this.jimakuTitle.addEventListener("mousedown", this.onMoveJimaku, true);
        this.jimakuBody.addEventListener("mousedown", this.onResizeJimaku, true);
        this.printSubjectToJimaku(this.jimakuSubject);
        this.printJimakuResCount();
      }
      if (this.jimakuClock != null) {
        this.jimakuClockOn();
      }
      if (this.jimakuRes != null) {
        if (window.viewerObj.so.data.fontFamily != null) {
          $(this.jimakuRes).css("font-family", window.viewerObj.so.data.fontFamily);
        }
        if (window.viewerObj.so.data.color != null) {
          $(this.jimakuRes).css("color", window.viewerObj.so.data.color);
        }
        if (window.viewerObj.so.data.fontSize != null) {
          $(this.jimakuRes).css("font-size", window.viewerObj.so.data.fontSize);
        }
        if (window.viewerObj.so.data.strokeWidth != null) {
          $(this.jimakuRes).css("-webkit-text-stroke-width", window.viewerObj.so.data.strokeWidth);
        }
        if (window.viewerObj.so.data.strokeColor != null) {
          return $(this.jimakuRes).css("-webkit-text-stroke-color", window.viewerObj.so.data.strokeColor);
        }
      }
    };

    ThreadController.prototype.onMoveJimaku = function(event) {
      return this.jimakuView.jimaku.startMove();
    };

    ThreadController.prototype.onResizeJimaku = function(event) {
      return this.jimakuView.jimaku.startResize("BR");
    };

    ThreadController.prototype.printSubjectToJimaku = function(subject) {
      this.thread.clickedThread["title"] = this.thread.clickedThread["title"].replace(/\(\d+\)$/, "");
      return subject.innerHTML = this.thread.clickedThread["title"];
    };

    ThreadController.prototype.printResToJimaku = function(res) {
      if (this.jimakuRes != null) {
        return this.jimakuRes.innerHTML = res;
      }
    };

    ThreadController.prototype.printJimakuResCount = function() {
      if (this.jimakuCount != null) {
        return this.jimakuCount.innerHTML = "(" + this.thread.resCount + ")";
      }
    };

    ThreadController.prototype.checkQueueLength = function(count) {
      var sec;
      switch (false) {
        case !(count <= 1):
          return sec = 9000;
        case !((2 <= count && count <= 3)):
          return sec = 6000;
        case !((4 <= count && count <= 5)):
          return sec = 5000;
        case !((6 <= count && count <= 10)):
          return sec = 3500;
        case !((11 <= count && count <= 15)):
          return sec = 2000;
        case !(16 < count):
          return sec = 1000;
        default:
          return sec = 1000;
      }
    };

    ThreadController.prototype.resLoadOn = function() {
      this.resLoadFlag = true;
      return this.resLoadTimer = setInterval((function(_this) {
        return function() {
          var res;
          res = _this.thread.getRes();
          if (res) {
            _this.threadView.printRes(res);
            $.each(res, function(index, value) {
              return _this.jimakuResQueue.push(res[index][4]);
            });
            if (!_this.jimakuLoadFlag) {
              return _this.jimakuLoadOn();
            }
          }
        };
      })(this), 7000);
    };

    ThreadController.prototype.resLoadOff = function() {
      this.resLoadFlag = false;
      clearInterval(this.resLoadTimer);
      return clearTimeout(this.jimakuPrintTimer);
    };

    ThreadController.prototype.jimakuLoadOn = function(sec) {
      if (sec == null) {
        sec = 0;
      }
      this.jimakuLoadFlag = true;
      return this.jimakuPrintTimer = setTimeout((function(_this) {
        return function() {
          var hoge;
          if (_this.jimakuResQueue[0] != null) {
            _this.printJimakuResCount();
            _this.printResToJimaku(_this.jimakuResQueue[0]);
            _this.sound.play();
            _this.jimakuResQueue.shift();
            hoge = _this.checkQueueLength(_this.jimakuResQueue.length);
            return _this.jimakuLoadOn(hoge);
          } else {
            _this.printResToJimaku("");
            _this.jimakuLoadFlag = false;
            return clearTimeout(_this.jimakuPrintTimer);
          }
        };
      })(this), sec);
    };

    ThreadController.prototype.jimakuClockOn = function() {
      return this.clock = setInterval((function(_this) {
        return function() {
          var nowTime;
          nowTime = _this.jimakuView.getNowTime();
          return _this.jimakuClock.innerHTML = nowTime;
        };
      })(this), 1000);
    };

    ThreadController.prototype.jimakuClockOff = function() {
      return clearInterval(this.clock);
    };

    ThreadController.prototype.switchClassAir = function() {
      if (this.airFlag && (this.jimakuBody != null)) {
        this.jimakuBody.className = "";
        return this.airFlag = false;
      } else if (this.jimakuBody != null) {
        this.jimakuBody.className = "bg-air";
        return this.airFlag = true;
      }
    };

    return ThreadController;

  })();

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Bbs = (function() {
    function Bbs(url) {
      this.subjectsToArray = bind(this.subjectsToArray, this);
      this.getSubjects = bind(this.getSubjects, this);
      this.url = url;
      this.urlToArray();
      this.getSubjects();
      this.subjectsToArray();
    }

    Bbs.prototype.urlToArray = function() {
      this.url = this.url.split("/");
      this.url = {
        "domain": this.url[2],
        "category": this.url[3],
        "address": this.url[4]
      };
      return this.url["reqSubjectUrl"] = "http://" + this.url["domain"] + "/" + this.url["category"] + "/" + this.url["address"] + "/subject.txt";
    };

    Bbs.prototype.getSubjects = function() {
      return $.ajax({
        async: false,
        beforeSend: (function(_this) {
          return function(xhr) {
            return xhr.overrideMimeType("text/html;charset=EUC-JP");
          };
        })(this),
        type: 'GET',
        url: this.url["reqSubjectUrl"],
        dataType: 'text',
        success: (function(_this) {
          return function(data) {
            if (data) {
              return _this.subjects = data;
            }
          };
        })(this),
        error: function() {
          return alert("スレッド読み込みエラー");
        }
      });
    };

    Bbs.prototype.subjectsToArray = function() {
      var res;
      res = [];
      this.subjects = this.subjects.split("\n");
      $.each(this.subjects, function(index, value) {
        value = value.split(".cgi,");
        return res[index] = {
          "number": value[0],
          "title": value[1]
        };
      });
      this.subjects = res;
      this.subjects.pop();
      return this.subjects.pop();
    };

    return Bbs;

  })();

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.BbsDb = (function() {
    function BbsDb() {
      this.deleteBbs = bind(this.deleteBbs, this);
      this.connect = bind(this.connect, this);
    }

    BbsDb.prototype.connect = function() {
      var dbFile, error;
      this.bbses = new window.air.SQLConnection();
      dbFile = window.air.File.applicationStorageDirectory.resolvePath("bbs.db");
      try {
        return this.bbses.open(dbFile, window.air.SQLMode.CREATE);
      } catch (_error) {
        error = _error;
        window.air.trace("Error message:", error.message);
        return window.air.trace("Details:", error.details);
      }
    };

    BbsDb.prototype.create = function() {
      var createBbs, error, sql;
      createBbs = new window.air.SQLStatement();
      createBbs.sqlConnection = this.bbses;
      sql = "CREATE TABLE IF NOT EXISTS bbses (\n	id INTEGER PRIMARY KEY AUTOINCREMENT,\n	name TEXT,\n	url TEXT\n	)";
      createBbs.text = sql;
      try {
        createBbs.execute();
        return air.trace("Table created");
      } catch (_error) {
        error = _error;
        window.air.trace("Error message:", error.message);
        return window.air.trace("Details:", error.details);
      }
    };

    BbsDb.prototype.insertBbs = function(name, url) {
      var error, insertBbsStmt, sql;
      insertBbsStmt = new window.air.SQLStatement();
      insertBbsStmt.sqlConnection = this.bbses;
      sql = "INSERT INTO bbses (name, url) VALUES ('" + name + "', '" + url + "')";
      insertBbsStmt.text = sql;
      try {
        insertBbsStmt.execute();
        return window.air.trace("INSERT statement succeeded");
      } catch (_error) {
        error = _error;
        window.air.trace("Error message:", error.message);
        return window.air.trace("Details:", error.details);
      }
    };

    BbsDb.prototype.selectBbs = function() {
      var error, result, selectBbsStmt, sql;
      selectBbsStmt = new window.air.SQLStatement();
      selectBbsStmt.sqlConnection = this.bbses;
      sql = "SELECT * FROM bbses";
      selectBbsStmt.text = sql;
      try {
        selectBbsStmt.execute();
        result = selectBbsStmt.getResult();
        this.bbsList = result.data;
        return window.air.trace("SELECT statement succeeded");
      } catch (_error) {
        error = _error;
        window.air.trace("Error message:", error.message);
        return window.air.trace("Details:", error.details);
      }
    };

    BbsDb.prototype.deleteBbs = function(id) {
      var deleteBbsStmt, erorr, sql;
      deleteBbsStmt = new window.air.SQLStatement();
      deleteBbsStmt.sqlConnection = this.bbses;
      sql = "DELETE FROM bbses WHERE id = " + id;
      deleteBbsStmt.text = sql;
      try {
        deleteBbsStmt.execute();
        return window.air.trace("DELETE statement succeeded");
      } catch (_error) {
        erorr = _error;
        window.air.trace("Error message:", error.message);
        return window.air.trace("Details:", error.details);
      }
    };

    return BbsDb;

  })();

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Thread = (function() {
    function Thread(clickedThread, bbsUrl) {
      this.getRes = bind(this.getRes, this);
      this.clickedThread = clickedThread;
      this.clickedThread["ReqUrl"] = "http://" + bbsUrl["domain"] + "/bbs/rawmode.cgi/" + bbsUrl["category"] + "/" + bbsUrl["address"] + "/" + clickedThread["number"] + "/";
      this.bbsUrl = bbsUrl;
      this.resCount = 0;
    }

    Thread.prototype.getRes = function() {
      var url;
      if (this.resCount === 0) {
        url = this.clickedThread["ReqUrl"];
      } else {
        url = this.clickedThread["ReqUrl"] + (this.resCount + 1) + "-";
      }
      $.ajax({
        async: false,
        beforeSend: (function(_this) {
          return function(xhr) {
            return xhr.overrideMimeType("text/html;charset=EUC-JP");
          };
        })(this),
        type: 'GET',
        url: url,
        dataType: 'text',
        success: (function(_this) {
          return function(data) {
            if (data) {
              return _this.resToArray(data);
            } else {
              return _this.res = null;
            }
          };
        })(this),
        error: function() {}
      });
      return this.res;
    };

    Thread.prototype.resToArray = function(data) {
      this.res = [];
      data = data.split("\n");
      data.pop();
      this.resCount = this.resCount + data.length;
      return $.each(data, (function(_this) {
        return function(index, value) {
          var i, j, results;
          _this.res[index] = [];
          value = value.split("<>");
          results = [];
          for (i = j = 0; j <= 4; i = ++j) {
            results.push(_this.res[index][i] = value[i]);
          }
          return results;
        };
      })(this));
    };

    return Thread;

  })();

}).call(this);

(function() {
  window.BaseView = (function() {
    function BaseView() {}

    BaseView.prototype.sectionToEmpty = function() {
      var section;
      section = window.viewerObj.html.window.document.getElementById("section");
      return $(section).empty();
    };

    return BaseView;

  })();

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.BbsView = (function(superClass) {
    extend(BbsView, superClass);

    function BbsView(bbs, db) {
      this.printSubject = bind(this.printSubject, this);
      this.subjects = bbs.subjects;
      this.url = bbs.url;
    }

    BbsView.prototype.printSubject = function() {
      var section, topMost;
      this.sectionToEmpty();
      section = window.viewerObj.html.window.document.getElementById("section");
      $.each(this.subjects, (function(_this) {
        return function(index, value) {
          return $(section).append($("<div class=\"thread\">" + _this.subjects[index]["title"] + "</div>").click(function() {
            _this.clickedThread = {
              "title": _this.subjects[index]["title"],
              "number": _this.subjects[index]["number"]
            };
            return window.viewerObj.clickThreadHandler();
          }));
        };
      })(this));
      topMost = window.viewerObj.html.window.document.getElementById("top-most");
      return $(topMost)[0].scrollIntoView(true);
    };

    return BbsView;

  })(BaseView);

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.BbsDbView = (function(superClass) {
    extend(BbsDbView, superClass);

    function BbsDbView() {
      this.addBbsClosingListener = bind(this.addBbsClosingListener, this);
      this.showAddbbs = bind(this.showAddbbs, this);
      this.printBbs = bind(this.printBbs, this);
      this.showAddbbsFlag = false;
    }

    BbsDbView.prototype.printBbs = function(bbsList) {
      var section, topMost;
      if (bbsList !== null) {
        this.sectionToEmpty();
        section = window.viewerObj.html.window.document.getElementById("section");
        $.each(bbsList, (function(_this) {
          return function(index, value) {
            return $(section).append($("<div class=\"bbs\" id=\"" + bbsList[index]["id"] + "\">" + bbsList[index]["name"] + "</div>").click(function() {
              return _this.clickedBbs = {
                "name": bbsList[index]["name"],
                "url": bbsList[index]["url"]
              };
            }));
          };
        })(this));
        topMost = window.viewerObj.html.window.document.getElementById("top-most");
        return $(topMost).get(0).scrollIntoView(true);
      }
    };

    BbsDbView.prototype.showAddbbs = function() {
      var options, url;
      url = new window.air.URLRequest("../../haml/add_bbs.html");
      this.html = new window.air.HTMLLoader();
      this.html.load(url);
      options = new window.air.NativeWindowInitOptions();
      options.transparent = false;
      options.systemChrome = air.NativeWindowSystemChrome.STANDARD;
      options.type = window.air.NativeWindowType.NORMAL;
      this.addBbs = new window.air.NativeWindow(options);
      this.addBbs.title = "掲示板を追加";
      this.addBbs.width = 450;
      this.addBbs.height = 160;
      this.html.width = this.addBbs.width;
      this.html.height = this.addBbs.height;
      this.addBbs.stage.addChild(this.html);
      this.addBbs.stage.scaleMode = "noScale";
      this.addBbs.stage.align = "topLeft";
      this.showAddbbsFlag = true;
      this.addBbs.addEventListener("closing", this.addBbsClosingListener);
      return this.addBbs.activate();
    };

    BbsDbView.prototype.addBbsClosingListener = function(event) {
      this.addBbs.removeEventListener("closing", this.addBbsClosingListener);
      return this.showAddbbsFlag = false;
    };

    return BbsDbView;

  })(BaseView);

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.ConfigView = (function(superClass) {
    extend(ConfigView, superClass);

    function ConfigView() {
      this.restoreConfig = bind(this.restoreConfig, this);
      this.getConfigElements = bind(this.getConfigElements, this);
      this.applyHandler = bind(this.applyHandler, this);
      this.windowResizeHandler = bind(this.windowResizeHandler, this);
      this.windowClosingHandler = bind(this.windowClosingHandler, this);
      this.htmlCompleteHandler = bind(this.htmlCompleteHandler, this);
      this.showConfigWindow = bind(this.showConfigWindow, this);
      this.windowFlag = false;
    }

    ConfigView.prototype.showConfigWindow = function() {
      var options, url;
      url = new window.air.URLRequest("../../haml/config.html");
      this.html = new window.air.HTMLLoader();
      this.html.load(url);
      this.html.addEventListener(window.air.Event.COMPLETE, this.htmlCompleteHandler);
      options = new window.air.NativeWindowInitOptions();
      options.transparent = false;
      options.systemChrome = air.NativeWindowSystemChrome.STANDARD;
      options.type = window.air.NativeWindowType.NORMAL;
      this.window = new window.air.NativeWindow(options);
      this.window.title = "設定";
      this.window.width = 540;
      this.window.height = 420;
      this.html.width = this.window.width;
      this.html.height = this.window.height;
      this.window.stage.addChild(this.html);
      this.window.stage.scaleMode = "noScale";
      this.window.stage.align = "topLeft";
      this.window.addEventListener("resize", this.windowResizeHandler);
      this.window.addEventListener("closing", this.windowClosingHandler);
      this.windowFlag = true;
      return this.window.activate();
    };

    ConfigView.prototype.htmlCompleteHandler = function(event) {
      var apply;
      this.html.removeEventListener("complete", this.htmlCompleteHandler);
      this.fontList = this.html.window.document.getElementById("font-list");
      if (this.fontList != null) {
        this.fonts = window.air.Font.enumerateFonts(true);
        this.fonts.sortOn("fontName");
        $.each(this.fonts, (function(_this) {
          return function(index, value) {
            return $(_this.fontList).append("<option>" + _this.fonts[index]["fontName"] + "</option>");
          };
        })(this));
      }
      apply = this.html.window.document.getElementById("config-apply");
      if (apply != null) {
        apply.addEventListener("click", this.applyHandler);
      }
      return this.restoreConfig();
    };

    ConfigView.prototype.windowClosingHandler = function(event) {
      this.windowFlag = false;
      return this.window.removeEventListener("closing", this.windowClosingHandler);
    };

    ConfigView.prototype.windowResizeHandler = function() {
      this.html.width = this.window.width;
      return this.html.height = this.window.height;
    };

    ConfigView.prototype.applyHandler = function(event) {
      var jimakuRes, style;
      this.getConfigElements();
      style = {
        'font-family': this.fontFamily.value,
        'font-size': this.fontSize.value,
        'color': "#" + this.fontColor.value,
        '-webkit-text-stroke-width': this.fontStrokeWidth.value,
        '-webkit-text-stroke-color': "#" + this.fontStrokeColor.value
      };
      if (window.viewerObj.threadController != null) {
        if (window.viewerObj.threadController.jimakuRes != null) {
          jimakuRes = window.viewerObj.threadController.jimakuRes;
          $(jimakuRes).css(style);
        }
      }
      if (this.sample != null) {
        $(this.sample).css(style);
      }
      window.viewerObj.so.data.fontFamily = style["font-family"];
      window.viewerObj.so.data.fontSize = style["font-size"];
      window.viewerObj.so.data.color = style["color"];
      window.viewerObj.so.data.strokeWidth = style["-webkit-text-stroke-width"];
      return window.viewerObj.so.data.strokeColor = style["-webkit-text-stroke-color"];
    };

    ConfigView.prototype.getConfigElements = function() {
      this.sample = this.html.window.document.getElementById("font-sample");
      this.fontFamily = this.html.window.document.getElementById("font-list");
      this.fontSize = this.html.window.document.getElementById("font-size");
      this.fontColor = this.html.window.document.getElementById("font-color");
      this.fontStrokeWidth = this.html.window.document.getElementById("font-stroke-size");
      return this.fontStrokeColor = this.html.window.document.getElementById("font-stroke-color");
    };

    ConfigView.prototype.restoreConfig = function() {
      this.getConfigElements();
      if (window.viewerObj.so.data.fontFamily != null) {
        $(this.fontList).append("<option selected>" + window.viewerObj.so.data.fontFamily + "</option selected>");
        $(this.sample).css("font-family", window.viewerObj.so.data.fontFamily);
      }
      if (window.viewerObj.so.data.fontSize != null) {
        $(this.fontSize).val(window.viewerObj.so.data.fontSize);
        $(this.sample).css("font-size", window.viewerObj.so.data.fontSize);
      }
      if (window.viewerObj.so.data.color != null) {
        $(this.fontColor).val(window.viewerObj.so.data.color.replace(/#/, ''));
        $(this.sample).css("color", window.viewerObj.so.data.color);
      }
      if (window.viewerObj.so.data.strokeWidth != null) {
        $(this.fontStrokeWidth).val(window.viewerObj.so.data.strokeWidth);
        $(this.sample).css("-webkit-text-stroke-width", window.viewerObj.so.data.strokeWidth);
      }
      if (window.viewerObj.so.data.strokeColor != null) {
        $(this.fontStrokeColor).val(window.viewerObj.so.data.strokeColor.replace(/#/, ''));
        return $(this.sample).css("-webkit-text-stroke-color", window.viewerObj.so.data.strokeColor);
      }
    };

    return ConfigView;

  })(BaseView);

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.ThreadJimakuView = (function(superClass) {
    extend(ThreadJimakuView, superClass);

    function ThreadJimakuView(path) {
      this.windowClosedHandler = bind(this.windowClosedHandler, this);
      this.htmlResize = bind(this.htmlResize, this);
      this.saveSettings = bind(this.saveSettings, this);
      this.closed = bind(this.closed, this);
      this.create = bind(this.create, this);
      this.path = path;
      this.flag = false;
    }

    ThreadJimakuView.prototype.create = function() {
      var options, url;
      url = new window.air.URLRequest(this.path);
      this.html = new window.air.HTMLLoader();
      this.html.paintsDefaultBackground = false;
      this.html.scaleX = 1;
      this.html.scaleY = 1;
      this.html.load(url);
      options = new window.air.NativeWindowInitOptions();
      options.transparent = true;
      options.systemChrome = window.air.NativeWindowSystemChrome.NONE;
      options.type = window.air.NativeWindowType.NORMAL;
      this.jimaku = new window.air.NativeWindow(options);
      this.jimaku.title = "字幕";
      this.jimaku.addEventListener(window.air.Event.RESIZE, this.htmlResize);
      window.nativeWindow.addEventListener(window.air.Event.CLOSING, this.windowClosedHandler);
      this.html.width = this.jimaku.width;
      this.html.height = this.jimaku.height;
      this.jimaku.alwaysInFront = true;
      this.jimaku.stage.addChild(this.html);
      this.jimaku.stage.scaleMode = "noScale";
      return this.jimaku.stage.align = "topLeft";
    };

    ThreadJimakuView.prototype.activated = function() {
      if (!this.flag) {
        this.restoreSettings();
        this.jimaku.activate();
        return this.flag = true;
      }
    };

    ThreadJimakuView.prototype.closed = function() {
      if (this.flag) {
        this.saveSettings();
        this.jimaku.close();
        this.flag = false;
        return window.nativeWindow.removeEventListener(window.air.Event.CLOSING, this.windowClosedHandler);
      }
    };

    ThreadJimakuView.prototype.restoreSettings = function() {
      this.so = window.air.SharedObject.getLocal("superfoo");
      if ((this.so.data.jimakuX != null) && (this.so.data.jimakuY != null)) {
        this.jimaku.x = this.so.data.jimakuX;
        this.jimaku.y = this.so.data.jimakuY;
        this.jimaku.width = this.so.data.jimakuWidth;
        return this.jimaku.height = this.so.data.jimakuHeight;
      } else {
        this.jimaku.width = 800;
        return this.jimaku.height = 200;
      }
    };

    ThreadJimakuView.prototype.saveSettings = function() {
      this.so.data.jimakuX = this.jimaku.x;
      this.so.data.jimakuY = this.jimaku.y;
      this.so.data.jimakuWidth = this.jimaku.width;
      return this.so.data.jimakuHeight = this.jimaku.height;
    };

    ThreadJimakuView.prototype.htmlResize = function(event) {
      this.html.width = this.jimaku.width;
      return this.html.height = this.jimaku.height;
    };

    ThreadJimakuView.prototype.windowClosedHandler = function(event) {
      this.saveSettings();
      return window.air.NativeApplication.nativeApplication.exit();
    };

    ThreadJimakuView.prototype.getNowTime = function() {
      var clock, nowHour, nowMin, nowSec, nowTime;
      nowTime = new Date;
      nowHour = nowTime.getHours();
      nowMin = nowTime.getMinutes();
      nowSec = nowTime.getSeconds();
      if (nowMin < 10) {
        nowMin = "0" + nowMin;
      }
      if (nowSec < 10) {
        nowSec = "0" + nowSec;
      }
      return clock = nowHour + ":" + nowMin + ":" + nowSec;
    };

    return ThreadJimakuView;

  })(BaseView);

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.ThreadView = (function(superClass) {
    var links;

    extend(ThreadView, superClass);

    function ThreadView() {
      this.callNavigateToURL = bind(this.callNavigateToURL, this);
      this.addEventToLink = bind(this.addEventToLink, this);
      this.autoLink = bind(this.autoLink, this);
      return ThreadView.__super__.constructor.apply(this, arguments);
    }

    ThreadView.prototype.regex = /(f|h?)(t{1}tps?:\/\/[-a-zA-Z0-9@:%_\+.~?&\/\/=]+)/gi;

    links = [];

    ThreadView.prototype.autoLink = function(res) {
      var makeLink;
      makeLink = (function(_this) {
        return function(all, url, h, href) {
          var id;
          id = Math.floor(Math.random() * 100000000);
          _this.links.push({
            "id": id,
            "url": "h" + h
          });
          return "<a href=\"" + h + "\" id=\"" + id + "\">" + all + "</a>";
        };
      })(this);
      return res.replace(this.regex, makeLink);
    };

    ThreadView.prototype.addEventToLink = function() {
      return $.each(this.links, (function(_this) {
        return function(index, value) {
          var id;
          id = window.viewerObj.html.window.document.getElementById(_this.links[index]["id"]);
          return id.addEventListener("click", _this.callNavigateToURL(_this.links[index]["url"]));
        };
      })(this));
    };

    ThreadView.prototype.callNavigateToURL = function(url) {
      return (function(_this) {
        return function(event) {
          var urlReq;
          urlReq = new window.air.URLRequest(url);
          return window.air.navigateToURL(urlReq);
        };
      })(this);
    };

    ThreadView.prototype.printRes = function(res) {
      var bottomMost;
      this.links = [];
      $.each(res, (function(_this) {
        return function(index, value) {
          var section;
          section = window.viewerObj.html.window.document.getElementById("section");
          return $(section).append("<div class=\"res\">\n	<div class=\"res-head\">\n		<span class=\"res-no\">\n			" + res[index][0] + "\n		</span>\n		<span class=\"res-name\">\n			" + res[index][1] + "\n		</span>\n		<span class=\"res-date\">\n			" + res[index][3] + "\n		</span>\n	</div>\n	<div class=\"res-body\">\n		" + (_this.autoLink(res[index][4])) + "\n	</div>\n</div>");
        };
      })(this));
      this.addEventToLink();
      bottomMost = window.viewerObj.html.window.document.getElementById("bottom-most");
      return $(bottomMost)[0].scrollIntoView(false);
    };

    return ThreadView;

  })(BaseView);

}).call(this);

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Viewer = (function() {
    function Viewer() {
      this.configHandler = bind(this.configHandler, this);
      this.addBbsHandler = bind(this.addBbsHandler, this);
      this.getBbsHandler = bind(this.getBbsHandler, this);
      this.getThreadHandler = bind(this.getThreadHandler, this);
      this.clickThreadHandler = bind(this.clickThreadHandler, this);
      this.airHandler = bind(this.airHandler, this);
      this.pauseHandler = bind(this.pauseHandler, this);
      this.playHandler = bind(this.playHandler, this);
      this.htmlCompleteHandler = bind(this.htmlCompleteHandler, this);
      this.closeHandler = bind(this.closeHandler, this);
      this.htmlResize = bind(this.htmlResize, this);
      this.onResizeWindow = bind(this.onResizeWindow, this);
      this.loadViewerSection = bind(this.loadViewerSection, this);
      this.windowSettings = bind(this.windowSettings, this);
      this.switchButton = bind(this.switchButton, this);
      this.buttonStatus = {
        "play": false,
        "pause": false,
        "air": false,
        "get-thread": false,
        "get-bbs": false,
        "add-bbs": false,
        "jimaku": false
      };
      this.bbsDb = new BbsDb();
      this.bbsDb.connect();
      this.bbsDb.create();
      this.bbsDbView = new BbsDbView();
      this.bbsDbController = new BbsDbController(this.bbsDb, this.bbsDbView);
      this.configView = new ConfigView();
      this.configController = new ConfigController(this.configView);
    }

    Viewer.prototype.switchButton = function() {
      return $.each(this.buttonStatus, (function(_this) {
        return function(key, index) {
          var button;
          button = window.document.getElementById(key);
          if (_this.buttonStatus[key][index]) {
            return $(button).addClass("on");
          } else {
            return $(button).removeClass("on");
          }
        };
      })(this));
    };

    Viewer.prototype.windowSettings = function() {
      var taskBar, viewer;
      this.so = window.air.SharedObject.getLocal("superfoo");
      if ((this.so.data.appX != null) && (this.so.data.appY != null)) {
        window.nativeWindow.x = this.so.data.appX;
        window.nativeWindow.y = this.so.data.appY;
        window.nativeWindow.width = this.so.data.appWidth;
        window.nativeWindow.height = this.so.data.appHeight;
      }
      if (this.so.data.bbsTitle) {
        this.bbsTitle.innerHTML = this.so.data.bbsTitle;
      }
      window.nativeWindow.visible = true;
      if (this.so.data.bbsUrl) {
        $(this.url).val(this.so.data.bbsUrl);
      } else {
        $(this.url).val("http://jbbs.shitaraba.net/computer/10298/");
      }
      taskBar = window.document.getElementById("task-bar");
      taskBar.addEventListener("mousedown", this.omMoveWindow);
      viewer = window.document.getElementById("arrows");
      viewer.addEventListener("mousedown", this.onResizeWindow);
      return window.nativeWindow.stage.addEventListener(window.air.Event.CLOSING, this.closeHandler);
    };

    Viewer.prototype.loadViewerSection = function() {
      var url;
      url = new window.air.URLRequest("../haml/viewer_section.html");
      this.html = new window.air.HTMLLoader();
      this.html.scaleX = 1;
      this.html.scaleY = 1;
      this.html.load(url);
      this.html.width = window.nativeWindow.width - 20;
      this.html.height = window.nativeWindow.height - 80;
      this.html.x = 10;
      this.html.y = 65;
      window.nativeWindow.addEventListener(window.air.Event.RESIZE, this.htmlResize);
      window.nativeWindow.stage.addChild(this.html);
      window.nativeWindow.stage.scaleMode = "noScale";
      window.nativeWindow.stage.align = "topLeft";
      return this.html.addEventListener("complete", this.htmlCompleteHandler);
    };

    Viewer.prototype.omMoveWindow = function(event) {
      return window.nativeWindow.startMove();
    };

    Viewer.prototype.onResizeWindow = function(event) {
      return window.nativeWindow.startResize("BR");
    };

    Viewer.prototype.htmlResize = function(event) {
      this.html.width = window.nativeWindow.width - 20;
      return this.html.height = window.nativeWindow.height - 80;
    };

    Viewer.prototype.setTaskBarListener = function() {
      var close, minimize;
      close = window.document.getElementById("close");
      close.addEventListener("click", this.closeHandler);
      minimize = window.document.getElementById("minimize");
      return minimize.addEventListener("click", this.minimizeHandler);
    };

    Viewer.prototype.closeHandler = function(event) {
      var so;
      so = window.air.SharedObject.getLocal("superfoo");
      so.data.appX = window.nativeWindow.x;
      so.data.appY = window.nativeWindow.y;
      so.data.appWidth = window.nativeWindow.width;
      so.data.appHeight = window.nativeWindow.height;
      if (this.buttonStatus["jimaku"]) {
        this.threadController.jimakuView.saveSettings();
      }
      return window.air.NativeApplication.nativeApplication.exit();
    };

    Viewer.prototype.minimizeHandler = function(event) {
      return window.nativeWindow.minimize();
    };

    Viewer.prototype.htmlCompleteHandler = function() {
      if ($(this.url).val()) {
        return this.getThreadHandler();
      }
    };

    Viewer.prototype.setNavListener = function() {
      this.play = window.document.getElementById("play");
      this.play.addEventListener("click", this.playHandler);
      this.pause = window.document.getElementById("pause");
      this.pause.addEventListener("click", this.pauseHandler);
      this.air = window.document.getElementById("air");
      this.air.addEventListener("click", this.airHandler);
      this.getThread = window.document.getElementById("get-thread");
      this.getThread.addEventListener("click", this.getThreadHandler);
      this.getBbs = window.document.getElementById("get-bbs");
      this.getBbs.addEventListener("click", this.getBbsHandler);
      this.addBbs = window.document.getElementById("add-bbs");
      this.addBbs.addEventListener("click", this.addBbsHandler);
      this.config = window.document.getElementById("config");
      this.config.addEventListener("click", this.configHandler);
      this.url = window.document.getElementById("url");
      return this.bbsTitle = window.document.getElementById("bbs-title");
    };

    Viewer.prototype.playHandler = function() {
      if ((this.threadController != null) && !this.threadController.resLoadFlag) {
        this.threadController.resLoadFlag = true;
        this.threadController.resLoadOn();
        $(this.play).addClass("on");
        return $(this.pause).removeClass("on");
      }
    };

    Viewer.prototype.pauseHandler = function() {
      if ((this.threadController != null) && this.threadController.resLoadFlag) {
        this.threadController.resLoadFlag = false;
        this.threadController.resLoadOff();
        $(this.play).removeClass("on");
        return $(this.pause).addClass("on");
      }
    };

    Viewer.prototype.airHandler = function() {
      if (this.buttonStatus["jimaku"]) {
        this.threadController.switchClassAir();
        if (this.threadController.airFlag) {
          $("#air").addClass("on");
          return this.buttonStatus["air"] = true;
        } else {
          $("#air").removeClass("on");
          return this.buttonStatus["air"] = false;
        }
      }
    };

    Viewer.prototype.clickThreadHandler = function() {
      var res;
      this.thread = new Thread(this.bbsView.clickedThread, this.bbs.url);
      this.threadView = new ThreadView();
      this.threadView.sectionToEmpty();
      res = this.thread.getRes();
      this.threadView.printRes(res);
      this.jimakuView = new ThreadJimakuView("../haml/jimaku.html");
      this.jimakuView.create();
      this.jimakuView.activated();
      this.buttonStatus["jimaku"] = true;
      return this.threadController = new ThreadController(this.thread, this.threadView, this.jimakuView);
    };

    Viewer.prototype.getThreadHandler = function() {
      if (this.buttonStatus["jimaku"]) {
        this.threadController.jimakuView.closed();
        this.threadController.jimakuClockOff();
        this.buttonStatus["jimaku"] = false;
        $(this.air).removeClass("on");
      }
      this.pauseHandler();
      this.bbs = new Bbs($(this.url).val());
      this.bbsView = new BbsView(this.bbs, this.bbsDb);
      this.bbsView.printSubject();
      return this.so.data.bbsUrl = $(this.url).val();
    };

    Viewer.prototype.getBbsHandler = function() {
      return this.bbsDbController.getBbsList();
    };

    Viewer.prototype.addBbsHandler = function() {
      return this.bbsDbController.getAddBbs();
    };

    Viewer.prototype.configHandler = function() {
      return this.configController.getConfig();
    };

    return Viewer;

  })();

}).call(this);
