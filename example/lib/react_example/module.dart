library module;

import 'package:recompose_dart/recompose_dart.dart';
import 'package:over_react/over_react.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_redux/built_redux.dart';

import '../reducers/app_state.dart';
import '../reducers/api.dart';
import '../reducers/todo.dart';
import '../reducers/group.dart';
import 'select.dart';
import 'creator.dart';

part 'module.g.dart';

abstract class TodoProps implements Built<TodoProps, TodoPropsBuilder> {
  AppStateActions get actions;
  int get currentGroup;
  BuiltMap<int, Group> get groups;
  BuiltMap<int, Todo> get todos;
  String get title;

  TodoProps._();
  factory TodoProps([updates(TodoPropsBuilder b)]) = _$TodoProps;
}

var todosReduxBuilder = compose<ReduxProps<AppState>, TodoProps>([
  mapReduxStoreToProps<AppState, TodoProps>(
      (ReduxProps<AppState> reduxProps) => new TodoProps((b) => b
        ..actions = reduxProps.store.actions
        ..currentGroup = reduxProps.store.state.currentGroup
        ..groups = reduxProps.store.state.groups.groupMap.toBuilder()
        ..todos = currentGroupTodos(reduxProps.store.state).toBuilder()
        ..title = "redux")),
  pure,
  lifecycle<TodoProps>(
      componentDidUpdate: (oldProps, newProps) => print('prev: $oldProps\nnew: $newProps')),
])(todosComponent);

ReactElement todosComponent(TodoProps props) => Dom.div()(
      todoHeader(props),
      selectComponent(new SelectProps()
        ..label = 'group'
        ..currentGroup = props.currentGroup
        ..optionMap = props.groups
        ..onSelect = props.actions.setCurrentGroup),
      creatorComponent(new CreatorProps()
        ..onSubmit = props.actions.creationActions.createGroup
        ..name = 'group'),
      Dom.div()(),
      creatorComponent(new CreatorProps()
        ..onSubmit = props.actions.creationActions.createTodo
        ..name = 'todo'),
      todoItems(props),
      (Dom.button()..onClick = (_) => props.actions.setBogus(3))('bogus props change'),
    );

ReactElement todoHeader(TodoProps props) =>
    Dom.div()('${props.title} TODOS: (${props.todos.length})');

ReactElement todoItems(TodoProps props) => Dom.div()(
      props.todos.values.map(
        (Todo todo) => todoItem(todo, props.actions.todosActions.updateTodoStatus),
      ),
    );

ReactElement todoItem(Todo todo, ActionMgr<int> updateTodoStatus) => (Dom.div()..key = todo.id)(
      todo.text,
      (Dom.input()
        ..onChange = ((_) => updateTodoStatus(todo.id))
        ..checked = todo.done
        ..type = 'checkbox')(),
    );