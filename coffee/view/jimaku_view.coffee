class window.JimakuView extends BaseView
	# air Airインスタンス
	# jimaku 字幕ウィンドウインスタンス
	# path jimaku.htmlファイルへのパス
	# clickedThread クリックされたスレタイとスレ番号
	# flag 字幕のOn、Off状態を保持
	# subject 字幕タイトルエレメント

	constructor: (air, path) ->
		@air = air
		@path = path
		@flag = false

	# 字幕を生成
	create: ->
		# jimaku.htmlを取得
		url = new @air.URLRequest(@path)
		@html = new @air.HTMLLoader()
		# HTMLLoaderの透過
		@html.paintsDefaultBackground = false
		@html.scaleX = 1
		@html.scaleY = 1
		@html.load(url)
		# 読み込み完了時のイベント
		@html.addEventListener("complete", @completeHandler)

		options = new @air.NativeWindowInitOptions()
		options.transparent = true
		options.systemChrome = @air.NativeWindowSystemChrome.NONE
		# 透過無効
		# options.transparent = false
		# options.systemChrome = air.NativeWindowSystemChrome.STANDARD
		options.type = @air.NativeWindowType.NORMAL

		@jimaku = new @air.NativeWindow(options)
		@jimaku.title = "字幕"
		@jimaku.width = 800
		@jimaku.height = 200

		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = @jimaku.width
		@html.height = @jimaku.height
		# 最前面表示
		@jimaku.alwaysInFront  = true
		@jimaku.stage.addChild(@html)
		@jimaku.stage.scaleMode = "noScale"
		@jimaku.stage.align = "topLeft"

	# HTML読み込み完了時に呼ぶハンドラ
	completeHandler: =>
		@subject = @html.window.document.getElementById("jimaku-subject")
		@subject.addEventListener("mousedown", @onMoveJimaku, true)

	# 字幕移動ハンドラ
	onMoveJimaku: (event) =>
		@jimaku.startMove()
		# @air.Introspector.Console.log(@jimaku)

	# 字幕をアクティベイト
	activate: ->
		@jimaku.activate()
		@flag = true

	# 字幕を閉じる
	close: ->
		@jimaku.close()
		@flag = false
