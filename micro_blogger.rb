require 'jumpstart_auth'
require 'bitly'
require 'pry'

class MicroBlogger
  attr_reader :client

  def initialize
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Your tweet cannot be more than 140 characters"
    end
  end

  def dm(target, message)
    screen_names = @client.followers.collect do |follower|
      @client.user(follower).screen_name
    end

    if screen_names.include?(target)
      puts "Trying to send #{target} this direct message:"
      puts message
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You are not following @#{target}."
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each do |follower|
      dm(follower, message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends
    sorted = friends.sort_by { |a| @client.user(a).screen_name.downcase }
    sorted.each do |friend|
      timestamp = @client.user(friend).status.created_at

      puts "On #{timestamp.strftime("%A, %b %d")}, @#{@client.user(friend).screen_name} said..."
      puts "...#{@client.user(friend).status.text}."
    end
  end

  def shorten(original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')

    puts "Shortening this URL: #{original_url}"
    return bitly.shorten(original_url).short_url
  end

  def run
    puts "Welcome to the JSL Twitter Client!"

    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]

      case command
      when 'q'
        then puts "Goodbye!"
      when 't'
        then tweet(parts[1..-1].join(" "))
      when 'dm'
        then dm(parts[1], parts[2..-1].join(" "))
      when 'spam'
        then spam_my_followers(parts[1..-1].join(" "))
      when 'elt'
        then everyones_last_tweet
      when 'turl'
        then tweet(parts[1..-2].join("") + " " + shorten(parts[-1]))
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end

  end
end

blogger = MicroBlogger.new

blogger.run
