module FifthedSim
  class RollRepl
    def initialize(inspect = true, errors = false)
      @inspect = inspect
      @errors = errors
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

    def run_cmd(cmd)
      case cmd
      when /(quit|exit|stop)/
        self.exit
      when "help"
        self.help
      when "inspect"
        toggle_inspect
      when "errors"
        toggle_errors
      else
        self.roll(cmd)
      end
    end

    def roll(cmd)
      r = DiceExpression(cmd)
      @last_expression = r
      if @inspect
        puts "  =  " + r.value_equation(terminal: true)
        puts "  => " + Rainbow(r.value.to_s).underline.bright.to_s
      else
        puts r.value.to_s
      end
    rescue FifthedSim::Compiler::CompileError => e
      if e.char
        display_compile_error(e, cmd)
      else
        error_msg("Could not parse expression!")
      end
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

    [:inspect, :errors].each do |m|
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
      }
    end
  end
end
