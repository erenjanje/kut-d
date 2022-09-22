module kut.console_screen;

import kut.interpreter;
import std.conv : to;
import std.stdio;

public class KutScreen : ExternalKutObject {
private:
   KutObject write(KutObject self,
      KutObject[] args,
      KutObject[dstring] kwargs,
      const KutObject[dstring] immutableVariables,
      ref KutObject[dstring] variables
   ) {
      KutObject arg = args[0];
      if(arg.type == KutType.String_) {
         writeln(arg.data.string_);
      } else {
         KutObject text = arg.methodCall("metinleştir", null, null, immutableVariables, variables);
         if(text.type != KutType.String_) {
            throw new Error("A stringify method must return a string value!");
         }
         writeln(text.data.string_);
      }
      return self;
   }
public:
   override KutObject dispatch(KutObject self,
      dstring method,
      KutObject[] args,
      KutObject[dstring] kwargs,
      const KutObject[dstring] immutableVariables,
      ref KutObject[dstring] variables
   ) {
      switch(method) {
         case "yazsın":
            return this.write(self, args, kwargs, immutableVariables, variables);
         default:
            return KutObject.undefined;
      }
   }

}
