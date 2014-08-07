class window.Bbs
	# url 掲示板TOPのURL
	# subjects スレタイ一覧

	constructor: (url) ->
		@url = url
		@urlToArray()
		@getSubject()
		@subjectsToArray()

	# urlを連想配列化する
	urlToArray: ->
		@url = @url.split("/")
		@url =
			"domain": @url[2]
			"category": @url[3]
			"address": @url[4]

	# subject.txtの取得
	getSubject: =>
		$.ajax({
			async: false
			beforeSend: (xhr) =>
		    	 xhr.overrideMimeType("text/html;charset=EUC-JP")
			type: 'GET'
			url:    "http://"+
					@url["domain"]+"/"+
					@url["category"]+"/"+
					@url["address"]+"/subject.txt"
			dataType: 'text'
			# 成功時
			success: (data) =>
				# 読み込むスレッドがあるか確認
				if data
					@subjects = data
			# 失敗時
			error: ->
				alert "スレッド読み込みエラー"
		});

	# @subjectsを配列化する
	# @subjects[0]["number"] => 0番目のスレッド番号
	# @subjects[0]["title"] => 0番目のスレッドタイトル
	subjectsToArray: =>
		res = []
		@subjects = @subjects.split("\n")
		$.each @subjects, (index, value) ->
			value = value.split(".cgi,")
			res[index] =
				"number": value[0]
				"title": value[1]
		@subjects = res
		# 末尾のundefind等を削除
		@subjects.pop()
		@subjects.pop()