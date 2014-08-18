class window.BbsDbController
	# bbsDb
	# bbsDbView BbsDbViewインスタンスはBbsDbインスタンスを保持

	constructor: (bbsDb, bbsDbView) ->
		@bbsDb = bbsDb
		@bbsDbView = bbsDbView

	# 掲示板一覧を取得
	getBbsList: ->
		# sectionを空に
		@bbsDbView.sectionToEmpty()
		# 掲示板一覧を取得
		@bbsDb.selectBbs()
		# 掲示板一覧を描画
		@bbsDbView.printBbs(@bbsDb.bbsList)
		# 掲示板一覧にイベントリスナーをつける
		@setBbsListListener(@bbsDb.bbsList)

	# 掲示板追加用ウィンドウを取得
	getAddBbs: =>
		# 表示
		@bbsDbView.showAddbbs()
		# 初期化
		@addBbsInitialize()

	# 掲示板追加用ウィンドウを初期化
	addBbsInitialize: ->
		# 読み込み完了時のイベント
		@bbsDbView.html.addEventListener("complete", @addBbsCompleteHandler)

	# 掲示板追加用ウィンドウハンドラ
	addBbsCompleteHandler: (event) =>
		# 追加ボタンにイベントリスナーを追加
		id = @bbsDbView.html.window.document.getElementById("post-bbs-url")
		if id?
			id.addEventListener("click", @postAddBbsHandler)

	# 掲示板追加用ウィンドウの追加ボタンハンドラ
	postAddBbsHandler: (event) =>
		name = @bbsDbView.html.window.document.getElementById("add-bbs-name").value
		url = @bbsDbView.html.window.document.getElementById("add-bbs-url").value
		# 掲示板を追加
		if url? && name?
			@bbsDb.insertBbs(name, url)
			@bbsDbView.addBbs.close()
			@bbsDbView.addBbs = null
			@getBbsList()

	# 掲示板一覧にイベントリスナー追加
	setBbsListListener: (bbsList) =>
		if bbsList != null
			$.each bbsList, (index, value) =>
				id = window.viewerObj.html.window.document.getElementById(bbsList[index]["id"])
				id.addEventListener "contextmenu", @showContextMenuHandler(bbsList[index]["id"])
				id.addEventListener "click", @clickBbsHandler(bbsList[index]["url"],bbsList[index]["name"])

	# コンテキストメニューハンドラ
	showContextMenuHandler: (id) =>
		(event) =>
			# コンテキストメニューを生成
		    contextMenu = new air.NativeMenu()
		    # デフォルトメニューを非表示に
		    event.preventDefault()
		    # 削除コンテキストメニューアイテムを追加
		    deleteBbs = contextMenu.addItem(new air.NativeMenuItem("削除"))
		    deleteBbs.addEventListener(window.air.Event.SELECT, @deleteBbsHandler(id))
	    	contextMenu.display(window.nativeWindow.stage, event.clientX, event.clientY)

	# 掲示板削除ハンドラ
	deleteBbsHandler: (id) =>
		(event) =>
			# 掲示板を削除
			@bbsDb.deleteBbs(id)
			# 掲示板一覧を取得
			@getBbsList()

	# 掲示板クリックハンドラ
	clickBbsHandler: (url, name) =>
		(event) =>
			# URLをセット
			getUrl = window.document.getElementById("url")
			$(getUrl).val(url)
			# 掲示板名をセット
			bbsTitle = window.document.getElementById("bbs-title")
			bbsTitle.innerHTML = name
			# 掲示板名を保存
			window.viewerObj.so.data.bbsTitle = name
			# スレッド一覧ボタンを有効化
			getTread = window.document.getElementById("get-thread")
			$(getTread).attr('disabled', false)
			# スレッド一覧ボタンを押下
			window.viewerObj.getThreadHandler()