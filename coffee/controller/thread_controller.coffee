class window.ThreadController
	# thread Threadインスタンス
	# threadView ThreadViewインスタンス
	# resLoadTimer 更新用インターバルタイマー

	constructor: (thread, threadView) ->
		@thread = thread
		@threadView = threadView
		@resLoadTimer = null

	# 自動更新ON
	resLoadOn: =>
		@resLoadTimer = setInterval =>
			res = @thread.getRes()
			if res
				@threadView.printRes(res)
		, 7000

	# 自動更新OFF
	resLoadOff: =>
		clearInterval(@resLoadTimer)