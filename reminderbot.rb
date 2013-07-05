require 'cinch'
require_relative 'reminder'

bot = Cinch::Bot.new do
    configure do |c|
        c.server = "irc.freenode.org"
        c.channels = ["#cinch-bots"]
        c.nick = "coolreminderbot"
        c.port = 7000
        c.ssl.use = true
        c.user = "reminderbot"
        c.plugins.plugins = [Reminder]
    end

    on :message, "!help" do |m|
        m.reply "Current plugins: Reminder"
        m.reply "For a reminder just type 'remind me in 5 minutes to take cake out of oven'"
    end
end

bot.start
