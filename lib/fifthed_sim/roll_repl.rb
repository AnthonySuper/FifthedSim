module FifthedSim
  class RollRepl
    def initialize(inspect: true,
                   errors: false,
                   auto_info: false)
      @inspect = inspect
      @errors = errors
      @auto_info = auto_info
    end

    def run(kill_on_interrupt = false)
      begin
        while buf = Readline.readline("> ", true)
          run_cmd(buf)
          kill_on_interrupt = false
        end
      rescue Interrupt
        self.exit if kill_on_interrupt
        puts "Control-C again or 'Exit' to quit"
        run(true)
      end
    end

    def info_command(cmd)
      s = cmd.gsub(/info/, "").chomp
      if s.length > 0
        roll(s)
      end
      print_last_info
    end

    def print_last_info
      return error_msg("Have nothing to get info of") unless @last_roll
      lb = ->(x){Rainbow(x).color(:yellow).bright.to_s + ": "}
      a = %i(max min percentile).map do |p|
        lb[p] + @last_roll.public_send(p).to_s
      end.inject{|m, x| m + ", " + x}
      puts a
    end

    def reroll
      return error_msg("Nothing to reroll") unless @last_roll
      @last_roll = @last_roll.reroll
      display_roll(@last_roll)
    end

    def run_cmd(cmd)
      case cmd
      when /(quit|exit|stop)/
        self.exit
      when "rr", "reroll"
        self.reroll
      when "info"
        info_command(cmd)
      when "help"
        self.help
      when "inspect"
        toggle_inspect
      when "errors"
        toggle_errors
      when "autoinfo"
        toggle_auto_info
      else
        self.roll(cmd)
      end
    end

    def roll(cmd)
      r = DiceExpression(cmd)
      @last_roll = r
      display_roll(r)
    rescue FifthedSim::Compiler::CompileError => e
      if e.char
        display_compile_error(e, cmd)
      else
        error_msg("Could not parse expression!")
      end
    end

    def display_roll(r)
      puts "  =  " + r.value_equation(terminal: true) if @inspect  
      puts "  => " + Rainbow(r.value.to_s).underline.bright.to_s
      print_last_info if @auto_info
    end

    def error_msg(msg)
      puts Rainbow(msg).color(:red).bright
    end

    def display_compile_error(err, cmd)
      if @errors
        error_msg("Could not read line: #{err.tree_cause}")
      else
        error_msg("Could not read line: #{err.message}")
      end
    end

    [:inspect, :errors, :auto_info].each do |m|
      send(:define_method, "toggle_#{m}") do
        t = instance_variable_get("@#{m}")
        puts "#{m}: #{t.inspect} => #{(!t).inspect}"
        instance_variable_set("@#{m}", !t)
      end
    end

    def exit
      puts "Goodbye."
      exit!
    end

    def help
      cmd = ->(a){ Rainbow(a.to_s).bright.underline + ":" }
      puts %Q{COMMANDS:
      #{cmd[:help]} display this message
      #{cmd[:inspect]} toggle equation inspection
      #{cmd[:quit]} exit the roller
      #{cmd[:errors]} toggle in-depth compile errors for dice expressions
      #{cmd["arrow keys"]} navigate like GNU readline
      #{cmd[:info]} get info about the previous roll, or a roll on this line.
      #{cmd["rr, reroll"]} reroll the previous dice
      }
    end
  end
end
