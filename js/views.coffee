app = app || {}
$ ->
	class app.WidgetView extends Backbone.View
		template: _.template($('#item-template').html())
		className:	"notes ui-widget-content"
		isDragging:	false
		isResizing: false

		events:
			"mousedown .close"	: "clear"
			"mouseup .close"	: "stopClear"
			"reset"				: "render"
			
		
		initialize: ->
			@listenTo @model, 'destroy', @remove
			@listenTo @model, 'change', @render
			@render()

		render: ->
			@$el.html   @template(@.model.toJSON())
			@$el.offset @model.get "pos"
			@$el.width  @model.get("size").width
			@$el.height @model.get("size").height
			# @$el.css 'z-index', @model.get "z-index"
			# return $el for chaining (?)
			$('#desk').append(el)
			return @$el

		
		# set states on ui events
		startDrag: ->
			@isDragging = true

		stopDrag: (position) ->
			delay 100, => @isDragging = false
			@model.set("z-index", @$el.css('z-index'))		
			@model.set("pos", position)
		
		startResize: ->
			@isResizing = true
			
		stopResize: (size) ->
			delay 100, => @isResizing = false
			@model.set("size", size)

		clear: (e) ->
			@$el.fadeOut 1000, =>
				@model.destroy()

		stopClear: (e) ->
			@$el.stop().css("opacity","1");


	class app.WidgetFactory
		buildModel: (type, params) ->
			switch type
				when "note" then new app.Note params	

		buildView: (type, params) ->
			switch type
				when "note" then new app.NoteView params	


		

	class app.NoteView extends app.WidgetView
		
		events:
			"click .marked"		: "enableEdit"
			"focusout"			: "editDone"
			"mousedown .close"	: "clear"
			"mouseup .close"	: "stopClear"
			

		enableEdit: (e) ->
			if not @isDragging and not @isResizing and not @collection.isLocked
				# prevent default in case a link in the marked el was clicked
				e.preventDefault()
				if @collection.editEl isnt null
					@collection.editEl.editDone()
				$('.marked',@el).hide()
				$('textarea',@el).show().focus()
				@oldText = $('textarea',@el).val()
				@collection.editEl = @

		# @editDone
		# set note model text
		# hide textarea and render the output
		editDone: ->
			text = $('textarea',@el).val()
			@model.set("text",text) if text isnt @oldText
			@showMarked()
			@collection.editEl = null

		# render markdown after create and edit note
		showMarked: ->
			$m = $('.marked',@el)
			text_v   = $('textarea',@el).val()
			marked_v = marked(text_v)
			$m.html(marked_v)
			$('textarea',@el).hide()
			$m.show()	




	# @class DeskView
	# manage all noteView elements on visble desktop
	class app.DeskView extends Backbone.View
		initialize: ->
			@listenTo @collection, 'add', @addOne
			# markdown options
			marked.setOptions breaks: true


		el: '#wrapper'

		events:
			"click #add"		: "create"
			"add"				: "addOne"
			"click #toggleEdit"	: "toggleEdit"

		create: ->
			z = 1
			l = @collection.last()
			z = l.get("z-index") + 1 if l != undefined
			@collection.create({ type: "note", "z-index" : z })
			
		
		addOne: (widget) ->
			wf = new app.WidgetFactory()
			type = "note"
			widgetView = wf.buildView type, { type: type, collection: @collection, model: widget, id: "note-" + widget.cid } 
		
			widgetView.$el.draggable
				stack: ".notes"
				delay: 100
				start: (event, ui) ->
					widgetView.startDrag()
				stop:  (event, ui) ->
					widgetView.stopDrag ui.position
			widgetView.$el.resizable
				start: (event, ui) ->
					widgetView.startResize()
				stop:  (event, ui) ->
					widgetView.stopResize ui.size
			widgetView.showMarked()

		toggleEdit: ->
			if @collection.isLocked 
				@collection.isLocked = false;
				$("#toggleEdit span").removeClass("ui-icon-locked")
								.addClass("ui-icon-unlocked")
			else					
				@collection.isLocked = true;
				$("#toggleEdit span").removeClass("ui-icon-unlocked")
								.addClass("ui-icon-locked")


# some functions here ;)
	delay = (ms, func) -> setTimeout func, ms
	return
	
