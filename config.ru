require 'json'

class MySignUp
  def call(env)
  	body = [
  	'<!DOCTYPE html>
			<html>
				<body>
					<h2>Sign Up</h2>
					<form action="/signup_user">
					  Email:<br>
					  <input type="text" name="email">
					  <br>
					  Password:<br>
					  <input type="password" name="password">
					  <br>
					  Repeat Password:<br>
					  <input type="password", name="repassword">
					  <br><br>
					  <input type="submit" value="Submit">
					</form>
				</body>
			</html>'
		]

    [200, {'Content-Type' => 'text/html'}, body]
  end
end

class SignUpUser
  def call(env)
  	data = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
  	res = "Not found"

  	if data['email'] =~ /\@/
  		if data['password'] == data['repassword']
  			file = File.read('data.txt')
  			hash_data = eval(file)
  			hash_data[data['email']] = data['password']
  			File.open('data.txt', 'w') { |file| file.write(hash_data) }

  			res = "Create successful"
  		else
  			res = "Re Password Incorrect"
  		end
  	else
  		res = "Email Invalid"
  	end

    [200, { 'Content-Type' => 'text/html' }, [res]]
  end
end

class MySignIn
	def call(env)
  	body = [
  	'<!DOCTYPE html>
			<html>
				<body>
					<h2>Sign In</h2>
					<form action="/signin_user">
					  Email:<br>
					  <input type="text" name="email">
					  <br>
					  Password:<br>
					  <input type="password" name="password">
					  <br><br>
					  <input type="submit" value="Submit">
					</form>
				</body>
			</html>'
		]

		[200, {'Content-Type' => 'text/html'}, body]
	end
end

class SignInUser
	def call(env)
		# read file data
		file = File.read('data.txt')

		# get params
		data =  Rack::Utils.parse_nested_query(env['QUERY_STRING'])
		email = data['email']
		pass = data['password']

		# convert file data from string to hash
		hash_data = eval(file)
		# init variable for user login
		user_email = nil

		# loop hash to find email params
		hash_data.each do |k, val|
			if k == email
				if val = pass
					user_email = k
				end
			end
		end

		if user_email
			body = ["<h1>email: #{user_email}<h/1>"]
		else
			body = ["<h1>Email or Password Invalid</h1>"]
		end


		[200, {'Content-Type' => 'text/html'}, body]
	end
end

class HomePage
	def call(env)
		body = [
			'<h2><a href="/signup">Create new account</a></h2>
			<br />
			<a href="/signin" style="color: red;">Login</a>'
		]

		[200, {'Content-Type' => 'text/html'}, body]
	end
end

class MyNotFound
  def call(env)
  	body = ['<a href="/signup">Create new account</a><br /><a href="/signin">Login</a>']

    [200, { 'Content-Type' => 'text/html' }, body]
  end
end

map '/signup_user' do
  run SignUpUser.new
end

map '/signup' do
  run MySignUp.new
end

map '/signin' do
	run MySignIn.new
end

map '/signin_user' do
	run SignInUser.new
end

map '/' do
	run HomePage.new
end

run MyNotFound.new
