# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(->
	$('button.task').click(->
		$this = $(this)
		id    = $(this).attr('id')
		$.get( 'tasks/' + id + '/able',->
			if($this.hasClass('btn-warning'))
				$this.removeClass('btn-warning').addClass('btn-success').text('可启用')
			else
				$this.removeClass('btn-success').addClass('btn-warning').text('可禁用')
		)
	)
	$('#start_date').datepicker({dateFormat: "yy-mm-dd"})
	$('#end_date').datepicker({dateFormat: "yy-mm-dd"})
)