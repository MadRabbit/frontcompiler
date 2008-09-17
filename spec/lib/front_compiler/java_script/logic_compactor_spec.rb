require File.dirname(__FILE__)+"/../../../spec_helper"

describe FrontCompiler::JavaScript::LogicCompactor do
  def compact(src)
    FrontCompiler::JavaScript.new(src).compact_logic
  end
  
  it "should have the compact_logic method" do 
    FrontCompiler::JavaScript.new('').should respond_to(:compact_logic)
  end
  
  it "should convert multi-lined if/else short constructions" do 
    compact(%{
      var a = b ?
        c : d;
      var a = b
        ? c : d;
      var a = b ?
        c :
        d;
      var a = b
        ? c
        : d;
    }).should == %{
      var a = b ? c : d;
      var a = b ? c : d;
      var a = b ? c : d;
      var a = b ? c : d;
    }
  end
  
  it "should convert multi-lined assignments" do 
    compact(%{ 
      var a =
        b + c;
      var a = b -
        c;
      var a = b
        % c;
    }).should == %{ 
      var a = b + c;
      var a = b - c;
      var a = b % c;
    }
  end
  
  it "should convert mutli-lined method-calls chain" do 
    compact(%{
      var a = b
        .c()
        .d();
    }).should == %{
      var a = b.c().d();
    }
  end
  
  it "should convert multi-lined method calls" do 
    compact(%{
      var a = b(
        c,
        d
      );
      var a = b(
        c, d
      );
    }).should == %{
      var a = b(c, d);
      var a = b(c, d);
    }
  end
  
  it "should convert multi-lined logical expressions" do 
    compact(%{
      if (a
          && b ||
          c)
        var d = e
          | f &
          g;
    }).should == %{
      if (a && b || c)
        var d = e | f & g;
    }
  end
  
  it "should not touch multilined logic constructions" do 
    compact(%{
      if (something) {
        bla;
        foo;
      }
      for (var k in o) {
        bla; foo;
      }
      while (something) { bla; foo; }
    }).should == %{
      if (something) {
        bla;
        foo;
      }
      for (var k in o) {
        bla; foo;
      }
      while (something) { bla; foo; }
    }
  end
  
  it "should not break try/catch/finally constructions" do 
    compact(%{
      try { bla; bla
      }
      catch(e) {
        bla; bla; bla
      }
      finally { 
        bla; bla; bla
      }
    }).should == %{
      try { bla; bla
      }
      catch(e) {
        bla; bla; bla
      }
      finally { 
        bla; bla; bla
      }
    }
  end
  
  it "should convert simple multilined constructions" do 
    compact(%{
      if (something) {
        foo;
      } else { foo }
      for (var k in o) { foo; }
      do {
        something;
      } while(needed)
      while (something()) { foo }
    }).should == %{
      if (something) 
        foo;
       else  foo; 
      for (var k in o)  foo; 
      do 
        something;
       while(needed)
      while (something())  foo; 
    }
  end
  
  it "should keep internal multilined constructions safe" do 
    compact(%{
      if (something) {
        for (var i=0; i<something.length; i++) {
          var boo = something[i];
          var foo = boo % i;
        }
      }
    }).should == %{
      if (something) 
        for (var i=0; i<something.length; i++) {
          var boo = something[i];
          var foo = boo % i;
        }
      
    }
  end
  
  it "should handle nested constructions" do 
    compact(%{
      if (something) {
        for (var k in o) {
          while(something) {
            var o[k] = something;
          }
        }
      } else {
        while (something) {
          for (var k in o) {
            something = o[k];
          }
        }
      }
    }).should == %{
      if (something) 
        for (var k in o) 
          while(something) 
            var o[k] = something;
          
        
       else 
        while (something) 
          for (var k in o) 
            something = o[k];
          
        
      
    }
  end
  
  it "should keep doubleifs alive" do 
    compact(%{
      if (something) {
        if (something_else) {
          bla; bla;
        }
      }
    }).should == %{
      if (something) {
        if (something_else) {
          bla; bla;
        }
      }
    }
  end
end