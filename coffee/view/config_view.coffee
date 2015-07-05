class window.ConfigView extends BaseView
	# windowFlag ウィンドウが開いているかフラグ

	constructor: ->
		@windowFlag = false

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
		@window.addEventListener("closing", @windowClosingHandler)
		@windowFlag = true
		@window.activate()

	# 設定ウィンドウ読み込み完了ハンドラ
	htmlCompleteHandler: (event) =>
		@html.removeEventListener("complete", @htmlCompleteHandler)
		# フォント一覧プルダウンリスト
		@fontList = @html.window.document.getElementById("font-list")

		if @fontList?
			# ゴシック系
			$(@fontList).append("<option>"+"sans-serif"+"</option>")
			# 明朝系
			$(@fontList).append("<option>"+"serif"+"</option>")
			# 筆記体
			$(@fontList).append("<option>"+"cursive"+"</option>")
			# 装飾系
			$(@fontList).append("<option>"+"fantasy"+"</option>")
			# 等幅系
			$(@fontList).append("<option>"+"monospace"+"</option>")

			# インストールされたフォント一覧を取得
			@fonts = window.air.Font.enumerateFonts(true)
			@fonts.sortOn("fontName")
			# ヒラギノフォントの一覧
			hiraginoFontList =
				"ヒラギノ角ゴ Pro W3": "Hiragino Kaku Gothic Pro"
				"ヒラギノ角ゴ ProN W3": "Hiragino Kaku Gothic ProN"
				"ヒラギノ明朝 Pro W3": "Hiragino Mincho Pro"
				"ヒラギノ明朝 ProN W3": "Hiragino Mincho ProN"
				"ヒラギノ丸ゴ Pro W4": "Hiragino Maru Gothic Pro"
				"ヒラギノ丸ゴ ProN W4": "Hiragino Maru Gothic ProN"
			# フォント一覧プルダウンに追加
			$.each @fonts, (index,value) =>
				font = @fonts[index]["fontName"]
				# フォント一覧を追加
				$(@fontList).append(
					"<option>"+
					@fonts[index]["fontName"]+
					"</option>"
				)
				# ヒラギノフォントリストと照合
				for hiraginoName, hiraginoFont of hiraginoFontList
					# window.air.Introspector.Console.log hiraginoName
					if hiraginoName == font
						# ヒラギノフォントリストとマッチしたらヒラギノフォント一覧を追加
						$(@fontList).append "<option>"+hiraginoFont+"</option>"

		# 適用ボタンにイベントを追加
		apply = @html.window.document.getElementById("config-apply")
		if apply?
			apply.addEventListener("click", @applyHandler)

		@restoreConfig()

	windowClosingHandler: (event) =>
		@windowFlag = false
		@window.removeEventListener("closing", @windowClosingHandler)

	windowResizeHandler: =>
		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = @window.width
		@html.height = @window.height

	# 適用ボタンハンドラ
	applyHandler: (event) =>
		# 入力値を取得
		@getConfigElements()
		style =
			'font-family':@fontFamily.value
			'font-size':@fontSize.value
			'color':"##{@fontColor.value}"
			'-webkit-text-stroke-width':@fontStrokeWidth.value
			'-webkit-text-stroke-color':"##{@fontStrokeColor.value}"

		# 字幕に入力値を適用
		if window.viewerObj.threadController?
			if window.viewerObj.threadController.jimakuRes?
				jimakuRes = window.viewerObj.threadController.jimakuRes
				$(jimakuRes).css(style)

		# サンプル文字に入力値を適用
		if @sample?
			$(@sample).css(style)

		# 入力値を保存
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

	# ヒラギノフォントのリストを取得（フォント名： CSS指定名）
	getHiraginoFontList: =>
		hiraginoFontList =
			"ヒラギノ角ゴ Pro W3": ["ヒラギノ角ゴ Pro","Hiragino Kaku Gothic Pro"]
			"ヒラギノ角ゴ ProN W3": [ "ヒラギノ角ゴ ProN","Hiragino Kaku Gothic ProN"]
			"ヒラギノ角ゴ Pro W6": ["ヒラギノ角ゴ Pro","Hiragino Kaku Gothic Pro"]
			"ヒラギノ角ゴ ProN W6": ["ヒラギノ角ゴ ProN","Hiragino Kaku Gothic ProN"]
			"ヒラギノ明朝 Pro W3": ["ヒラギノ明朝 Pro","Hiragino Mincho Pro"]
			"ヒラギノ明朝 ProN W3": ["ヒラギノ明朝 ProN","Hiragino Mincho ProN"]
			"ヒラギノ明朝 Pro W6": ["ヒラギノ明朝 Pro","Hiragino Mincho Pro"]
			"ヒラギノ明朝 ProN W6": ["ヒラギノ明朝 ProN","Hiragino Mincho ProN"]
			"ヒラギノ丸ゴ Pro W4": ["ヒラギノ丸ゴ Pro","Hiragino Maru Gothic Pro"]
			"ヒラギノ丸ゴ ProN W4": ["ヒラギノ丸ゴ ProN","Hiragino Maru Gothic ProN"]
		return hiraginoFontList
