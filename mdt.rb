
module MdT
  class RuleNotFoundException < Exception
  end
  class MdT
    attr_reader   :step_count
    def initialize(state, sym, prog)
      @state = State.new state
      @tape =  Tape.new sym
      @prog = prog
      @step_count = 0
    end
    def start
      until @state.is_final? do
        yield step
      end
    end
    def step
      irule = Rule.new @state, @tape.read
      rule = @prog.find do |r|
        r == irule
      end
      if rule
        @state = rule.fstate
        @tape.write rule.fsym
        @tape.mov rule.mov
        @step_count += 1
        return rule
      else
        raise RuleNotFoundException.new
      end
    end
    def status
      "State: #{@state}, Tape: #{@tape}"
    end
    def is_final_state?
      @state.is_final?
    end
  end
  
  class State
    attr_reader :state
    def initialize(s = 0)
      self.state = s
    end
    def state=(s)
      @state = s.to_i
    end
    def is_final?
      @state < 0
    end
    def to_s
      "#{@state}"
    end
    def ==(s)
      @state == s
    end
  end
  
  class Tape < Array
    BLANK = 'b'
    BLANK_FILL = 2
    attr_reader :head
    def initialize(syms = [BLANK])
      self.replace syms.split '' if syms.kind_of? String
      self.replace syms if syms.kind_of? Array
      @head = 0
    end
    def read
      self[@head]
    end
    def write(sym)
      self[@head] = sym[0]
    end
    def mov(dir)
      send dir if respond_to? dir
    end
    def sx
      if @head == 0
        unshift BLANK
      else
        @head -= 1
      end
    end
    def dx
      if @head == (self.size - 1)
        push BLANK
      end
      @head += 1
    end
    def nx
    end
    def to_s
      blanks = BLANK * BLANK_FILL
      sx = slice 0, @head
      dx = slice @head+1, size
      "#{blanks}#{sx.join}|#{read}|#{dx.join}#{blanks}"
    end
  end
  
  class Rule
    attr_reader   :istate, :isym
    attr_reader   :fstate, :fsym, :mov
    def initialize(*args)
      @name = ''
      assign = Proc.new do |i|
        @istate = State.new args[i]
        @isym = args[i+1]
        @fstate = State.new args[i+2]
        @fsym = args[i+3]
        self.mov = args[i+4]
      end
      case args.size
      when 2 then
        @istate, @isym = args[0], args[1]
      when 5 then
        assign.call(0)
      when 6 then
        @name = args[0]
        assign.call(1)
      end
    end
    def ==(r)
      (r.istate == @istate) and (r.isym == @isym)
    end
    alias eql? ==
    alias hash ==
    def to_s
      mov_sym = case @mov
      when :dx then '>>'
      when :sx then '<<'
      when :nx then '<>'
      end
      "#{@name}. #{@istate} + #{@isym} => #{@fstate} + #{@fsym} + #{ mov_sym }"
    end
    private 
    def mov=(m)
      @mov = m if m == :sx or m == :dx or m == :nx
    end
  end
  
end
