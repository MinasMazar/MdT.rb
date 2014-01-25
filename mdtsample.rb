#!ruby
require './mdt'

Rule = MdT::Rule
prog = [ 
  Rule.new('slide DX', 1, 'c', 1, 'c', :dx),
  Rule.new('slide DX', 1, 'i', 1, 'i', :dx),
  Rule.new('slide DX', 1, 'a', 1, 'a', :dx),
  Rule.new('slide DX', 1, 'o', 1, 'o', :dx),
  Rule.new('turn!'   , 1, 'b', 3, 'b', :sx),
  Rule.new('slide SX', 3, 'c', 3, 'c', :sx),
  Rule.new('slide SX', 3, 'i', 3, 'i', :sx),
  Rule.new('slide SX', 3, 'a', 3, 'a', :sx),
  Rule.new('slide SX', 3, 'o', 3, 'o', :sx),
  Rule.new('stop!'   , 3, 'b',-1, 'b', :sx),

]

mdt = MdT::MdT.new 1, 'ciao', prog
puts "MdT Loaded: [#{mdt.status}]"
begin
  mdt.start do |rule|
    puts "***** STEP #{mdt.step_count} *****"
    puts "Applyed #{rule}"
    puts mdt.status
    puts "******************"  
  end
rescue MdT::RuleNotFoundException
  puts "Rule not found. MdT is stopped."
end
if mdt.is_final_state?
  puts "MdT found a final state after #{mdt.step_count} step"
end

