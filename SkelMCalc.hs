module SkelMCalc where

-- Haskell module generated by the BNF converter

import AbsMCalc
import ErrM
type Result = Err String

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transIdent :: Ident -> Result
transIdent x = case x of
  Ident string -> failure x
transProgram :: Program -> Result
transProgram x = case x of
  Prog entitys -> failure x
transEntity :: Entity -> Result
transEntity x = case x of
  Ettstm stm -> failure x
  Ettfundec functiondeclare -> failure x
  Ettfundef function -> failure x
transFunctionDeclare :: FunctionDeclare -> Result
transFunctionDeclare x = case x of
  Fundec type_ ident funcdeclargs -> failure x
transFunction :: Function -> Result
transFunction x = case x of
  Fundef type_ ident funcdefargs stms -> failure x
transFuncDeclarg :: FuncDeclarg -> Result
transFuncDeclarg x = case x of
  Vartypearg type_ -> failure x
  Varnamearg type_ ident -> failure x
  Varinitarg type_ ident exp -> failure x
transFuncDefarg :: FuncDefarg -> Result
transFuncDefarg x = case x of
  Vararg type_ ident -> failure x
  Varargass type_ ident exp -> failure x
transVarDecl :: VarDecl -> Result
transVarDecl x = case x of
  DeclVar ident -> failure x
  DeclVarInit ident exp -> failure x
transStm :: Stm -> Result
transStm x = case x of
  SDecl type_ vardecls -> failure x
  SExp exp -> failure x
  SBlock stms -> failure x
  SIf exp stm -> failure x
  SIfElse exp stm1 stm2 -> failure x
  SWhile exp stm -> failure x
  SReturn exp -> failure x
  SRetnul -> failure x
  SPrint exp -> failure x
transExp :: Exp -> Result
transExp x = case x of
  EAssign ident exp -> failure x
  Edisjunc exp1 exp2 -> failure x
  Econjunc exp1 exp2 -> failure x
  Eeq exp1 exp2 -> failure x
  Eineq exp1 exp2 -> failure x
  Ecmplt exp1 exp2 -> failure x
  Ecmpgt exp1 exp2 -> failure x
  Ecmplet exp1 exp2 -> failure x
  Ecmpget exp1 exp2 -> failure x
  EAdd exp1 exp2 -> failure x
  ESub exp1 exp2 -> failure x
  EMul exp1 exp2 -> failure x
  EDiv exp1 exp2 -> failure x
  ENeg exp -> failure x
  Epos exp -> failure x
  Epreinc ident -> failure x
  Epredec ident -> failure x
  Epostinc ident -> failure x
  Epostdec ident -> failure x
  Efunc ident -> failure x
  Efuncpar ident exps -> failure x
  Evar ident -> failure x
  Econst constant -> failure x
transConstant :: Constant -> Result
transConstant x = case x of
  EString string -> failure x
  Eint integer -> failure x
  EDouble double -> failure x
  Ebool_false -> failure x
  Ebool_true -> failure x
transType :: Type -> Result
transType x = case x of
  TInt -> failure x
  TBool -> failure x
  TDouble -> failure x
  TString -> failure x
  TVoid -> failure x
