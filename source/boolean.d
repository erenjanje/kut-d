module kut.boolean;

import std.conv : to;
import kut.interpreter;

KutObject booleanStringifyMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   return KutObject.string_(self.data.boolean ? "doğru".to!dstring : "yanlış".to!dstring);
}

KutDispatchedMethodType[dstring] getBooleanMethods() {
   return [
      "metinleştir": &booleanStringifyMethod,
   ];
}

