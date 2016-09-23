require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	# инициализация БД
	init_db
end

# configure вызывается каждый раз при конфигурации приложения:
# когда изменился код программы и перезагрузилась страница

configure do
	# инициализация БД
	init_db

	# создает таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	 (
	 id INTEGER PRIMARY KEY AUTOINCREMENT,
	  created_date DATE,
	  content TEXT
	   )'
 end

get '/' do
	# выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

# обработчик get - запроса / new 
# (браузер получает страницу с сервера)

get '/new' do
	erb :new
end

# обработчик post - запроса /new
# (браузер отправляет данные на сервер)

post '/new' do
	# получаем переменную из post-запроса
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	# сохраненин данных в БД

	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	# перенаправление на главную страницу

	redirect to '/'
end

# вывод информации о посте
# обработчик для details, получаем параметр из URL

get '/details/:post_id' do

	# получаем переменную из URL' а 
	post_id = params[:post_id]

	# получаем список постов
	# (у нас только один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]

	# выбираем этот один пост в переменную @row
	@row = results[0]
	# возвращаем представление details.erb
	erb :details
end

# обработчик post-запроса /details/...
# (браузер отправляет данные на сервер, мы их принимаем)
post '/details/:post_id' do

	# получаем переменную из URL' а 
	post_id = params[:post_id]

	# получаем переменную из post-запроса
	content = params[:content]

	erb "You typed comment #{content} for post #{post_id}"

end