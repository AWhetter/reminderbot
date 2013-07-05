require 'cinch'
require 'rufus-scheduler'

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
        @scheduler = Rufus::Scheduler.start_new
    end

    def execute(m, times, text)
        time_list = times.split ' '
        time_list.delete "and"
        debug time_list

        time_to_add = 0
        time_list.each_slice(2) do |time|
            quantity = is_int? time[0]
            time_unit = parse_time_unit time[1]
            if quantity and time_unit
                time_to_add += quantity * time_unit
            else
                m.reply "Invalid time format. Reminder not set"
                return
            end
        end

        m.reply "Okay, I'll remind you about that on #{Time.now+time_to_add}"
        time_was = Time.now
        @scheduler.in "#{time_to_add}s" do
            m.reply "#{m.user.nick}: On #{time_was}, you asked me to remind you #{text}"
        end
    end

    private
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
end
