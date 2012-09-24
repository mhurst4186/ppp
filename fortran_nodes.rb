module Fortran

  @@env={}
  @@dolabels=[]
  @@level=0
  @@levelstack=[]

  def bb(s)
    @@level+=1
    s
  end

  def be
    @@level-=1 if @@level>0
  end

  def cat(f=nil)
    send(f) unless f.nil?
    self.elements.map { |e| e.to_s }.join
  end

  def dolabel_dupe?
    "#{@@dolabels[-1]}"=="#{@@dolabels[-2]}"
  end
  
  def dolabel_pop(label)
    @@dolabels.pop
  end

  def dolabel_push(label)
    @@dolabels.push(label)
  end

  def envget(k)
    @@env[k.to_s]||{}
  end

  def envset(k,v)
    @@env[k.to_s]=v
  end

  def fail(s)
    puts "\nERROR: "+s+"\n\nbacktrace:\n\n"
    begin
      raise
    rescue => e
      puts e.backtrace
    end
    puts
    exit(1)
  end

  def indent(s)
    ' '*2*@@level+s
  end

  def is_array?(node)
    envget(node.function_name)[:array]
  end

  def lr
    @@level=@@levelstack.pop
  end

  def ls
    @@levelstack.push(@@level)
  end

  def mn(p,c,v)
    (p.to_s!=c)?(v):(p)
  end
  
  def mp(p,c,v)
    (p.to_s==c)?(v):(p)
  end
  
  def msg(s)
    $stderr.write(">|#{s}|<\n")
  end

  def nonblock_do_end?(node)
    return false unless node.respond_to?(:label)
    return false if node.label.to_s.empty?
    ("#{node.label}"=="#{@@dolabels.last}")?(true):(false)
  end

  def nonblock_do_end!(node)
    @@dolabels.pop if nonblock_do_end?(node)
  end

  def sa(e)
    (e.to_s=='')?(''):("#{e} ")
  end

  def sb(e)
    (e.to_s=='')?(''):(" #{e}")
  end

  def sms(s)
    "#{e0}#{e1} "+s+"\n"
  end

  def space(x=nil)
    a=(x.nil?)?(self.elements[1..-1]):(self.elements)
    a.map { |e| e.to_s }.join(' ').strip
  end

  def stmt(s,f=nil)
    send(f) unless f.nil?
    indent(("#{sa(e0)}"+s.chomp).strip)+"\n"
  end

  def typeinfo(type_spec,attr_spec_option,entity_decl_list)
    props=entity_decl_list.props
    type=type_spec.type
    props.each { |k,v| v[:type]=type }
    if attr_spec_option.is_a?(Attr_Spec_Option) and attr_spec_option.dimension?
      props.each { |k,v| v[:array]=true }
    end
    props.each { |k,v| envset(k,v) }
    true
  end

  # Extension of SyntaxNode class

  class Treetop::Runtime::SyntaxNode
    def to_s
      ''
    end
  end

  # Generic Subclasses

  class T < Treetop::Runtime::SyntaxNode

    def initialize(a='',b=(0..0),c=[])
      super(a,b,c)
    end

    def method_missing(m,*a)
      if m=~/e(\d+)/
        e=elements[$~[1].to_i]
        (e.to_s=='')?(nil):(e)
      else
        fail "method_missing cannot find method '#{m}'"
      end
    end

    def to_s
      text_value
    end

  end

  class E < T
    def to_s
      cat
    end
  end

  class J < T
    def to_s
      space(:all)
    end
  end

  class StmtC < T
    def to_s
      stmt(elements[1..-1].map { |e| e.to_s }.join)
    end
  end

  class StmtJ < T
    def to_s
      stmt(space)
    end
  end

  # Specific Subclasses

  class Access_Stmt_Option < T
    def to_s() "#{mn(e0,'::',' ')}#{e1}" end
  end
  
  class Allocatable_Stmt < T
    def to_s() stmt("#{e1}#{mp(e2,'',' ')}#{e3}") end
  end
  
  class Arithmetic_If_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}#{e4} #{e5}#{e6}#{e7}#{e8}#{e9}") end
  end

  class Assigned_Goto_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{mn(e3,',',' '+e3.to_s)}") end
  end

  class Attr_Spec_Dimension < T
  end

  class Attr_Spec_List < T
    def dimension?()
      e0.is_a?(Attr_Spec_Dimension) or (e1 and e1.dimension?)
    end
  end

  class Attr_Spec_List_Pair < T
    def dimension?() e1.is_a?(Attr_Spec_Dimension) end
  end

  class Attr_Spec_List_Pairs < T
    def dimension?()
      elements.each { |e| return true if e.dimension? }
      false
    end
  end
  
  class Attr_Spec_Option < T
    def dimension?() e1.dimension? end
  end

  class Block_Data_Stmt < T
    def to_s() bb(stmt(space)) end
  end
  
  class Call_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}") end
  end
  
  class Case_Stmt < T
    def to_s() bb(stmt(space,:be)) end
  end
  
  class Common_Block_Name_And_Object_List < T
    def to_s() "#{mp(e0,'',' ')}#{e1}#{e2}" end
  end

  class Common_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}#{e4}") end
  end

  class Component_Def_Stmt < T
    def to_s() stmt("#{e1}#{mp(e2,'',' ')}#{e3}") end
  end

  class Computed_Goto_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}#{e4}#{mp(e5,'',' ')}#{e6}") end
  end

  class Contains_Stmt < T
    def to_s() bb(stmt(space,:be)) end
  end

  class Derived_Type_Stmt < T
    def to_s() bb(stmt("#{e1}#{sb(e2)} #{e3}")) end
  end

  class Dimension_Stmt < T
    def to_s() stmt("#{e1}#{mp(e2,'',' ')}#{e3}") end
  end
  
  class Do_Term_Action_Stmt < T
    def to_s() stmt(space,:be) end
  end

  class Do_Term_Shared_Stmt < T
    def to_s() cat(:be) end
  end

  class Double_Colon < T
  end

  class Else_If_Stmt < T
    def to_s() bb(stmt("#{e1} #{e2}#{e3}#{e4} #{e5}",:be)) end
  end

  class Else_Stmt < T
    def to_s() bb(stmt(space,:be)) end
  end

  class Elsewhere_Stmt < T
    def to_s() bb(stmt(space,:be)) end
  end

  class End_Block_Data_Option < T
    def to_s() space(:all) end
  end

  class End_Block_Data_Stmt < T
    def to_s() stmt(space,:be) end
  end
  
  class End_Do_Stmt < T
    def to_s() stmt(space,:be) end
  end

  class End_Function_Stmt < T
    def to_s() stmt(space,:be) end
  end
  
  class End_If_Stmt < T
    def to_s() stmt(space,:be) end
  end

  class End_Interface_Stmt < T
    def to_s() stmt(space,:be) end
  end
  
  class End_Module_Option < T
    def to_s() space(:all) end
  end

  class End_Module_Stmt < T
    def to_s() stmt(space,:be) end
  end
  
  class End_Program_Stmt < T
    def to_s() stmt("#{e1}#{sb(e3)}#{sb(e4)}",:be) end
  end

  class End_Select_Stmt < T
    def to_s() stmt(space,:lr) end
  end
  
  class End_Subroutine_Stmt < T
    def to_s() stmt(space,:be) end
  end
  
  class End_Type_Stmt < T
    def to_s() stmt(space,:be) end
  end

  class End_Where_Stmt < T
    def to_s() stmt(space,:be) end
  end

  class Entity_Decl_1 < T
    def array?() e1.is_a?(Treetop::Runtime::SyntaxNode) end
    def name() "#{e0}" end
    def props() {:name=>name,:array=>array?} end
  end

  class Entity_Decl_2 < T
    def array?() false end
    def name() "#{e0}" end
    def props() {:name=>name,:array=>array?} end
  end

  class Entity_Decl_List < T
    def props
      x={e0.props[:name]=>e0.props}
      e1.props.each { |e| x[e[:name]]=e } unless e1.nil?
      x
    end
  end
  
  class Entity_Decl_List_Pair < T
    def array?() e1.array? end
    def name() "#{e1.name}" end
    def props() e1.props end
  end

  class Entity_Decl_List_Pairs < T
    def props() elements.inject([]) { |m,e| m << e.props } end
  end

  class Entry_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}#{sb(e4)}") end
  end

  class Function_Stmt < T
    def to_s() bb(stmt("#{sa(e1)}#{e2} #{e3}#{e4}#{e5}#{e6}#{sb(e7)}")) end
  end

  class If_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}#{e4} #{e5.to_s.strip}") end
  end

  class If_Then_Stmt < T
    def to_s() bb(stmt("#{e1} #{e2} #{e3}#{e4}#{e5} #{e6}")) end
  end

  class Implicit_None_Stmt < E
    def to_s() stmt(space) end
  end

  class Implicit_Stmt < E
    def to_s() stmt(space) end
  end

  class Inner_Shared_Do_Construct < T
    def to_s() cat(:be) end
  end

  class Intent_Stmt < T
    def to_s() stmt("#{e1}#{e2}#{e3}#{e4}#{mn(e5,'::',' ')}#{e6}") end
  end

  class Interface_Stmt < T
    def to_s() bb(stmt(space)) end
  end
  
  class Label_Do_Stmt < T
    def to_s() bb(stmt("#{sa(e1)}#{e2} #{e3}#{e4}")) end
  end

  class Loop_Control_1 < T
    def to_s() "#{mp(e0,'',' ')}#{e1}#{e2}#{e3}#{e4}#{e5}" end
  end

  class Loop_Control_2 < T
    def to_s() "#{mp(e0,'',' ')}#{e1} #{e2}#{e3}#{e4}" end
  end

  class Module_Stmt < T
    def to_s() bb(stmt(space)) end
  end

  class Module_Subprogram_Part < T
    def to_s() "#{e0}#{elements[1].elements.reduce('') { |m,e| m << "#{e}" }}" end
  end

  class Namelist_Group_Set_Pair < T
    def to_s() "#{mp(e0,'',' ')}#{e1}" end
  end

  class Namelist_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}") end
  end

  class Nonlabel_Do_Stmt < T
    def to_s() bb(stmt("#{sa(e1)}#{e2}#{e3}")) end
  end

  class Optional_Stmt < T
    def to_s() stmt("#{e1}#{mn(e2,'::',' ')}#{e3}") end
  end
  
  class Pointer_Stmt < T
    def to_s() stmt("#{e1}#{mp(e2,'',' ')}#{e3}") end
  end
  
  class Print_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}") end
  end

  class Program_Stmt < T
    def to_s() bb(stmt(space)) end
  end

  class Program_Units < T
    def to_s() elements.reduce('') { |m,e| m << "#{e}\n" }.chomp end
  end
  
  class Read_Stmt_1 < T
    def to_s() stmt("#{e1}#{e2}#{e3}#{e4}#{sb(e5)}") end
  end

  class Read_Stmt_2 < T
    def to_s() stmt("#{e1} #{e2}#{e3}") end
  end

  class Save_Stmt < T
    def to_s() stmt("#{e1}#{e2}") end
  end

  class Save_Stmt_Entity_List < T
    def to_s() "#{mp(e0,'',' ')}#{e1}" end
  end
  
  class Select_Case_Stmt < T
    def to_s() bb(bb(stmt("#{sa(e1)}#{e2} #{e3} #{e4}#{e5}#{e6}",:ls))) end
  end

  ## SMS ##
  class SMS_Distribute_Begin < T
    def to_s() sms("#{e2} #{e3}") end
  end
  
  class SMS_Distribute_End < T
    def to_s() sms("#{e2}") end
  end
  
  class SMS_Halo_Comp_Begin < T
    def to_s() sms("#{e2} #{e3}") end
  end
  
  class SMS_Halo_Comp_End < T
    def to_s() sms("#{e2}") end
  end
  
  class SMS_Ignore_Begin < T
    def to_s() sms("#{e2} #{e3}") end
  end
  
  class SMS_Ignore_End < T
    def to_s() sms("#{e2}") end
  end
  
  class SMS_Parallel_Begin < T
    def to_s() sms("#{e2} #{e3}") end
  end
  
  class SMS_Parallel_End < T
    def to_s() sms("#{e2}") end
  end
  
  class SMS_Serial_Begin < T
    def to_s() sms("#{e2} #{e3}") end
  end
  
  class SMS_Serial_End < T
    def to_s() sms("#{e2}") end
  end
  
  class SMS_To_Local_Begin < T
    def to_s() sms("#{e2} #{e3}") end
  end
  
  class SMS_To_Local_End < T
    def to_s() sms("#{e2}") end
  end
  
  ## SMS ##

  class Subroutine_Stmt < T
    def to_s() bb(stmt("#{sa(e1)}#{e2} #{e3}#{e4}")) end
  end

  class Target_Stmt < T
    def to_s() stmt("#{e1}#{mp(e2,'',' ')}#{e3}") end
  end
  
  class Type_Declaration_Stmt < T
    def to_s() stmt("#{e1}#{mp(e2,'',mn(e1,',',' '))}#{e3}") end
  end

  class Type_Spec < E
    def derived?() "#{e0}"=="type" end
    def type() (derived?)?("#{e2}"):("#{e0}") end
  end

  class Use_Stmt_1 < T
    def to_s() stmt("#{e1} #{e2}#{e3}") end
  end
  
  class Use_Stmt_2 < T
    def to_s() stmt("#{e1} #{e2}#{e3}#{e4}#{e5}#{e6}") end
  end
  
  class Where_Construct_Stmt < T
    def to_s() bb(stmt("#{e1} #{e2}#{e3}#{e4}")) end
  end

  class Where_Stmt < T
    def to_s() stmt("#{e1} #{e2}#{e3}#{e4} #{e6.to_s.strip}") end
  end

  class Write_Stmt < T
    def to_s() stmt("#{e1}#{e2}#{e3}#{e4}#{sb(e5)}") end
  end
  
end

# paul.a.madden@noaa.gov
