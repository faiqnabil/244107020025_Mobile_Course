class Todo {
  final String title;
  final bool done;

  const Todo(this.title, {this.done = false});

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}
