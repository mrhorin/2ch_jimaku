class window.ThreadView extends BaseView
	# res コンストラクタ取得したレス

	# 【引数】Threadインスタンス
	constructor: (thread) ->
		@res = thread.res

	# レスを描画
	printRes: =>
		# sectionを空に
		@sectionToEmpty()

		$.each @res, (index, value) =>
			$("section").append(
				"""
				<div class="res">
					<div class="res-head">
						<span class="res-no">
							#{@res[index][0]}
						</span>
						<span class="res-name">
							#{@res[index][1]}
						</span>
						<span class="res-date">
							#{@res[index][3]}
						</span>
					</div>
					<div class="res-body">
						#{@res[index][4]}
					</div>
				</div>
				"""
			)