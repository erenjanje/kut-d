module kut.undefined;

import std.stdio;
import std.conv : to;
import std.string : format;
import kut.interpreter;

KutObject undefinedStringifyMethod(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   return KutObject.string_("tanımsız".to!dstring);
}

KutDispatchedMethodType[dstring] getUndefinedMethods() {
   return [
      "metinleştir": &undefinedStringifyMethod,
   ];
}

