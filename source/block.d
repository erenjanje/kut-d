module kut.block;

import std.stdio;
import std.conv : to;
import std.string : format;
import kut.parser : Token, TokenType;
import kut.interpreter;

KutObject blockStringifyMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   Token* ptr = &self.data.block;
   return KutObject.string_("Block[0x%X]".format(ptr).to!dstring);
}

KutObject blockCallMethod(
   KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
) {
   KutList argList;
   Token[] interpretedTokens;
   KutObject[dstring] backupVariables;
   dstring[] deletedIdentifiers;
   Token selfToken = self.data.block;
   Token[] selfInnerTokens = selfToken.data.block;
   Token blockHead = selfInnerTokens[0];

   if(blockHead.type == TokenType.List) {   
      argList = blockHead.eval(immutableVariables, variables).data.list;
      interpretedTokens = selfInnerTokens[1..$];
   } else {
      interpretedTokens = selfInnerTokens;
   }
   
   if(argList) {
      if(argList.sequential.length != args.length || argList.pairs.length != kwargs.length) {
         return KutObject.undefined;
      }
      for(size_t i = 0; i < argList.sequential.length; i++) {
         if(argList.sequential[i].type != KutType.Symbol) {
            throw new Error("Argument list must consist of only symbols!");
         }
         dstring identifier = argList.sequential[i].data.symbol;
         if(identifier in immutableVariables) {
            backupVariables[identifier] = immutableVariables[identifier];
         } else {
            deletedIdentifiers ~= identifier;
         }
         immutableVariables[identifier] = args[i];
      }
      foreach(dstring key; argList.pairs.byKey) {
         if(argList.pairs[key].type != KutType.Symbol) {
            throw new Error("Keyword arguments must consist of only symbols!");
         }
         if(!(key in kwargs)) {
            return KutObject.undefined;
         }
         dstring identifier = argList.pairs[key].data.symbol;
         if(identifier in immutableVariables) {
            backupVariables[identifier] = immutableVariables[identifier];
         } else {
            deletedIdentifiers ~= identifier;
         }
         immutableVariables[identifier] = kwargs[key];
      }
   }

   Token expr = Token.expression(interpretedTokens);

   KutObject ret = expr.eval(immutableVariables, variables);

   if(argList) {
      foreach(dstring backupKey; backupVariables.byKey) {
         immutableVariables[backupKey] = backupVariables[backupKey];
      }
      foreach(dstring deletedKey; deletedIdentifiers) {
         immutableVariables.remove(deletedKey);
      }
   }

   return ret;
}

KutDispatchedMethodType[dstring] getBlockMethods() {
   return [
      "metinleştir": &blockStringifyMethod,
      "çağır": &blockCallMethod,
   ];
}
