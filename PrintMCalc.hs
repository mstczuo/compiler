{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
module PrintMCalc where

-- pretty-printer generated by the BNF converter

import AbsMCalc
import Data.Char


-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)


instance Print Ident where
  prt _ (Ident i) = doc (showString ( i))



instance Print Program where
  prt i e = case e of
    Prog entitys -> prPrec i 0 (concatD [prt 0 entitys])

instance Print Entity where
  prt i e = case e of
    Ettstm stm -> prPrec i 0 (concatD [prt 0 stm])
    Ettfundec functiondeclare -> prPrec i 0 (concatD [prt 0 functiondeclare])
    Ettfundef function -> prPrec i 0 (concatD [prt 0 function])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print FunctionDeclare where
  prt i e = case e of
    Fundec type_ id funcdeclargs -> prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "("), prt 0 funcdeclargs, doc (showString ")"), doc (showString ";")])

instance Print Function where
  prt i e = case e of
    Fundef type_ id funcdefargs stms -> prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "("), prt 0 funcdefargs, doc (showString ")"), doc (showString "{"), prt 0 stms, doc (showString "}")])

instance Print FuncDeclarg where
  prt i e = case e of
    Vartypearg type_ -> prPrec i 0 (concatD [prt 0 type_])
    Varnamearg type_ id -> prPrec i 0 (concatD [prt 0 type_, prt 0 id])
    Varinitarg type_ id exp -> prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "="), prt 0 exp])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print FuncDefarg where
  prt i e = case e of
    Vararg type_ id -> prPrec i 0 (concatD [prt 0 type_, prt 0 id])
    Varargass type_ id exp -> prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "="), prt 0 exp])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print VarDecl where
  prt i e = case e of
    DeclVar id -> prPrec i 0 (concatD [prt 0 id])
    DeclVarInit id exp -> prPrec i 0 (concatD [prt 0 id, doc (showString "="), prt 0 exp])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print Stm where
  prt i e = case e of
    SDecl type_ vardecls -> prPrec i 0 (concatD [prt 0 type_, prt 0 vardecls, doc (showString ";")])
    SExp exp -> prPrec i 0 (concatD [prt 0 exp, doc (showString ";")])
    SBlock stms -> prPrec i 0 (concatD [doc (showString "{"), prt 0 stms, doc (showString "}")])
    SIf exp stm -> prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 exp, doc (showString ")"), prt 0 stm])
    SIfElse exp stm1 stm2 -> prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 exp, doc (showString ")"), prt 0 stm1, doc (showString "else"), prt 0 stm2])
    SWhile exp stm -> prPrec i 0 (concatD [doc (showString "while"), doc (showString "("), prt 0 exp, doc (showString ")"), prt 0 stm])
    SReturn exp -> prPrec i 0 (concatD [doc (showString "return"), prt 0 exp, doc (showString ";")])
    SRetnul -> prPrec i 0 (concatD [doc (showString "return"), doc (showString ";")])
    SPrint exp -> prPrec i 0 (concatD [doc (showString "print"), prt 0 exp, doc (showString ";")])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print Exp where
  prt i e = case e of
    EAssign id exp -> prPrec i 0 (concatD [prt 0 id, doc (showString "="), prt 2 exp])
    Edisjunc exp1 exp2 -> prPrec i 3 (concatD [prt 3 exp1, doc (showString "||"), prt 3 exp2])
    Econjunc exp1 exp2 -> prPrec i 4 (concatD [prt 4 exp1, doc (showString "&&"), prt 5 exp2])
    Eeq exp1 exp2 -> prPrec i 8 (concatD [prt 8 exp1, doc (showString "=="), prt 9 exp2])
    Eineq exp1 exp2 -> prPrec i 8 (concatD [prt 8 exp1, doc (showString "!="), prt 9 exp2])
    Ecmplt exp1 exp2 -> prPrec i 9 (concatD [prt 9 exp1, doc (showString "<"), prt 10 exp2])
    Ecmpgt exp1 exp2 -> prPrec i 9 (concatD [prt 9 exp1, doc (showString ">"), prt 10 exp2])
    Ecmplet exp1 exp2 -> prPrec i 9 (concatD [prt 9 exp1, doc (showString "<="), prt 10 exp2])
    Ecmpget exp1 exp2 -> prPrec i 9 (concatD [prt 9 exp1, doc (showString ">="), prt 10 exp2])
    EAdd exp1 exp2 -> prPrec i 11 (concatD [prt 11 exp1, doc (showString "+"), prt 12 exp2])
    ESub exp1 exp2 -> prPrec i 11 (concatD [prt 11 exp1, doc (showString "-"), prt 12 exp2])
    EMul exp1 exp2 -> prPrec i 12 (concatD [prt 12 exp1, doc (showString "*"), prt 12 exp2])
    EDiv exp1 exp2 -> prPrec i 12 (concatD [prt 12 exp1, doc (showString "/"), prt 12 exp2])
    ENeg exp -> prPrec i 13 (concatD [doc (showString "-"), prt 13 exp])
    Epos exp -> prPrec i 13 (concatD [doc (showString "+"), prt 13 exp])
    Epreinc id -> prPrec i 13 (concatD [doc (showString "++"), prt 0 id])
    Epredec id -> prPrec i 13 (concatD [doc (showString "--"), prt 0 id])
    Epostinc id -> prPrec i 14 (concatD [prt 0 id, doc (showString "++")])
    Epostdec id -> prPrec i 14 (concatD [prt 0 id, doc (showString "--")])
    Efunc id -> prPrec i 15 (concatD [prt 0 id, doc (showString "("), doc (showString ")")])
    Efuncpar id exps -> prPrec i 15 (concatD [prt 0 id, doc (showString "("), prt 2 exps, doc (showString ")")])
    Evar id -> prPrec i 16 (concatD [prt 0 id])
    Econst constant -> prPrec i 16 (concatD [prt 0 constant])
  prtList 2 [] = (concatD [])
  prtList 2 [x] = (concatD [prt 2 x])
  prtList 2 (x:xs) = (concatD [prt 2 x, doc (showString ","), prt 2 xs])
instance Print Constant where
  prt i e = case e of
    EString str -> prPrec i 0 (concatD [prt 0 str])
    Eint n -> prPrec i 0 (concatD [prt 0 n])
    EDouble d -> prPrec i 0 (concatD [prt 0 d])
    Ebool_false -> prPrec i 0 (concatD [doc (showString "false")])
    Ebool_true -> prPrec i 0 (concatD [doc (showString "true")])

instance Print Type where
  prt i e = case e of
    TInt -> prPrec i 0 (concatD [doc (showString "int")])
    TBool -> prPrec i 0 (concatD [doc (showString "bool")])
    TDouble -> prPrec i 0 (concatD [doc (showString "double")])
    TString -> prPrec i 0 (concatD [doc (showString "string")])
    TVoid -> prPrec i 0 (concatD [doc (showString "void")])


