part of 'pages.dart';

const dataBoxName = "todo_data";
enum TodoFilter {
  ALL,
  COMPLETED,
  PROGRESS,
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Box<Todo> dataBox;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TodoFilter filter = TodoFilter.ALL;

  @override
  void initState() {
    super.initState();
    dataBox = Hive.box<Todo>(dataBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value.compareTo('All') == 0) {
                setState(() {
                  filter = TodoFilter.ALL;
                });
              } else if (value.compareTo('Completed') == 0) {
                setState(() {
                  filter = TodoFilter.COMPLETED;
                });
              } else {
                setState(() {
                  filter = TodoFilter.PROGRESS;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return ["All", "Completed", "Progress"].map(
                (option) {
                  return PopupMenuItem(
                    child: Text(option),
                    value: option,
                  );
                },
              ).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: dataBox.listenable(),
          builder: (context, Box<Todo> items, _) {
            List<int> keys = items.keys.cast<int>().toList();
            if (filter == TodoFilter.ALL) {
              keys = items.keys.cast<int>().toList();
            } else if (filter == TodoFilter.COMPLETED) {
              keys = items.keys
                  .cast<int>()
                  .where((key) => items.get(key).isCompleted)
                  .toList();
            } else {
              keys = items.keys
                  .cast<int>()
                  .where((key) => !items.get(key).isCompleted)
                  .toList();
            }
            return ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_, index) => Divider(),
              itemCount: keys.length,
              itemBuilder: (_, index) {
                final int key = keys[index];
                final Todo todo = items.get(key);
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.todoTitle,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(todo.todoDescription),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          color: todo.isCompleted
                              ? Colors.amber
                              : Colors.grey[400],
                        ),
                        onPressed: !todo.isCompleted
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: Container(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              child: Text('Mark as complete'),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.amber,
                                              ),
                                              onPressed: () {
                                                Todo mTodo = Todo(
                                                  todoTitle: todo.todoTitle,
                                                  todoDescription:
                                                      todo.todoDescription,
                                                  isCompleted: true,
                                                );
                                                dataBox.put(key, mTodo);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              showBottomSheet(
                backgroundColor: Colors.black,
                context: context,
                builder: (context) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add New Task',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        TextField(
                          decoration: InputDecoration(hintText: 'Title'),
                          controller: titleController,
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextField(
                          decoration: InputDecoration(hintText: 'Description'),
                          controller: descriptionController,
                        ),
                        SizedBox(
                          height: 32.0,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final String title = titleController.text;
                            final String description =
                                descriptionController.text;
                            titleController.clear();
                            descriptionController.clear();
                            Todo newTodo = Todo(
                              todoTitle: title,
                              todoDescription: description,
                              isCompleted: false,
                            );
                            dataBox.add(newTodo);
                            Navigator.pop(context);
                          },
                          child: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                            primary: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Icon(
              Icons.add,
              size: 32.0,
            ),
            backgroundColor: Colors.amber,
          );
        },
      ),
    );
  }
}
