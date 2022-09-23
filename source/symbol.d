module kut.symbol;

import std.conv : to;
import kut.interpreter;

KutObject symbolAssignMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   dstring key = self.data.symbol;
   KutObject value = args[0];
   variables[key] = value;
   return value;
}

KutObject symbolAddAssignMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   KutObject newValue = self.data.symbol.getVariableValue(variables).methodCall("+", args, kwargs, immutableVariables, variables);
   return self.symbolAssignMethod([newValue], kwargs, immutableVariables, variables);
}

KutObject symbolSubAssignMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   KutObject newValue = self.data.symbol.getVariableValue(variables).methodCall("-", args, kwargs, immutableVariables, variables);
   return self.symbolAssignMethod([newValue], kwargs, immutableVariables, variables);
}

KutObject symbolMulAssignMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   KutObject newValue = self.data.symbol.getVariableValue(variables).methodCall("*", args, kwargs, immutableVariables, variables);
   return self.symbolAssignMethod([newValue], kwargs, immutableVariables, variables);
}

KutObject symbolDivAssignMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   KutObject newValue = self.data.symbol.getVariableValue(variables).methodCall("/", args, kwargs, immutableVariables, variables);
   return self.symbolAssignMethod([newValue], kwargs, immutableVariables, variables);
}

KutObject symbolPowAssignMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   KutObject newValue = self.data.symbol.getVariableValue(variables).methodCall("^", args, kwargs, immutableVariables, variables);
   return self.symbolAssignMethod([newValue], kwargs, immutableVariables, variables);
}

KutObject symbolStringifyMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   dstring identifier = self.data.symbol;
   return KutObject.string_(("Symbol(" ~ identifier ~ ")").to!dstring);
}

KutDispatchedMethodType[dstring] getSymbolMethods() {
   return [
      "olsun": &symbolAssignMethod,
      "ekle": &symbolAddAssignMethod,
      "çıkar": &symbolSubAssignMethod,
      "çarp": &symbolMulAssignMethod,
      "böl": &symbolDivAssignMethod,
      "üs-al": &symbolPowAssignMethod,
      "metinleştir": &symbolStringifyMethod,
   ];
}


