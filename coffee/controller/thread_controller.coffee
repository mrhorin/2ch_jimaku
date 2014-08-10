class window.ThreadController
	# thread Threadインスタンス
	# threadView ThreadViewインスタンス
	# jimakuView jimakuViewインスタンス
	# resLoadTimer レス自動更新用タイマー
	# jimakuPrintTimer 字幕表示用タイマー
	# jimakuSubject 字幕タイトルエレメント
	# jimakuRes 字幕レスエレメント
	# jimakuResQueue 字幕レス表示用キュー

	constructor: (thread, threadView, jimakuView) ->
		@thread = thread
		@threadView = threadView
		@jimakuView = jimakuView
		@resLoadTimer = null
		@jimakuPrintTimer = null
		# @jimakuSubject = null
		@jimakuResQueue = []
		@jimakuInitialize()

	# 字幕初期化設定
	jimakuInitialize: ->
		@jimakuView.html.addEventListener("complete", @jimakuCompleteHandler)

	# 字幕初期読み込み完了時イベントハンドラー
	jimakuCompleteHandler: =>
		# 字幕タイトルエレメントの取得
		@jimakuSubject = @jimakuView.html.window.document.getElementById("jimaku-subject")
		@jimakuRes = @jimakuView.html.window.document.getElementById("jimaku-res")
		# 字幕の移動ハンドラを設定
		if @jimakuSubject?
			@jimakuSubject.addEventListener("mousedown", @onMoveJimaku, true)
			@printSubjectToJimaku(@jimakuSubject)

	# 字幕移動ハンドラ
	onMoveJimaku: (event) =>
		@jimakuView.jimaku.startMove()

	# 字幕にスレタイを表示
	printSubjectToJimaku: (subject) =>
		subject.innerHTML = @thread.clickedThread["title"]

	# 字幕にレスを表示
	printResToJimaku: (res) =>
		@jimakuRes.innerHTML = res

	# 自動更新ON
	resLoadOn: =>
		# レス自動更新用タイマー
		@resLoadTimer = setInterval =>
			# 新着レスを取得
			res = @thread.getRes()
			# 新着レスがあるか確認
			if res
				# スレッドビューに新着レスを描画
				@threadView.printRes(res)
				# 字幕表示用配列に新着レスをpush
				$.each res, (index, value) =>
					@jimakuResQueue.push res[index][4]
			# @jimakuView.air.Introspector.Console.log(res)
		, 7000

		# 字幕表示用タイマー
		@jimakuPrintTimer = setInterval =>
			if @jimakuResQueue[0]?
				@printResToJimaku(@jimakuResQueue[0])
				@jimakuResQueue.shift()
		, 500

	# 自動更新OFF
	resLoadOff: =>
		clearInterval(@resLoadTimer)
		clearInterval(@jimakuPrintTimer)