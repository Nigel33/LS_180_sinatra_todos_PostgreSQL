require "pg"
require "pry"

class DatabasePersistence

  def initialize(logger)
    @db = PG.connect(dbname: "todos")
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    tuple = result.first

    list_id = tuple["id"].to_i
    {id: list_id, name: tuple["name"], todos: find_todos(list_id)}
  end

  def all_lists
    sql = "SELECT * FROM lists"
    result = query(sql)

    result.map do |tuple|
      list_id = tuple["id"].to_i
      {id: list_id, name: tuple["name"], todos: find_todos(list_id)}
    end
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    result = query(sql, list_name)
  end

  def delete_list(list_id)
    sql_lists = "DELETE FROM Lists WHERE id = $1"
    sql_todos = "DELETE FROM todos WHERE list_id = $1"
    result_todo = query(sql_todos, list_id)
    result_list = query(sql_lists, list_id)
  end

  def update_list_name(list_id, new_name)
    sql = "UPDATE lists SET name = $2 WHERE id = $1 "
    result = query(sql, list_id, new_name)
  end

  def create_new_todo(list_id, todo_name)
    sql = "INSERT INTO todos (list_id, name) VALUES($1, $2)"
    result = query(sql, list_id, todo_name)
  end

  def delete_todo_from_list(list_id, todo_id)
    sql_todos = "DELETE FROM todos WHERE list_id = $1 AND id = $2"
    result_todo = query(sql_todos, list_id, todo_id)
  end

  def update_todo_status(list_id, todo_id, new_status)
    sql = "UPDATE todos SET status = $1 WHERE id = $2 AND list_id = $3"
    query(sql, new_status, todo_id, list_id)
  end

  def mark_all_todos_as_completed(list_id)
   sql = "UPDATE todos SET status = true WHERE list_id = $1"
   query(sql, list_id)
  end

  private


  def find_todos(list_id)
    todo_sql = "SELECT * FROM todos WHERE list_id = $1"
    todos_result = query(todo_sql, list_id)

    todos = todos_result.map do |todo_tuple|
      { id: todo_tuple["id"],
        name: todo_tuple["name"],
        completed: todo_tuple["status"] == "t"
      }
    end
  end

end