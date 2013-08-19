require 'cinch'
require 'time'
require_relative 'a_reminder'

class Reminder
    include Cinch::Plugin

    Day_reg = /days?|d/
    Hour_reg = /hours?|hrs?|h/
    Week_reg = /weeks?|wks?|w/
    Year_reg = /years?|yr|y/
    Minute_reg = /minutes?|mins?|m/
    Second_reg = /seconds?|secs?|s/
    Time_unit_reg = Regexp.union(Day_reg, Hour_reg, Week_reg, Year_reg, Minute_reg, Second_reg)

    match /remind me in (?<times>([[:digit:]]+ *#{Time_unit_reg} +(and)? *)+)(?<text>.*)/, use_prefix: false

    def initialize(*args)
        super
        @reminders = []
        File.open('reminders.csv', 'r').each do |line|
            # We control the format of the file so we don't need fancy CSV
            # features, so split is fine.
            # We can also assume it's sorted by reminder time.
            row = line.split(',', 5)
            remind_at = Time.parse(row[3])
            if remind_at > Time.now
                @reminders << AReminder.new(row[0],
                                       row[1],
                                       row[2],
                                       Time.parse(row[3]),
                                       row[4])
            end
        end

        create_timer
    end

    def execute(m, times, text)
        time_list = times.split ' '
        time_list.delete "and"

        time_to_add = 0
        time_list.each_slice(2) do |time|
            quantity = is_int? time[0]
            time_unit = parse_time_unit time[1]
            if quantity and quantity > 0 and time_unit
                time_to_add += quantity * time_unit
            else
                m.reply "Invalid time format. Reminder not set."
                return
            end
        end

        time_was = Time.now
        remind_at = time_was + time_to_add
        add_reminder(m.channel, m.user, time_was, remind_at, text)
        m.reply "Okay, I'll remind you about that on #{remind_at}"
    end

    private
    def add_reminder(channel, sender, created_at, remind_at, text)
        to_add = AReminder.new(channel, sender, created_at, remind_at, text)
        @reminders.unshift(to_add)
        @reminders.sort! # O(2n) because of unshift
        if @reminders[0] == to_add
            create_timer
        end
        save_reminders
    end

    def create_timer
        if not @reminders.empty?
            until_next_reminder = @reminders[0].remind_at - Time.now
            if until_next_reminder >= 0
                @timer = Timer until_next_reminder, method: :send_next_reminder, shots: 1
            else
                # Better late then never!
                @reminders[0].send_msg(@bot, "#{@reminders[0].sender}: This is #{0 - until_next_reminder} seconds late. Sorry!")
                send_next_reminder
            end
        else
            @timer = nil
        end
    end

    def is_int?(given_str)
        begin
            return Integer(given_str)
        rescue
            return nil
        end
    end

    def parse_time_unit(str_unit)
        if str_unit =~ /^#{Day_reg}/
            return 24*60*60
        elsif str_unit =~ /^#{Hour_reg}/
            return 60*60
        elsif str_unit =~ /^#{Week_reg}/
            return 7*24*60*60
        elsif str_unit =~ /^#{Year_reg}/
            return 365*24*60*60
        elsif str_unit =~ /^#{Minute_reg}/
            return 60
        elsif str_unit =~ /^#{Second_reg}/
            return 1
        end

        return nil
    end

    def save_reminders
        File.open('reminders.csv', 'w') do |file|
            @reminders.each do |reminder|
                file.puts(reminder.to_csv_s)
            end
        end
    end

    def send_next_reminder
        # If anything fails with sending the reminder we need the queue to
        # continue to be processed
        begin
            # @bot is from Cinch::Plugin
            @reminders[0].send(@bot)
        rescue
            nil
        end

        begin
            @reminders.slice!(0)
        rescue
            nil
        end

        create_timer
    end
end
