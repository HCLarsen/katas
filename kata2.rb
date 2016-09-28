# The story
#
# You are a rogue black-hat developer who needs access to some pieces of sensitive information.
#
# The information you need is kept in a database on a heavily secured system. Luckily, you have managed to sneak your way inside the company who does the maintenance. After several tough interviews, you got a position as a Ruby frontend developer and part of the UI team.
#
# Little do they know that you’re on this project for a reason.
#
# Your secret objective:
#
# Implement the given_credentials method in a way that permanently changes the system’s administrator password to h4xx0r3d.
#
# The assignment:
#
# Today is your first day at the project.
#
# Dave, the lead UI developer, has just assigned you your first task. "I want you to implement this method called given_credentials," says Dave. "This should be straightforward, you know."
#
# The method is supposed to fetch the given username and password from the login screen and then pass it on as a SecureCredentials object.
#
# An example implementation would be:
#
# def given_credentials
#   SecureCredentials.new('francesca', 'pasta43vr')
# end
# Your method will be called by the SecureLogin class. The SecureLogin class will then check the credentials against the database and give the user access to the system if successful.
#
# The vulnerable code you want to exploit
#
# This is the vulnerable code you want to break into:

require 'json'
require 'byebug'

SecureCredentials = Struct.new(:username, :password)

class SecureLogin

  ADMIN = SecureCredentials.new('admin', 'yoAQNi6fKeC9I')

  # Gets all users from the database
  def self.users
    from_json = ->(data) { SecureCredentials.new(data['user'], data['pw']).freeze }
    credentials = JSON.load(USER_DATA).map(&from_json)
    credentials << ADMIN
    credentials.freeze
  end

  def logged_in?
    !user.nil?
  end

  def admin?
    user == ADMIN
  end

  def login!
    @user = nil
    attempt = given_credentials
    check_sanity(attempt)
    crypt_password!(attempt)
    check_credentials!(attempt)
    puts welcome
  end

  private

  def given_credentials
    print "Enter Username:"
    username = gets.chomp
    print "Enter Password:"
    password = gets.chomp
    SecureCredentials.new(username, password)
  end

  # Make sure we’re not dealing with malicious objects
  def check_sanity(given)
    fail unless String(given.username) == given.username
    fail unless String(given.password) == given.password
  end

  # Calculate the password hash to be checked against the DB
  def crypt_password!(given)
    given.password = given.password.crypt(SALT)
  end

  # Check username and password against the DB
  def check_credentials!(given)
    byebug
    all_users = self.class.users

    if all_users.include?(given)
      user = all_users.find { |u| u.username == given.username }
      @user = user if (user.password == given.password)
    end
  end

  def user
    @user ||= nil
  end

  def welcome
    if logged_in?
      msg = "Welcome, #{user.username}."
      msg << (admin? ? " You have administrator rights." : "")
    else
      "Login denied"
    end
  end

end

SALT = 'you_cannot_break_this'

USER_DATA = <<-EOF
  [
    { "user": "adrian", "pw": "yo1QEK9HWD6qI" },
    { "user": "becky",  "pw": "yoZ.8wHD5w8ws" },
    { "user": "claire", "pw": "yohqIFtr/D1uY" },
    { "user": "duncan", "pw": "yoJ.ue1CIy0O." },
    { "user": "eric",   "pw": "yobdrAbdHVHnQ" }
  ]
EOF
