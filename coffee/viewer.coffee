# window.air.Introspector.Console.log()
# viewerObj = null


# viewer初期化(Gruntコンパイラの影響でviewer.hamlに移動)
# viewerIniInitialize = =>
# 	@viewerObj = new window.Viewer()
# 	@viewerObj.setNavListener()
# 	@viewerObj.setTaskBarListener()
# 	@viewerObj.windowSettings()
# 	@viewerObj.loadViewerSection()

class window.Viewer
	# buttonStatus ボタンの状態を持つ連想配列
	# html HTMLLoaderインスタンスviewer_section.html

	constructor: ->
		@buttonStatus =
			"play": false
			"pause": false
			"air": false
			"get-thread": false
			"get-bbs": false
			"add-bbs": false
			"jimaku": false
		# 掲示板データベースに接続
		@bbsDb = new BbsDb()
		@bbsDb.connect()
		@bbsDb.create()
		@bbsDbView = new BbsDbView()
		@bbsDbController = new BbsDbController(@bbsDb, @bbsDbView)
		# 設定ウィンドウ系インスタンス
		@configView = new ConfigView()
		@configController = new ConfigController(@configView)

	# ボタンの状態を切り替える
	switchButton: =>
		$.each @buttonStatus, (key, index) =>
			button = window.document.getElementById(key)
			if @buttonStatus[key][index]
				$(button).addClass("on")
			else
				$(button).removeClass("on")

	# window設定読み込み
	windowSettings: =>
		@so = window.air.SharedObject.getLocal("superfoo")
		# ウィンドウサイズ位置の復帰
		if @so.data.appX? && @so.data.appY?
			window.nativeWindow.x = @so.data.appX
			window.nativeWindow.y = @so.data.appY
			window.nativeWindow.width = @so.data.appWidth
			window.nativeWindow.height = @so.data.appHeight
		# 前回開いた掲示板名をセット
		# if @so.data.bbsTitle
			# @bbsTitle.innerHTML = @so.data.bbsTitle
		# ウィンドウを表示
		window.nativeWindow.visible = true
		# URLを復帰
		if @so.data.bbsUrl
			$(@url).val(@so.data.bbsUrl)
		else
			# したらば助け合い掲示板
			$(@url).val("http://jbbs.shitaraba.net/computer/10298/")
		# タスクバーの移動イベント
		# taskBar = window.document.getElementById("task-bar")
		# taskBar.addEventListener("mousedown", @omMoveWindow)
		# viewerのリサイズイベント
		# viewer = window.document.getElementById("arrows")
		# viewer.addEventListener("mousedown", @onResizeWindow)
		# ウィンドウを閉じた時
		window.nativeWindow.addEventListener(window.air.Event.CLOSING, @closeHandler)
		# ウィンドウを閉じた時(非systemChrome.none時)
		# window.nativeWindow.stage.addEventListener(window.air.Event.CLOSING, @closeHandler)

	# viewer_section.htmlの読み込み
	loadViewerSection: =>
		url = new window.air.URLRequest("../haml/viewer_section.html")
		@html = new window.air.HTMLLoader()
		@html.scaleX = 1
		@html.scaleY = 1
		# @html.navigateInSystemBrowser = true
		@html.load(url)

		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = window.nativeWindow.width
		@html.height = window.nativeWindow.height - 67
		@html.x = 0
		@html.y = 45

		# viewerウィンドウがリサイズされた時のイベント
		window.nativeWindow.addEventListener(window.air.Event.RESIZE, @htmlResize)
		window.nativeWindow.stage.addChild(@html)
		window.nativeWindow.stage.scaleMode = "noScale"
		window.nativeWindow.stage.align = "topLeft"
		@html.addEventListener("complete", @htmlCompleteHandler)

	# viewerウィンドウムーブハンドラ
	omMoveWindow: (event) ->
		window.nativeWindow.startMove()

	# viewerウィンドウリサイズハンドラ
	onResizeWindow: (event) =>
		window.nativeWindow.startResize("BR")

	# viewerウィンドウリサイズイベントハンドラ
	htmlResize: (event) =>
		# HTMLLoaderのサイズをviewerウィンドウに合わせる
		@html.width = window.nativeWindow.width
		@html.height = window.nativeWindow.height - 67

	# タスクバーにイベントリスナーをセット
	setTaskBarListener: ->
		# 閉じる
		close = window.document.getElementById("close")
		close.addEventListener "click", @closeHandler
		# 最小化
		minimize = window.document.getElementById("minimize")
		minimize.addEventListener "click", @minimizeHandler
		# 最大化
		maximize = window.document.getElementById("maximize")
		maximize.addEventListener "click", maximizeHandler

	closeHandler: (event) =>
		# ウィンドウサイズ位置を保存
		# viewerウィンドウ
		so = window.air.SharedObject.getLocal("superfoo")
		so.data.appX = window.nativeWindow.x
		so.data.appY = window.nativeWindow.y
		so.data.appWidth = window.nativeWindow.width
		so.data.appHeight = window.nativeWindow.height
		# 字幕
		if @buttonStatus["jimaku"]
			@threadController.jimakuView.saveSettings()
		# アプリケーションを終了
		window.air.NativeApplication.nativeApplication.exit()

	# 最小化ハンドラ
	minimizeHandler: (event) ->
		window.nativeWindow.minimize()

	# 最大化ハンドラ
	maximizeHandler = (event) ->
		window.nativeWindow.maximize()

	# viewer_section.html読み込み完了時
	htmlCompleteHandler: =>
		if $(@url).val()
			@getThreadHandler()

	# ナビバーにイベントリスナーをセット
	setNavListener: ->
		@play = window.document.getElementById("play")
		@play.addEventListener "click", @playHandler
		@pause = window.document.getElementById("pause")
		@pause.addEventListener "click", @pauseHandler
		@air = window.document.getElementById("air")
		@air.addEventListener "click", @airHandler
		@getThread = window.document.getElementById("get-thread")
		@getThread.addEventListener "click", @getThreadHandler
		@getBbs = window.document.getElementById("get-bbs")
		@getBbs.addEventListener "click", @getBbsHandler
		@addBbs = window.document.getElementById("add-bbs")
		@addBbs.addEventListener "click", @addBbsHandler
		@config = window.document.getElementById("config")
		@config.addEventListener "click", @configHandler
		@url = window.document.getElementById("url")
		# @bbsTitle = window.document.getElementById("bbs-title")

	playHandler: =>
		if @threadController? && !@threadController.resLoadFlag
			# 自動更新ON
			@threadController.resLoadFlag = true
			@threadController.resLoadOn()
			$(@play).addClass("on")
			$(@pause).removeClass("on")

	pauseHandler: =>
		# 自動更新がONか？
		if @threadController? && @threadController.resLoadFlag
			# 自動更新OFF
			@threadController.resLoadFlag = false
			@threadController.resLoadOff()
			$(@play).removeClass("on")
			$(@pause).addClass("on")

	airHandler: =>
		if @buttonStatus["jimaku"]
			@threadController.switchClassAir()
			if @threadController.airFlag
				$("#air").addClass("on")
				@buttonStatus["air"] = true
			else
				$("#air").removeClass("on")
				@buttonStatus["air"] = false

	# スレッド選択時のハンドラ
	# BbsView.printSubjectからの呼び出し
	clickThreadHandler: =>
		# スレッドの処理系インスタンスの生成
		@thread = new Thread(@bbsView.clickedThread, @bbs.url)
		# スレッドの表示系インスタンスを生成
		@threadView = new ThreadView()
		# sectionタグを空に
		@threadView.sectionToEmpty()
		# レスを取得
		res = @thread.getRes()
		# レスを表示
		@threadView.printRes(res)

		# 字幕の表示系インスタンスを生成
		@jimakuView = new ThreadJimakuView("../haml/jimaku.html")
		# 字幕を生成
		@jimakuView.create()
		@jimakuView.activated()
		# 字幕表示フラグをON
		@buttonStatus["jimaku"] = true

		# ThreadControllerを生成
		@threadController = new ThreadController(@thread, @threadView, @jimakuView)

	# スレッド一覧取得ハンドラ
	getThreadHandler: =>
		# 字幕が表示中か？
		if @buttonStatus["jimaku"]
			# 字幕を閉じる
			@threadController.jimakuView.closed()
			# 字幕の時計を止める
			@threadController.jimakuClockOff()
			@buttonStatus["jimaku"] = false
			$(@air).removeClass("on")

		# 自動更新OFF
		@pauseHandler()
		# 掲示板の処理系インスタンスを生成
		@bbs = new Bbs($(@url).val())
		# 掲示板の表示系インスタンスを生成
		@bbsView = new BbsView(@bbs, @bbsDb)
		# スレッド一覧を描画
		@bbsView.printSubject()
		# URLを保存
		@so.data.bbsUrl = $(@url).val()

	getBbsHandler: =>
		@bbsDbController.getBbsList()

	addBbsHandler: =>
		@bbsDbController.getAddBbs()

	configHandler: =>
		@configController.getConfig()
