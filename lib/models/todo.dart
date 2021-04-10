import 'package:hive/hive.dart';
part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  final String todoTitle;
  @HiveField(1)
  final String todoDescription;
  @HiveField(2)
  final bool isCompleted;
  Todo({
    this.todoTitle,
    this.todoDescription,
    this.isCompleted,
  });
}
