class window.ThreadView extends BaseView

	# レスを描画
	printRes: =>
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