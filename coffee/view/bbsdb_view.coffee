class window.BbsDbView extends BaseView
	# clickedBbs 選択された掲示板
	# deleteId 削除する掲示板ID
	# html 掲示板追加ウィンドウ用HTMLLoader
	# addBbs 掲示板追加用ウィンドウ

	constructor: ->
		@showAddbbsFlag = false

	# 掲示板一覧を描画
	printBbs: (bbsList) =>
		if bbsList != null
			# sectionを空に
			@sectionToEmpty()
			section = window.viewerObj.html.window.document.getElementById("section")
			$.each bbsList, (index, value) =>
				# 掲示板タイトルを描画
				$(section).append(
					$("<div class=\"bbs\" id=\""+bbsList[index]["id"]+"\">"+
						bbsList[index]["name"]+
					"</div>"
					).click  =>
						@clickedBbs =
							"name": bbsList[index]["name"]
							"url": bbsList[index]["url"]
				)
			# 一番上へスクロール
			topMost = window.viewerObj.html.window.document.getElementById("top-most")
			$(topMost).get(0).scrollIntoView(true)

	# 掲示板追加ウィンドウを描画
	showAddbbs: =>
		# add_bbs.htmlを取得
		url = new window.air.URLRequest("../../haml/add_bbs.html")
		@html = new window.air.HTMLLoader()
		@html.load(url)

		options = new window.air.NativeWindowInitOptions()
		# 透過無効
		options.transparent = false
		options.systemChrome = air.NativeWindowSystemChrome.STANDARD
		options.type = window.air.NativeWindowType.NORMAL

		# 掲示板追加用ウィンドウの生成
		@addBbs = new window.air.NativeWindow(options)
		@addBbs.title = "掲示板を追加"
		@addBbs.width = 450
		@addBbs.height = 160

		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = @addBbs.width
		@html.height = @addBbs.height
		# 最前面表示
		# @addBbs.alwaysInFront  = true
		@addBbs.stage.addChild(@html)
		@addBbs.stage.scaleMode = "noScale"
		@addBbs.stage.align = "topLeft"
		@addBbs.activate()