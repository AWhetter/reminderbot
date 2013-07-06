reminderbot
===========

Inspired by ReminderBot' (https://github.com/davidlazar/ReminderBot), this cinch
IRC bot plugin lets you set reminders on IRC using natural language.

Installation
------------
If you already have a cinch IRC bot set up then installation is as simple as
adding the reminder.rb file into your bots file directory and adding `Reminder`
to the `plugins.plugins` array in the configure block of your bot's starting
file.

```ruby
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
end
bot.start
```

If you don't already have a bot set up then an example one is provided in
reminderbot.rb. Just change the configuration to the settings you want, and then
run with `ruby reminderbot.rb`.
For more information on configuring a chinch bot, take a look at the cinch
documentation (https://github.com/achiu/cinch-github).

Usage
-----
Example:

    remind me in 30 minutes to take cake out of oven

You can also use multiple units of time in one reminder. eg:

    remind me in 1 hour and 30 minutes to go to stop coding and go to bed!

The currently supported units of time are years, weeks, days, hours, minutes,
and seconds.

    remind me in 2 years 6 weeks 5 days 2 hours 5 minutes and 6 seconds that
    we should have Back To The Future hoverboards by now!

TODO
-----
Tests!
Add support for saving reminders, and reloading them on startup if the bot dies
Add support for repeating reminders (with a configurable minimum interval)
Turn into a gem?
