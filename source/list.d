module kut.list;

import std.stdio;
import std.conv : to;
import std.string : format;
import kut.interpreter;

KutObject listMapMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   if(!("ile" in kwargs)) {
      return KutObject.undefined;
   }
   KutObject func = kwargs["ile"];
   KutList list = self.data.list;
   KutList ret = new KutList;
   KutObject[dstring] fakeKW;
   foreach(KutObject elem; list.sequential) {
      ret.sequential ~= func.methodCall("çağır", [elem], null, immutableVariables, variables);
   }
   foreach(dstring key; list.pairs.byKey) {
      ret.pairs[key] = func.methodCall("çağır", [list.pairs[key]], null, immutableVariables, variables);
   }
   return KutObject.list(ret);
}

KutObject listStringifyMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   dstring str = "{ ";
   if(self.data.list.sequential.length != 0) {
      foreach(KutObject obj; self.data.list.sequential) {
         KutObject inner = obj.methodCall("metinleştir", null, null, immutableVariables, variables);
         if(!inner.isString_) {
            throw new Error("A stringify method must return a string value!");
         }
         dstring innerStr = inner.data.string_;
         str ~= "%s ".format(innerStr).to!dstring;
      }
   }
   if(self.data.list.pairs.length != 0) {
      str ~= "\n";
   }
   if(self.data.list.pairs.length != 0) {
      foreach(dstring key; self.data.list.pairs.byKey) {
         KutObject val = self.data.list.pairs[key].methodCall("metinleştir", null, null, immutableVariables, variables);
         if(!val.isString_) {
            throw new Error("A stringify method must return a string value!");
         }
         dstring valStr = val.data.string_;
         str ~= "\t%s : %s\n".format(valStr, key).to!dstring;
      }
   }
   return KutObject.string_(str ~ "}".to!dstring);
}

KutDispatchedMethodType[dstring] getListMethods() {
   return [
      "metinleştir": &listStringifyMethod,
      "eşle": &listMapMethod,
   ];
}

