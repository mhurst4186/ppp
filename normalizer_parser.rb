# Autogenerated from a Treetop grammar. Edits may be lost.


module Normalizer
  include Treetop::Runtime

  def root
    @root ||= :text
  end

  def _nt_text
    start_index = index
    if node_cache[:text].has_key?(index)
      cached = node_cache[:text][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      i1 = index
      r2 = _nt_directive
      if r2
        r1 = r2
      else
        r3 = _nt_comment
        if r3
          r1 = r3
        else
          r4 = _nt_quoted
          if r4
            r1 = r4
          else
            r5 = _nt_unquoted
            if r5
              r1 = r5
            else
              @index = i1
              r1 = nil
            end
          end
        end
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(Text,input, i0...index, s0)

    node_cache[:text][start_index] = r0

    r0
  end

  module Comment0
  end

  def _nt_comment
    start_index = index
    if node_cache[:comment].has_key?(index)
      cached = node_cache[:comment][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?("!", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure("!")
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if has_terminal?('\G[^\\n]', true, index)
          r3 = true
          @index += 1
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
      if r2
        s4, i4 = [], index
        loop do
          if has_terminal?("\n", false, index)
            r5 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("\n")
            r5 = nil
          end
          if r5
            s4 << r5
          else
            break
          end
        end
        if s4.empty?
          @index = i4
          r4 = nil
        else
          r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
        end
        s0 << r4
      end
    end
    if s0.last
      r0 = instantiate_node(Comment,input, i0...index, s0)
      r0.extend(Comment0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:comment][start_index] = r0

    r0
  end

  module Directive0
  end

  def _nt_directive
    start_index = index
    if node_cache[:directive].has_key?(index)
      cached = node_cache[:directive][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?("@", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure("@")
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if has_terminal?('\G[^\\n]', true, index)
          r3 = true
          @index += 1
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      if s2.empty?
        @index = i2
        r2 = nil
      else
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      end
      s0 << r2
      if r2
        if has_terminal?("\n", false, index)
          r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure("\n")
          r4 = nil
        end
        s0 << r4
      end
    end
    if s0.last
      r0 = instantiate_node(Directive,input, i0...index, s0)
      r0.extend(Directive0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:directive][start_index] = r0

    r0
  end

  module Quoted0
  end

  module Quoted1
  end

  def _nt_quoted
    start_index = index
    if node_cache[:quoted].has_key?(index)
      cached = node_cache[:quoted][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      i1 = index
      i2, s2 = index, []
      if has_terminal?('\G[\\"]', true, index)
        r3 = true
        @index += 1
      else
        r3 = nil
      end
      s2 << r3
      if r3
        s4, i4 = [], index
        loop do
          if has_terminal?('\G[^\\"]', true, index)
            r5 = true
            @index += 1
          else
            r5 = nil
          end
          if r5
            s4 << r5
          else
            break
          end
        end
        r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
        s2 << r4
        if r4
          if has_terminal?('\G[\\"]', true, index)
            r6 = true
            @index += 1
          else
            r6 = nil
          end
          s2 << r6
        end
      end
      if s2.last
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
        r2.extend(Quoted0)
      else
        @index = i2
        r2 = nil
      end
      if r2
        r1 = r2
      else
        i7, s7 = index, []
        if has_terminal?('\G[\\\']', true, index)
          r8 = true
          @index += 1
        else
          r8 = nil
        end
        s7 << r8
        if r8
          s9, i9 = [], index
          loop do
            if has_terminal?('\G[^\\\']', true, index)
              r10 = true
              @index += 1
            else
              r10 = nil
            end
            if r10
              s9 << r10
            else
              break
            end
          end
          r9 = instantiate_node(SyntaxNode,input, i9...index, s9)
          s7 << r9
          if r9
            if has_terminal?('\G[\\\']', true, index)
              r11 = true
              @index += 1
            else
              r11 = nil
            end
            s7 << r11
          end
        end
        if s7.last
          r7 = instantiate_node(SyntaxNode,input, i7...index, s7)
          r7.extend(Quoted1)
        else
          @index = i7
          r7 = nil
        end
        if r7
          r1 = r7
        else
          @index = i1
          r1 = nil
        end
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    if s0.empty?
      @index = i0
      r0 = nil
    else
      r0 = instantiate_node(Quoted,input, i0...index, s0)
    end

    node_cache[:quoted][start_index] = r0

    r0
  end

  def _nt_unquoted
    start_index = index
    if node_cache[:unquoted].has_key?(index)
      cached = node_cache[:unquoted][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?('\G[^\\\'\\"!@]', true, index)
        r1 = true
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    if s0.empty?
      @index = i0
      r0 = nil
    else
      r0 = instantiate_node(Unquoted,input, i0...index, s0)
    end

    node_cache[:unquoted][start_index] = r0

    r0
  end

end

class NormalizerParser < Treetop::Runtime::CompiledParser
  include Normalizer
end

