class window.Thread extends ThreadView
	# clickedThread スレッドタイトルと番号とリクエストURLを格納
	# bbsUrl 掲示板のURL
	# resLoadFlag スレッド自動更新用フラグ
	# resCount 取得済みレス数
	# res レスを格納する二次元配列

	# 【引数】選択されたスレッドと掲示板URL
	constructor: (clickedThread, bbsUrl) ->
		@clickedThread = clickedThread
		# スレッドのリクエスト用URL
		@clickedThread["ReqUrl"] = "http://#{bbsUrl["domain"]}/bbs/rawmode.cgi/#{bbsUrl["category"]}/#{bbsUrl["address"]}/#{clickedThread["number"]}/"
		# 掲示板URL
		@bbsUrl = bbsUrl
		# スレッド自動更新用フラグ
		@resLoadFlag = false;
		# 取得済みレス数
		@resCount = 0
		# 更新用タイマー
		@resLoadTimer = null

	# レスを取得
	getRes: =>
		if @resCount == 0
			# 初回取得用URL
			url = @clickedThread["ReqUrl"]
		else
			# スレッド更新用URL
			url = @clickedThread["ReqUrl"] + (@resCount+1) + "-"

		$.ajax({
			async: false
			beforeSend: (xhr) =>
		    	 xhr.overrideMimeType("text/html;charset=EUC-JP")
			type: 'GET'
			url: url
			dataType: 'text'
			# 成功時
			success: (data) =>
				if data
					@resToArray(data)

			# 失敗時
			error: ->
				alert "スレッド読み込みエラー"
		});

	# GETしたtxt形式のレスを配列化
	# 【引数】GETしたtxt形式のレス
	resToArray: (data) ->
		# レスを格納する配列の初期化
		@res = []
		# 1レスずつ配列にして分ける
		data = data.split("\n")
		# 末尾のundefinedを削除
		data.pop()
		# 取得レス数を格納
		@resCount = @resCount + data.length

		# 1レスを各要素ごとに配列で分ける
		$.each data, (index, value) =>
			@res[index] = []
			value = value.split("<>")
			for i in [0..4]
				@res[index][i] = value[i]
		@printRes()

	# 自動更新ON
	loadOn: ->
		@resLoadFlag = true
		@resLoading()

	# 自動更新OFF
	loadOff: ->
		@resLoadFlag = false
		clearTimeout(@resLoadTimer)

	# 自動更新する
	resLoading: =>
		@getRes()
		if @resLoadFlag
			# alert "取得"
			@resLoadTimer = setTimeout =>
				@resLoading()
			, 7000