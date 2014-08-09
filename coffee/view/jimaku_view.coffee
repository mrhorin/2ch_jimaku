class JimakuView extends BaseView
	# air Airインスタンス
	# path jimaku.htmlファイルへのパス
	# flag 字幕のOn、Off状態を保持

	constructor: (air, path) ->
		@air = air
		@path = path
		@flag = false

	# 字幕を生成
	create: ->
		# jimaku.htmlを取得
		url = new @air.URLRequest(@path)
		html = new @air.HTMLLoader()
		# HTMLLoaderの透過
		html.paintsDefaultBackground = false
		html.scaleX = 1
		html.scaleY = 1
		html.load(url)
		options = new @air.NativeWindowInitOptions()
		# options.transparent = false
		# options.systemChrome = air.NativeWindowSystemChrome.STANDARD
		options.transparent = true
		options.systemChrome = @air.NativeWindowSystemChrome.NONE
		options.type = @air.NativeWindowType.NORMAL
		@jimaku = new @air.NativeWindow(options)
		@jimaku.title = "字幕"
		@jimaku.width = 800
		@jimaku.height = 200
		# HTMLLoaderのサイズをNativeWindowに合わせる
		html.width = @jimaku.width
		html.height = @jimaku.height
		# 最前面表示
		@jimaku.alwaysInFront  = true
		@jimaku.stage.addChild(html)
		@jimaku.stage.scaleMode = "noScale"
		@jimaku.stage.align = "topLeft"

	activate: ->
		@jimaku.activate()
		@flag = true

	# 字幕を閉じる
	close: ->
		@jimaku.close()
		@flag = false
