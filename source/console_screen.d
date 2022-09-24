module kut.console_screen;

import kut.interpreter;
import std.conv : to;
import std.stdio;

public class KutScreen : ExternalKutObject {
private:
   KutObject writeScreen(KutObject self,
      KutObject[] args,
      KutObject[dstring] kwargs,
      KutObject[dstring] immutableVariables,
      ref KutObject[dstring] variables
   ) {
      dstring sep = "\n";
      if("ayracıyla" in kwargs) {
         KutObject sepObj = kwargs["ayracıyla"];
         if(sepObj.isString_) {
            sep = sepObj.data.string_;
         }
      }
      for(size_t i = 0; i < args.length; i++) {
         KutObject arg = args[i];
         if(arg.type == KutType.String_) {
            write(arg.data.string_);
         } else {
            KutObject text = arg.methodCall("metinleştir", null, null, immutableVariables, variables);
            if(text.type != KutType.String_) {
               writeln(arg.type);
               throw new Error("A stringify method must return a string value!");
            }
            write(text.data.string_);
         }
         if(i != args.length-1) {
            write(sep);
         }
      }
      return self;
   }
public:
   override KutObject dispatch(KutObject self,
      dstring method,
      KutObject[] args,
      KutObject[dstring] kwargs,
      KutObject[dstring] immutableVariables,
      ref KutObject[dstring] variables
   ) {
      switch(method) {
         case "yazsın":
            return this.writeScreen(self, args, kwargs, immutableVariables, variables);
         default:
            return KutObject.undefined;
      }
   }

}
