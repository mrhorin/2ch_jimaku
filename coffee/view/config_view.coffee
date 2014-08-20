class window.ConfigView extends BaseView

	# コンフィグウィンドウを表示
	showConfigWindow: =>
		# config.htmlを取得
		url = new window.air.URLRequest("../../haml/config.html")
		@html = new window.air.HTMLLoader()
		@html.load(url)
		@html.addEventListener(window.air.Event.COMPLETE, @htmlCompleteHandler)

		options = new window.air.NativeWindowInitOptions()
		# 透過無効
		options.transparent = false
		options.systemChrome = air.NativeWindowSystemChrome.STANDARD
		options.type = window.air.NativeWindowType.NORMAL

		# 設定用ウィンドウの生成
		@window = new window.air.NativeWindow(options)
		@window.title = "設定"
		@window.width = 540
		@window.height = 420

		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = @window.width
		@html.height = @window.height
		# 最前面表示
		# @window.alwaysInFront  = true
		@window.stage.addChild(@html)
		@window.stage.scaleMode = "noScale"
		@window.stage.align = "topLeft"
		@window.addEventListener("resize", @windowResizeHandler)
		@window.activate()

	htmlCompleteHandler: (event) =>
		@html.removeEventListener("complete", @htmlCompleteHandler)
		# インストールされたフォント一覧を取得
		@fontList = @html.window.document.getElementById("font-list")
		if @fontList?
			@fonts = window.air.Font.enumerateFonts(true)
			@fonts.sortOn("fontName")
			# 表示
			$.each @fonts, (index,value) =>
				$(@fontList).append(
					"<option>"+
					@fonts[index]["fontName"]+
					"</option>"
				)

		# # 適用ボタンにイベントを追加
		apply = @html.window.document.getElementById("config-apply")
		if apply?
			apply.addEventListener("click", @applyHandler)

		@restoreConfig()

	# 適用ボタンハンドラ
	applyHandler: (event) =>
		@getConfigElements()
		style =
			'font-family':@fontFamily.value
			'font-size':@fontSize.value
			'color':"##{@fontColor.value}"
			'-webkit-text-stroke-width':@fontStrokeWidth.value
			'-webkit-text-stroke-color':"##{@fontStrokeColor.value}"

		# 字幕に設定を適用
		if window.viewerObj.threadController?
			if window.viewerObj.threadController.jimakuRes?
				jimakuRes = window.viewerObj.threadController.jimakuRes
				$(jimakuRes).css(style)

		# サンプル文字に設定を適用
		if @sample?
			$(@sample).css(style)

		# 適用した値を保存
		window.viewerObj.so.data.fontFamily = style["font-family"]
		window.viewerObj.so.data.fontSize = style["font-size"]
		window.viewerObj.so.data.color = style["color"]
		window.viewerObj.so.data.strokeWidth = style["-webkit-text-stroke-width"]
		window.viewerObj.so.data.strokeColor = style["-webkit-text-stroke-color"]

	# 入力欄のエレメントを取得
	getConfigElements: =>
		# サンプル文字
		@sample = @html.window.document.getElementById("font-sample")
		# 選択されたフォント
		@fontFamily = @html.window.document.getElementById("font-list")
		# フォントサイズ
		@fontSize = @html.window.document.getElementById("font-size")
		# フォントカラー
		@fontColor = @html.window.document.getElementById("font-color")
		# 文字縁取りサイズ
		@fontStrokeWidth = @html.window.document.getElementById("font-stroke-size")
		# 文字縁取りカラー
		@fontStrokeColor = @html.window.document.getElementById("font-stroke-color")

	# 設定を復帰
	restoreConfig: =>
		@getConfigElements()
		# フォント
		if window.viewerObj.so.data.fontFamily?
			$(@fontList).append("<option selected>#{window.viewerObj.so.data.fontFamily}</option selected>")
			$(@sample).css("font-family", window.viewerObj.so.data.fontFamily)
		# フォントサイズ
		if window.viewerObj.so.data.fontSize?
			$(@fontSize).val(window.viewerObj.so.data.fontSize)
			$(@sample).css("font-size", window.viewerObj.so.data.fontSize)
		# フォントカラー
		if window.viewerObj.so.data.color?
			$(@fontColor).val(window.viewerObj.so.data.color.replace(/#/,''))
			$(@sample).css("color", window.viewerObj.so.data.color)
		# 縁取りサイズ
		if window.viewerObj.so.data.strokeWidth?
			$(@fontStrokeWidth).val(window.viewerObj.so.data.strokeWidth)
			$(@sample).css("-webkit-text-stroke-width", window.viewerObj.so.data.strokeWidth)
		# 縁取りカラー
		if window.viewerObj.so.data.strokeColor?
			$(@fontStrokeColor).val(window.viewerObj.so.data.strokeColor.replace(/#/,''))
			$(@sample).css("-webkit-text-stroke-color", window.viewerObj.so.data.strokeColor)

	windowResizeHandler: =>
		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = @window.width
		@html.height = @window.height