class window.ThreadController
	# thread Threadインスタンス
	# threadView ThreadViewインスタンス
	# jimakuView ThreadJimakuViewインスタンス

	# resLoadTimer レス自動更新用タイマー
	# jimakuPrintTimer 字幕表示用タイマー
	# clock 時計表示用タイマー

	# jimakuBody 字幕bodyエレメント
	# jimakuTitle 字幕titleエレメント
	# jimakuSubject 字幕subjectエレメント
	# jimakuClock 字幕時計エレメント
	# jimakuCount 字幕レス数エレメント
	# jimakuRes 字幕レスエレメント

	# jimakuResQueue 字幕レス表示用キュー
	# jimakuAAFlag 字幕アスキアート表示フラグ
	# jimakuLoadFlag
	# resLoadFlag レス自動更新用フラグ
	# res_sound レス着信音用Soundインスタンス
	# airFlag switchClassAirのOnOff

	constructor: (thread, threadView, jimakuView) ->
		@thread = thread
		@threadView = threadView
		@jimakuView = jimakuView
		@resLoadTimer = null
		@jimakuPrintTimer = null
		@clock = null
		@jimakuBody = null
		@jimakuTitle = null
		@jimakuSubject = null
		@jimakuClock = null
		@jimakuCount = null
		@jimakuRes = null
		@jimakuResQueue = []
		@jimakuCompleteFlag = false
		@jimakuAAFlag = false
		@resLoadFlag = false
		@jimakuLoadFlag = false
		@airFlag = false
		# スレッドの最大レス数
		@MAX_RES_COUNT = 1000
		# レス着信音
		res_sound_url = new window.air.URLRequest("../../sound/sound.mp3")
		@res_sound = new air.Sound(res_sound_url)
		# スレッドストップ通知音
		stop_sound_url = new window.air.URLRequest("../../sound/stop.mp3")
		@stop_sound = new air.Sound(stop_sound_url)
		@jimakuInitialize()

	# 字幕初期化設定
	jimakuInitialize: ->
		@jimakuView.html.addEventListener("complete", @jimakuCompleteHandler)

	# 字幕ウィンドウ読み込み完了時イベントハンドラー
	jimakuCompleteHandler: =>
		# 字幕エレメントの取得
		@jimakuTitle = @jimakuView.html.window.document.getElementById("jimaku-title")
		@jimakuSubject = @jimakuView.html.window.document.getElementById("jimaku-subject")
		@jimakuBody = @jimakuView.html.window.document.getElementById("jimaku-body")
		@jimakuClock = @jimakuView.html.window.document.getElementById("jimaku-clock")
		@jimakuCount = @jimakuView.html.window.document.getElementById("jimaku-count")
		@jimakuRes = @jimakuView.html.window.document.getElementById("jimaku-res")
		if @jimakuSubject?
			# 字幕タイトルがドラッグされた時のイベント
			@jimakuTitle.addEventListener("mousedown", @onMoveJimaku, true)
			# 字幕枠がリサイズされた時のイベント
			@jimakuBody.addEventListener("mousedown", @onResizeJimaku, true)
			# 字幕にスレタイとレス数を描画
			@printSubjectToJimaku(@jimakuSubject)
			@printJimakuResCount()
			# @addClassAir()
		# 字幕時計をON
		if @jimakuClock?
			@jimakuClockOn()
		# 字幕CSSスタイルを復帰
		if @jimakuRes?
			if window.viewerObj.so.data.fontFamily?
				$(@jimakuRes).css("font-family", window.viewerObj.so.data.fontFamily)
			if window.viewerObj.so.data.color?
				$(@jimakuRes).css("color",window.viewerObj.so.data.color)
			if window.viewerObj.so.data.fontSize?
				$(@jimakuRes).css("font-size", window.viewerObj.so.data.fontSize)
			if window.viewerObj.so.data.strokeWidth?
				$(@jimakuRes).css("-webkit-text-stroke-width", window.viewerObj.so.data.strokeWidth)
			if window.viewerObj.so.data.strokeColor?
				$(@jimakuRes).css("-webkit-text-stroke-color", window.viewerObj.so.data.strokeColor)

	# 字幕移動ハンドラ
	onMoveJimaku: (event) =>
		@jimakuView.jimaku.startMove()

	# 字幕リサイズハンドラ
	onResizeJimaku: (event) =>
		@jimakuView.jimaku.startResize("BR")

	# 字幕にスレタイを表示
	printSubjectToJimaku: (subject) =>
		# スレタイから（レス数）を削除
		@thread.clickedThread["title"] = @thread.clickedThread["title"].replace(/\(\d+\)$/, "")
		# スレタイを描画
		subject.innerHTML = @thread.clickedThread["title"]

	# 字幕にレスを表示
	printResToJimaku: (res) =>
		# レスを表示
		if @jimakuRes?
			# アスキアートモードOFF
			@AAModeOff()
			@jimakuRes.innerHTML = res

	# 字幕にアスキーアートを表示
	printAAToJimaku: (res) =>
		if window.viewerObj.threadController?
			if window.viewerObj.threadController.jimakuRes?
				# アスキアートモードON
				@AAModeOn()
				@jimakuRes.innerHTML = res

	# 字幕にレス数を表示
	printJimakuResCount: =>
		if @jimakuCount?
			@jimakuCount.innerHTML = "("+@thread.resCount+")"

	# レスがAAかを判定
	checkAA: (res) =>
		ptn = new RegExp("＼|∪|∩|⌒|从|;;;|:::|\,\,\,|'''")
		if ptn.test(res)
			return true
		else
			return false

	# レスに画像URLが含まれているか判定
	checkImageUrl: (res) =>
		ptn = new RegExp("f|h?)(t{1}tps?:\/\/[-a-zA-Z0-9@:%_\+.~?&\/\/=]+\.(jpg|jpeg|png|bmp)$")
		if ptn.test(res)
			return true
		else
			return false

	# キューの要素数(引数)を調べて字幕表示秒数を返す
	checkQueueLength: (count) ->
		switch
			when count <= 1
				sec = 9000
			when 2 <= count <= 3
				sec = 6000
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
		@resLoadFlag = true
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
				if !@jimakuLoadFlag
					# 字幕表示用タイマーON
					@jimakuLoadOn()
			else if @thread.resCount >= @MAX_RES_COUNT
				# レス1000表示
				@printResToJimaku("スレが1000になりました")
				@stop_sound.play()
		, 7000

	# 自動更新OFF
	resLoadOff: =>
		@resLoadFlag = false
		clearInterval(@resLoadTimer)
		clearTimeout(@jimakuPrintTimer)

	# アスキアートモードをON
	AAModeOn: =>
		# 字幕がAAモードになっているか
		if !@jimakuAAFlag
			# アスキーアート用cssクラスを追加
			$(@jimakuRes).addClass("jimaku-res-aa")
			@jimakuAAFlag = true

	# アスキアートモードをOFF
	AAModeOff: =>
		# アスキアートモードか
		if @jimakuAAFlag
			$(@jimakuRes).removeClass("jimaku-res-aa")
			@jimakuAAFlag = false

	# 字幕表示用タイマーON
	jimakuLoadOn: (sec = 0) =>
		@jimakuLoadFlag = true
		@jimakuPrintTimer = setTimeout =>
			# 新着レスがあるか確認
			if @jimakuResQueue[0]?
				# 表示用レス
				res = @jimakuResQueue[0]
				# 字幕に総レス数を表示
				@printJimakuResCount()
				# 表示用レスがAAかを確認
				if @checkAA(res)
					# AAを表示
					@printAAToJimaku(res)
				else
					# レスを表示
					@printResToJimaku(res)
				# レス着信音の再生
				@res_sound.play()
				# デキュー
				@jimakuResQueue.shift()
				# レス表示時間を取得
				hoge = @checkQueueLength(@jimakuResQueue.length)
				@jimakuLoadOn(hoge)
			else
				# アスキアートモードOFF
				@AAModeOff()
				# 字幕レス表示を消す
				@printResToJimaku("")
				@jimakuLoadFlag = false
				clearTimeout(@jimakuPrintTimer)
		, sec

	# 字幕時計をON
	jimakuClockOn: =>
		@clock = setInterval =>
			# 現在時刻を取得
			nowTime = @jimakuView.getNowTime()
			@jimakuClock.innerHTML = nowTime
		, 1000

	# 字幕時計をOFF
	jimakuClockOff: =>
		clearInterval(@clock)

	switchClassAir: =>
		if @airFlag && @jimakuBody?
			@jimakuBody.className = ""
			@airFlag = false
		else if  @jimakuBody?
			@jimakuBody.className = "bg-air"
			@airFlag = true
