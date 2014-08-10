class window.ThreadController
	# thread Threadインスタンス
	# threadView ThreadViewインスタンス
	# jimakuView jimakuViewインスタンス
	# resLoadTimer レス自動更新用タイマー
	# jimakuPrintTimer 字幕表示用タイマー
	# jimakuSubject 字幕タイトルエレメント
	# jimakuRes 字幕表示用レスをスタックする配列

	constructor: (thread, threadView, jimakuView) ->
		@thread = thread
		@threadView = threadView
		@jimakuView = jimakuView
		@resLoadTimer = null
		@jimakuPrintTimer = null
		# @jimakuSubject = null
		@jimakuRes = []
		@jimakuInitialize()

	# 字幕初期化設定
	jimakuInitialize: ->
		@jimakuView.html.addEventListener("complete", @jimakuCompleteHandler)

	# 字幕初期読み込み完了時イベントハンドラー
	jimakuCompleteHandler: =>
		# 字幕タイトルエレメントの取得
		@jimakuSubject = @jimakuView.html.window.document.getElementById("jimaku-subject")
		# 字幕の移動ハンドラを設定
		@jimakuSubject.addEventListener("mousedown", @onMoveJimaku, true)
		@printSubjectToJimaku(@jimakuSubject)
		# @jimaku.air.Introspector.Console.log(@jimakuSubject)

	# 字幕移動ハンドラ
	onMoveJimaku: (event) =>
		@jimakuView.jimaku.startMove()
		# @air.Introspector.Console.log(@jimaku)

	# 字幕にスレタイを表示
	printSubjectToJimaku: (subject) =>
		subject.innerHTML = @thread.clickedThread["title"]

	# 自動更新ON
	resLoadOn: =>
		# レス自動更新用タイマー
		@resLoadTimer = setInterval =>
			res = @thread.getRes()
			if res
				# 読み込むレスがあった時
				@threadView.printRes(res)

				$.each res, (index, value) =>
					@jimakuRes.push res[index][4]
		, 7000
		# 字幕表示用タイマー
		@jimakuPrintTimer = setInterval =>
			if @jimakuRes[0]?
				alert @jimakuRes[0]
				@jimakuRes.shift()
		, 500

	# 自動更新OFF
	resLoadOff: =>
		clearInterval(@resLoadTimer)
		clearInterval(@jimakuPrintTimer)