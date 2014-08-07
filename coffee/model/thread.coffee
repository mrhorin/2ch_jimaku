class window.Thread
	# clickedThread スレッドタイトルと番号とリクエストURLを格納
	# bbsUrl 掲示板のURL
	# res レスを格納する二次元配列

	# 【引数】選択されたスレッドと掲示板URL
	constructor: (clickedThread, bbsUrl) ->
		@clickedThread = clickedThread
		@bbsUrl = bbsUrl
		# スレッドのリクエスト用URL
		@clickedThread["ReqUrl"] = "http://#{bbsUrl["domain"]}/bbs/rawmode.cgi/#{bbsUrl["category"]}/#{bbsUrl["address"]}/#{clickedThread["number"]}/"

	# レスを取得
	getRes: =>
		$.ajax({
			async: false
			beforeSend: (xhr) =>
		    	 xhr.overrideMimeType("text/html;charset=EUC-JP")
			type: 'GET'
			url: @clickedThread["ReqUrl"]
			dataType: 'text'
			# 成功時
			success: (data) =>
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

		$.each data, (index, value) =>
			@res[index] = []
			# 1レスを各要素ごとに配列で分ける
			value = value.split("<>")
			for i in [0..4]
				@res[index][i] = value[i]