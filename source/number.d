module kut.number;

import kut.interpreter;
import std.conv : to;

KutObject numberPlusMethod(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   const KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   double num = self.data.number;
   KutObject value = args[0];
   if(value.type != KutType.Number) {
      return KutObject.undefined;
   }
   return KutObject.number(num + value.data.number);
}

KutObject numberMinusMethod(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   const KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   double num = self.data.number;
   KutObject value = args[0];
   if(value.type != KutType.Number) {
      return KutObject.undefined;
   }
   return KutObject.number(num - value.data.number);
}

KutObject numberMultiplyMethod(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   const KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   double num = self.data.number;
   KutObject value = args[0];
   if(value.type != KutType.Number) {
      return KutObject.undefined;
   }
   return KutObject.number(num * value.data.number);
}

KutObject numberDivideMethod(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   const KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   double num = self.data.number;
   KutObject value = args[0];
   if(value.type != KutType.Number) {
      return KutObject.undefined;
   }
   return KutObject.number(num / value.data.number);
}

KutObject numberExponentMethod(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   const KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   double num = self.data.number;
   KutObject value = args[0];
   if(value.type != KutType.Number) {
      return KutObject.undefined;
   }
   return KutObject.number(num ^^ value.data.number);
}

KutObject numberStringifyMethod(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   const KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   double num = self.data.number;
   return KutObject.string_(num.to!dstring);
}

KutDispatchedMethodType[dstring] getNumberMethods() {
   return [
      "+": &numberPlusMethod,
      "-": &numberMinusMethod,
      "*": &numberMultiplyMethod,
      "/": &numberDivideMethod,
      "^": &numberExponentMethod,
      "metinleştir": &numberStringifyMethod,
   ];
}

