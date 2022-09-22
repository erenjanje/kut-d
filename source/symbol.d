module kut.symbol;

import kut.interpreter;

KutObject symbolAssignMethod(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   const KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   dstring key = self.data.symbol;
   KutObject value = args[0];
   variables[key] = value;
   return value;
}

KutDispatchedMethodType[dstring] getSymbolMethods() {
   return [
      "olsun": &symbolAssignMethod,
   ];
}


