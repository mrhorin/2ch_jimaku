class window.ThreadController
	# thread Threadインスタンス
	# threadView ThreadViewインスタンス
	# jimakuView ThreadJimakuViewインスタンス
	# resLoadTimer レス自動更新用タイマー
	# jimakuPrintTimer 字幕表示用タイマー
	# clock 時計表示用タイマー
	# jimakuSubject 字幕タイトルエレメント
	# jimakuClock 字幕時計エレメント
	# jimakuRes 字幕レスエレメント
	# jimakuResQueue 字幕レス表示用キュー
	# jimakuLoadFlag

	constructor: (thread, threadView, jimakuView) ->
		@thread = thread
		@threadView = threadView
		@jimakuView = jimakuView
		@resLoadTimer = null
		@jimakuPrintTimer = null
		@jimakuSubject = null
		@jimakuClock = null
		@clock = null
		@jimakuResQueue = []
		@jimakuLoadFlag = false
		@jimakuInitialize()

	# 字幕初期化設定
	jimakuInitialize: ->
		@jimakuView.html.addEventListener("complete", @jimakuCompleteHandler)

	# 字幕ウィンドウ読み込み完了時イベントハンドラー
	jimakuCompleteHandler: =>
		# 字幕タイトルエレメントの取得
		@jimakuSubject = @jimakuView.html.window.document.getElementById("jimaku-subject")
		@jimakuClock = @jimakuView.html.window.document.getElementById("jimaku-clock")
		@jimakuRes = @jimakuView.html.window.document.getElementById("jimaku-res")
		# 字幕の移動ハンドラを設定
		if @jimakuSubject?
			@jimakuSubject.addEventListener("mousedown", @onMoveJimaku, true)
			@printSubjectToJimaku(@jimakuSubject)
		# 字幕時計をON
		if @jimakuClock?
			@jimakuClockOn()

	# 字幕移動ハンドラ
	onMoveJimaku: (event) =>
		@jimakuView.jimaku.startMove()

	# 字幕にスレタイを表示
	printSubjectToJimaku: (subject) =>
		subject.innerHTML = @thread.clickedThread["title"]

	# 字幕にレスを表示
	printResToJimaku: (res) =>
		@jimakuRes.innerHTML = res

	# キューの要素数を調べて字幕表示秒数を返す
	checkQueueLength: (count) ->
		switch
			when count <= 1
				sec = 10000
			when 2 <= count <= 3
				sec = 7500
			when 4 <= count <= 5
				sec = 5000
			when 6 <= count <= 10
				sec = 3500
			when 11 <= count <= 15
				sec = 2000
			when 16 < count
				sec = 1000
			else
				sec = 1000

	# レス自動更新用タイマーON
	resLoadOn: =>
		@resLoadTimer = setInterval =>
			# 新着レスを取得
			res = @thread.getRes()
			# 新着レスがあるか確認
			if res
				# スレッドビューに新着レスを描画
				@threadView.printRes(res)
				# @jimakuView.air.Introspector.Console.log(res)
				# 字幕表示用配列に新着レスをpush
				$.each res, (index, value) =>
					@jimakuResQueue.push res[index][4]
				if !@jimakuLoadFlag
					# 字幕表示用タイマーON
					@jimakuLoadOn()
		, 7000

	# 字幕表示用タイマーON
	jimakuLoadOn: (sec = 0) =>
		@jimakuLoadFlag = true
		@jimakuPrintTimer = setTimeout =>
			# 新着レスがあるか確認
			if @jimakuResQueue[0]?
				# キューの先頭要素を表示
				@printResToJimaku(@jimakuResQueue[0])
				# デキュー
				@jimakuResQueue.shift()
				# レス表示時間を取得
				hoge = @checkQueueLength(@jimakuResQueue.length)
				@jimakuLoadOn(hoge)
			else
				# 字幕レス表示を消す
				@printResToJimaku("")
				@jimakuLoadFlag = false
				clearTimeout(@jimakuPrintTimer)
		, sec

	# 字幕時計をON
	jimakuClockOn: () =>
		@clock = setInterval =>
			# 現在時刻を取得
			nowTime = @jimakuView.getNowTime()
			@jimakuClock.innerHTML = nowTime
		, 1000

	# 字幕時計をOFF
	jimakuClockOff: () =>
		clearInterval(@clock)

	# 自動更新OFF
	resLoadOff: =>
		clearInterval(@resLoadTimer)
		clearTimeout(@jimakuPrintTimer)