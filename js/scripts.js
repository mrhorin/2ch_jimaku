// Generated by CoffeeScript 1.7.1
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

window.ThreadController = (function() {
  function ThreadController(thread, threadView, jimakuView) {
    this.resLoadOff = __bind(this.resLoadOff, this);
    this.resLoadOn = __bind(this.resLoadOn, this);
    this.printSubjectToJimaku = __bind(this.printSubjectToJimaku, this);
    this.onMoveJimaku = __bind(this.onMoveJimaku, this);
    this.jimakuCompleteHandler = __bind(this.jimakuCompleteHandler, this);
    this.thread = thread;
    this.threadView = threadView;
    this.jimakuView = jimakuView;
    this.resLoadTimer = null;
    this.jimakuInitialize();
  }

  ThreadController.prototype.jimakuInitialize = function() {
    return this.jimakuView.html.addEventListener("complete", this.jimakuCompleteHandler);
  };

  ThreadController.prototype.jimakuCompleteHandler = function() {
    this.subject = this.jimakuView.html.window.document.getElementById("jimaku-subject");
    this.subject.addEventListener("mousedown", this.onMoveJimaku, true);
    return this.printSubjectToJimaku(this.subject);
  };

  ThreadController.prototype.onMoveJimaku = function(event) {
    return this.jimakuView.jimaku.startMove();
  };

  ThreadController.prototype.printSubjectToJimaku = function(subject) {
    return subject.innerHTML = this.thread.clickedThread["title"];
  };

  ThreadController.prototype.resLoadOn = function() {
    return this.resLoadTimer = setInterval((function(_this) {
      return function() {
        var res;
        res = _this.thread.getRes();
        if (res) {
          return _this.threadView.printRes(res);
        }
      };
    })(this), 7000);
  };

  ThreadController.prototype.resLoadOff = function() {
    return clearInterval(this.resLoadTimer);
  };

  return ThreadController;

})();

$(function() {
  return $("#get-thread").click(function() {
    var bbs, bbsView;
    $("#play").attr('disabled', true);
    bbs = new Bbs($("#url").val());
    bbsView = new BbsView(bbs);
    bbsView.printSubject();
    return $(".thread").click((function(_this) {
      return function() {
        var jimakuView, res, thread, threadController, threadView;
        $("#play").attr('disabled', false);
        $("#play").removeAttr('disabled');
        thread = new Thread(bbsView.clickedThread, bbs.url);
        threadView = new ThreadView();
        threadView.sectionToEmpty();
        res = thread.getRes();
        threadView.printRes(res);
        jimakuView = new ThreadJimakuView(air, "../haml/jimaku.html");
        jimakuView.create();
        jimakuView.activate();
        jimakuView.close();
        threadController = new ThreadController(thread, threadView, jimakuView);
        $("#play").click(function() {
          if (!thread.resLoadFlag) {
            thread.resLoadFlag = true;
            threadController.resLoadOn();
            return $("#play").addClass("on");
          }
        });
        return $("#pause,#get-thread").click(function() {
          if (thread.resLoadFlag) {
            thread.resLoadFlag = false;
            threadController.resLoadOff();
            return $("#play").removeClass("on");
          }
        });
      };
    })(this));
  });
});

window.Bbs = (function() {
  function Bbs(url) {
    this.subjectsToArray = __bind(this.subjectsToArray, this);
    this.getSubjects = __bind(this.getSubjects, this);
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

window.Thread = (function() {
  function Thread(clickedThread, bbsUrl) {
    this.getRes = __bind(this.getRes, this);
    this.clickedThread = clickedThread;
    this.clickedThread["ReqUrl"] = "http://" + bbsUrl["domain"] + "/bbs/rawmode.cgi/" + bbsUrl["category"] + "/" + bbsUrl["address"] + "/" + clickedThread["number"] + "/";
    this.bbsUrl = bbsUrl;
    this.resLoadFlag = false;
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
      error: function() {
        return alert("スレッド読み込みエラー");
      }
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
        var i, _i, _results;
        _this.res[index] = [];
        value = value.split("<>");
        _results = [];
        for (i = _i = 0; _i <= 4; i = ++_i) {
          _results.push(_this.res[index][i] = value[i]);
        }
        return _results;
      };
    })(this));
  };

  Thread.prototype.loadOn = function() {
    return this.resLoadFlag = true;
  };

  Thread.prototype.loadOff = function() {
    return this.resLoadFlag = false;
  };

  return Thread;

})();

