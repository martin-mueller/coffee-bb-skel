// Generated by CoffeeScript 1.6.2
var app,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

app = app || {};

$(function() {
  var _ref, _ref1, _ref2, _ref3;

  app.Note = (function(_super) {
    __extends(Note, _super);

    function Note() {
      _ref = Note.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Note.prototype.urlRoot = 'server.php/notes';

    Note.prototype.defaults = {
      text: "",
      pos: {
        x: 0,
        y: 0
      },
      size: {
        width: 100,
        height: 100
      }
    };

    Note.prototype.initialize = function() {
      this.on("change:pos", this.savePos);
      return this.on("all", function(e) {
        return console.log("Note event:" + e);
      });
    };

    Note.prototype.savePos = function() {
      return this.save(this.pos);
    };

    Note.prototype.validate = function(attrs, options) {};

    return Note;

  })(Backbone.Model);
  app.Notes = (function(_super) {
    __extends(Notes, _super);

    function Notes() {
      _ref1 = Notes.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Notes.prototype.url = 'server.php/notes';

    Notes.prototype.model = app.Note;

    return Notes;

  })(Backbone.Collection);
  app.notes = new app.Notes();
  app.NoteView = (function(_super) {
    __extends(NoteView, _super);

    function NoteView() {
      _ref2 = NoteView.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    NoteView.prototype.template = _.template($('#item-template').html());

    NoteView.prototype.className = "draggable ui-widget-content";

    NoteView.prototype.isDragging = false;

    NoteView.prototype.events = {
      "click .close": "clear"
    };

    NoteView.prototype.initialize = function() {
      this.listenTo(this.model, 'destroy', this.remove);
      this.listenTo(this.model, 'change:id', this.render);
      this.render();
      return console.log(this);
    };

    NoteView.prototype.render = function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this.$el.offset(this.model.get("pos"));
    };

    NoteView.prototype.startDrag = function() {
      return this.isDragging = true;
    };

    NoteView.prototype.stopDrag = function(position) {
      this.isDragging = false;
      return this.model.set("pos", position);
    };

    NoteView.prototype.clear = function(e) {
      e.stopImmediatePropagation();
      return this.model.destroy();
    };

    return NoteView;

  })(Backbone.View);
  return app.DeskView = (function(_super) {
    __extends(DeskView, _super);

    function DeskView() {
      _ref3 = DeskView.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    DeskView.prototype.initialize = function() {
      return this.listenTo(app.notes, 'add', this.addOne);
    };

    DeskView.prototype.el = '#wrapper';

    DeskView.prototype.events = {
      "click #add": "addNote",
      "add": "addOne"
    };

    DeskView.prototype.addNote = function() {
      return app.notes.create({
        text: 'test'
      });
    };

    DeskView.prototype.addOne = function(note) {
      var noteView;

      noteView = new app.NoteView({
        model: note,
        id: "note-" + note.cid
      });
      $('#wrapper').append(noteView.el);
      return noteView.$el.draggable({
        stack: ".draggable",
        delay: 100,
        start: function(event, ui) {
          return noteView.startDrag;
        },
        stop: function(event, ui) {
          return noteView.stopDrag(ui.position);
        }
      });
    };

    return DeskView;

  })(Backbone.View);
});
