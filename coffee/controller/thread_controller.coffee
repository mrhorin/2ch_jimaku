class window.ThreadController
	# thread Threadインスタンス
	# threadView ThreadViewインスタンス
	# jimakuView jimakuViewインスタンス
	# resLoadTimer 更新用インターバルタイマー
	# subject 字幕タイトルエレメント

	constructor: (thread, threadView, jimakuView) ->
		@thread = thread
		@threadView = threadView
		@jimakuView = jimakuView
		@resLoadTimer = null
		@jimakuInitialize()

	# 字幕初期化設定
	jimakuInitialize: ->
		@jimakuView.html.addEventListener("complete", @jimakuCompleteHandler)

	# 字幕初期読み込み完了時イベントハンドラー
	jimakuCompleteHandler: =>
		# 字幕タイトルエレメントの取得
		@subject = @jimakuView.html.window.document.getElementById("jimaku-subject")
		# 字幕の移動ハンドラを設定
		@subject.addEventListener("mousedown", @onMoveJimaku, true)
		@printSubjectToJimaku(@subject)
		# @jimaku.air.Introspector.Console.log(@subject)

	# 字幕移動ハンドラ
	onMoveJimaku: (event) =>
		@jimakuView.jimaku.startMove()
		# @air.Introspector.Console.log(@jimaku)

	# 字幕にスレタイを表示
	printSubjectToJimaku: (subject) =>
		subject.innerHTML = @thread.clickedThread["title"]

	# 自動更新ON
	resLoadOn: =>
		@resLoadTimer = setInterval =>
			res = @thread.getRes()
			if res
				# 読み込むレスがあった時
				@threadView.printRes(res)
		, 7000

	# 自動更新OFF
	resLoadOff: =>
		clearInterval(@resLoadTimer)