require 'io/console'

require_relative './lib/steamweb.rb'

def read(field_name, noecho = false)
  STDOUT.print "#{field_name}: "

  if noecho
    value = ''

    STDIN.noecho { |io| value = io.gets.chomp }
    STDOUT.print "\n"
  else
    value = STDIN.gets.chomp
  end

  value
end

login_incorrect = false

loop do
  username = read 'Username'
  password = read 'Password', true

  login_success = false
  login_options = {}
  login_retry = false

  loop do
    login = SteamWeb.login username, password, login_options

    login_options = {}
    login_retry = false

    if login[:captcha_needed]
      puts "Captcha required: https://steamcommunity.com/public/captcha.php?gid=#{login[:captcha_gid]}"
      captcha_text = read 'Captcha Text'

      login_options[:captcha_gid] = login[:captcha_gid]
      login_options[:captcha_text] = captcha_text

      login_retry = true
    end

    if login[:emailauth_needed]
      puts "SteamGuard required: check your email"
      steamguard_code = read 'SteamGuard Code'

      login_options[:emailauth_steamid] = login[:emailauth_steamid]
      login_options[:emailauth] = steamguard_code

      login_retry = true
    end

    if login[:login_success]
      puts "Login success: #{login[:login_session_id]}"

      login_success = true
    end

    break if !login_retry && (login_incorrect || login_success)
  end

  break if login_success
end
