class window.Thread
	# clickedThread スレッドタイトルと番号を格納

	constructor: (clickedThread) ->
		@clickedThread = clickedThread

	getThread: (title, number, url) ->
		# $.ajax({
		# 	async: false
		# 	beforeSend: (xhr) =>
		#     	 xhr.overrideMimeType("text/html;charset=EUC-JP")
		# 	type: 'GET'
		# 	url:    "http://"+
		# 			@url["domain"]+"/"+
		# 			@url["category"]+"/"+
		# 			@url["address"]+"/subject.txt"
		# 	dataType: 'text'
		# 	# 成功時
		# 	success: (data) =>
		# 		# 読み込むスレッドがあるか確認
		# 		if data
		# 			@subjects = data
		# 	# 失敗時
		# 	error: ->
		# 		alert "スレッド読み込みエラー"
		# });