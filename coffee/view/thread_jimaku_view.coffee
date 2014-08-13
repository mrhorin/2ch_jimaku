class window.ThreadJimakuView extends BaseView
	# jimaku 字幕ウィンドウインスタンス
	# path jimaku.htmlファイルへのパス
	# clickedThread クリックされたスレタイとスレ番号
	# flag 字幕のOn、Off状態を保持

	constructor: (path) ->
		@path = path
		@flag = false

	# 字幕を生成
	create: ->
		# jimaku.htmlを取得
		url = new window.air.URLRequest(@path)
		@html = new window.air.HTMLLoader()
		# HTMLLoaderの透過
		@html.paintsDefaultBackground = false
		@html.scaleX = 1
		@html.scaleY = 1
		@html.load(url)

		options = new window.air.NativeWindowInitOptions()
		# 透過にする
		options.transparent = true
		options.systemChrome = window.air.NativeWindowSystemChrome.NONE
		# 透過無効
		# options.transparent = false
		# options.systemChrome = air.NativeWindowSystemChrome.STANDARD
		options.type = window.air.NativeWindowType.NORMAL

		@jimaku = new window.air.NativeWindow(options)
		@jimaku.title = "字幕"
		@jimaku.width = 800
		@jimaku.height = 200
		@jimaku.addEventListener(window.air.Event.RESIZE, @htmlResize)

		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = @jimaku.width
		@html.height = @jimaku.height
		# 最前面表示
		@jimaku.alwaysInFront  = true
		@jimaku.stage.addChild(@html)
		@jimaku.stage.scaleMode = "noScale"
		@jimaku.stage.align = "topLeft"

	# 字幕をアクティベイト
	activate: ->
		@jimaku.activate()
		@flag = true

	# 字幕を閉じる
	close: ->
		@jimaku.close()
		@flag = false

	# jimakuウィンドウリサイズイベントハンドラ
	htmlResize: (event) =>
		# HTMLLoaderのサイズをjimakuに合わせる
		@html.width = @jimaku.width
		@html.height = @jimaku.height

	# 字幕タイトル表示用の現在時刻を取得する
	getNowTime: ->
		# 現在時刻を取得
		nowTime = new Date
		nowHour = nowTime.getHours()
		nowMin = nowTime.getMinutes()
		nowSec = nowTime.getSeconds()
		if nowMin < 10
			nowMin = "0" + nowMin
		if nowSec < 10
			nowSec = "0" + nowSec
		clock = nowHour + ":" + nowMin + ":" + nowSec