window.BaseView = (function() {
  function BaseView() {}

  BaseView.prototype.sectionToEmpty = function() {
    return $("section").empty();
  };

  return BaseView;

})();

window.BbsView = (function(_super) {
  __extends(BbsView, _super);

  function BbsView(bbs) {
    this.printSubject = __bind(this.printSubject, this);
    this.subjects = bbs.subjects;
    this.url = bbs.url;
  }

  BbsView.prototype.printSubject = function() {
    this.sectionToEmpty();
    $.each(this.subjects, (function(_this) {
      return function(index, value) {
        return $("section").append($("<div class=\"thread\">" + _this.subjects[index]["title"] + "</div>").click(function() {
          return _this.clickedThread = {
            "title": _this.subjects[index]["title"],
            "number": _this.subjects[index]["number"]
          };
        }));
      };
    })(this));
    $(".thread:odd").addClass("odd");
    return $(".thread:even").addClass("even");
  };

  return BbsView;

})(BaseView);

window.ThreadView = (function(_super) {
  __extends(ThreadView, _super);

  function ThreadView() {
    return ThreadView.__super__.constructor.apply(this, arguments);
  }

  ThreadView.prototype.printRes = function(res) {
    return $.each(res, function(index, value) {
      return $("section").append("<div class=\"res\">\n	<div class=\"res-head\">\n		<span class=\"res-no\">\n			" + res[index][0] + "\n		</span>\n		<span class=\"res-name\">\n			" + res[index][1] + "\n		</span>\n		<span class=\"res-date\">\n			" + res[index][3] + "\n		</span>\n	</div>\n	<div class=\"res-body\">\n		" + res[index][4] + "\n	</div>\n</div>");
    });
  };

  return ThreadView;

})(BaseView);

window.ThreadJimakuView = (function(_super) {
  __extends(ThreadJimakuView, _super);

  function ThreadJimakuView(air, path) {
    this.air = air;
    this.path = path;
    this.flag = false;
  }

  ThreadJimakuView.prototype.create = function() {
    var options, url;
    url = new this.air.URLRequest(this.path);
    this.html = new this.air.HTMLLoader();
    this.html.paintsDefaultBackground = false;
    this.html.scaleX = 1;
    this.html.scaleY = 1;
    this.html.load(url);
    options = new this.air.NativeWindowInitOptions();
    options.transparent = true;
    options.systemChrome = this.air.NativeWindowSystemChrome.NONE;
    options.type = this.air.NativeWindowType.NORMAL;
    this.jimaku = new this.air.NativeWindow(options);
    this.jimaku.title = "字幕";
    this.jimaku.width = 800;
    this.jimaku.height = 200;
    this.html.width = this.jimaku.width;
    this.html.height = this.jimaku.height;
    this.jimaku.alwaysInFront = true;
    this.jimaku.stage.addChild(this.html);
    this.jimaku.stage.scaleMode = "noScale";
    return this.jimaku.stage.align = "topLeft";
  };

  ThreadJimakuView.prototype.activate = function() {
    this.jimaku.activate();
    return this.flag = true;
  };

  ThreadJimakuView.prototype.close = function() {
    alert("close");
    this.jimaku.close();
    return this.flag = false;
  };

  return ThreadJimakuView;

})(BaseView);
