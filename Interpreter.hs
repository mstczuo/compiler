module Interpreter where

-- interpreter for a calculator with "memory" (variable assignments)

import AbsMCalc
import PrintMCalc

import Control.Monad.State
import qualified Data.Map.Strict as Map

data Value
  = Vint Integer
  | Vdouble Double
  | Vstring String
  | Vbool Bool
  | Vvoid
  deriving (Eq, Ord)

yesno :: Value -> Bool
yesno (Vint vi) = (vi /= 0) :: Bool
yesno (Vbool vb) = vb 

instance Num Value where
  (+) v1 v2 = case (v1, v2) of
    (Vint a, Vint b) -> Vint (a + b)
    (Vdouble a, Vdouble b) -> Vdouble (a + b)
    (Vstring a, Vstring b) -> Vstring (a ++ b)
  (-) v1 v2 = case (v1, v2) of
    (Vint a, Vint b) -> Vint (a - b)
    (Vdouble a, Vdouble b) -> Vdouble (a - b)
  (*) v1 v2 = case (v1, v2) of
    (Vint a, Vint b) -> Vint (a * b)
    (Vdouble a, Vdouble b) -> Vdouble (a * b)
  abs val = case val of
    Vint a -> Vint (abs a)
    Vdouble a -> Vdouble (abs a)
  signum val = case val of
    Vint a -> Vint (signum a)
    Vdouble a -> Vdouble (signum a)
  fromInteger n = Vdouble (read (show n) :: Double)

instance Fractional Value where
  (/) v1 v2 = case (v1, v2) of
    (Vint a, Vint b) -> Vint (div a b)
    (Vdouble a, Vdouble b) -> Vdouble (a / b)
  fromRational n = Vdouble (read (show n) :: Double)

instance Show Value where
  show val = case val of
    Vint v -> (show v)
    Vbool v -> (show v)
    Vdouble v -> (show v)
    Vstring s -> (show s)
    Vvoid -> "NULL"

-- the interpreter

execProgram :: Program -> Action Void
execProgram p = case p of
  Prog ss -> do
    forEach ss handle
    funs <- gets functions
    case Map.lookup (Ident "main") funs of
      Just (Fundef t name arg stms) -> do
        forEach stms exec
      Nothing -> do
        return ()

handle :: Entity -> Action Void
handle et = case et of
  Ettstm stm -> do exec stm
  Ettfundec fdec -> return ()
  Ettfundef (Fundef t name args stms) -> do
    registFunc name (Fundef t name args stms)
    return ()

exec :: Stm -> Action Void
exec s = do
  flag <- gets flags
  case (head flag) of
    Just v -> return ()
    Nothing -> case s of
      SExp x -> do
        v <- eval x
        return ()
      SPrint e -> do
        v <- eval e
        output (show v)
      SIf judge stm -> do
        flag <- eval judge
        if yesno(flag) then 
            exec stm
        else
            return ()
      SIfElse judge stm1 stm2 -> do
        flag <- eval judge
        if yesno(flag) then
            exec stm1
        else
            exec stm2
      SWhile e b-> do
        flag <- eval e
        case yesno(flag) of
          False -> return()
          True -> do
            exec b
            exec s
      SBlock ss -> do
        forEach ss exec
      SDecl t vars -> do
        forAll vars (initvar t)
        return ()
      SReturn e -> do
        v <- eval e
        modify (\s -> s{flags = Just v : tail (flags s)}) 
        return ()
      SRetnul -> do
        modify (\s -> s{flags = (Just Vvoid) : tail (flags s)}) 
        return ()
  
zero_val :: Type -> Action Value
zero_val TInt = return (Vint 0)
zero_val TDouble = return (Vdouble 0)
zero_val TString = return (Vstring "")
zero_val TVoid = return (Vvoid)
zero_val TBool = return (Vbool False)

initvar :: Type -> VarDecl -> Action Value
initvar t vdec = case vdec of
  DeclVar var -> do
    v <- zero_val t
    updateVar var v
    return (v)
  DeclVarInit var e -> do
    v <- eval e
    updateVar var v
    return (v)

forAll:: [x] -> (x -> Action Value) -> Action Void
forAll ss comp = do
  mapM_ comp ss
  return ()

eval :: Exp -> Action Value
eval e = case e of
  Epostinc x -> do
    v <- lookupVar x
    updateVar x (v + (Vint 1))
    return (v)
  Epreinc x -> do
    v <- lookupVar x
    updateVar x (v + (Vint 1))
    return (v + (Vint 1))
  Epostdec x -> do
    v <- lookupVar x
    updateVar x (v - (Vint 1))
    return (v)
  Epredec x -> do
    v <- lookupVar x
    updateVar x (v - (Vint 1))
    return (v - (Vint 1))
  Econjunc exp1 exp2 -> do
    v1 <- eval exp1
    case v1 of 
      Vbool False -> return v1
      Vbool True -> eval exp2
  Edisjunc exp1 exp2 -> do
    v1 <- eval exp1
    case v1 of
      Vbool True -> return v1
      Vbool False -> eval exp2
  Eeq exp1 exp2 -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (Vbool (v1 == v2))
  Eineq exp1 exp2 -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (Vbool (v1 /= v2))
  Ecmplt exp1 exp2 -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (Vbool (v1 < v2))
  Ecmpgt exp1 exp2 -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (Vbool (v1 > v2))
  Ecmplet exp1 exp2 -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (Vbool (v1 <= v2))
  Ecmpget exp1 exp2 -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (Vbool (v1 >= v2))
  EAssign var e -> do
    v <- eval e
    updateVar var v
    return (v)
  EAdd exp1 exp2  -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (v1 + v2)
  ESub exp1 exp2  -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (v1 - v2)
  EMul exp1 exp2  -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (v1 * v2)
  EDiv exp1 exp2  -> do
    v1 <- eval exp1
    v2 <- eval exp2
    return (v1 / v2)
  Econst n -> return (get_const n)
  Evar x -> lookupVar x
  Efuncpar f exps -> do
    Fundef t name args stms <- lookupFunc f
    case ((length args) == (length exps)) of
        False -> do 
          er <- error("The number of arguments doesn't match")
          return (Vint 1)
        True -> do
          recursion args exps
          er <- forEach stms exec
          ret: _ <- gets flags
          modify (\s -> s{flags = tail (flags s)}) 
          case ret of
            Just val -> return val
            Nothing -> return (Vvoid)

get_const :: Constant -> Value
get_const e = case e of
  EString s -> Vstring s
  Eint i -> Vint i
  EDouble d -> Vdouble d
  Ebool_false -> Vint 0
  Ebool_true -> Vint 1

-- Actions: functions with side effects on a state

-- an Action is a State monad on Environment
type Action a = State Env a

-- a familiar name for Action whose return value is uninteresting
type Void = ()

-- iterate over a list of elementes
forEach :: [x] -> (x -> Action Void) -> Action Void
forEach ss comp = mapM_ comp ss

-- the environment

data Env = ENV {
  variables :: [Map.Map Ident Value],
  functions :: Map.Map Ident Function,
  outputs   :: [String],
  flags     :: [Maybe Value],
  tmp       :: Map.Map Ident Value
  }

-- auxiliary functions

-- initial environment
initEnv :: Env
initEnv = ENV [Map.empty] Map.empty [] [Nothing] Map.empty

-- update the value of a variable
updateVar :: Ident -> Value -> Action Void
updateVar x v = modify (\s ->
  s{variables = [Map.insert x v (head (variables s))] ++ (tail (variables s)) }
  )

updateVar2 :: (FuncDefarg, Exp) -> Action Void
updateVar2 p = case p of
  ((Vararg t x), exp) -> do
    v <- eval exp
    modify (\s -> s{tmp = Map.insert x v (tmp s)})

-- lookup the value of a variable
lookupVar :: Ident -> Action Value
lookupVar x = do
  vars <- gets variables
  case Map.lookup x (head vars) of
    Just v  -> return v
    Nothing -> error ("unknown variable " ++ printTree x)

recursion :: [FuncDefarg] -> [Exp] -> Action Void
recursion args vals = do
  mapM_ updateVar2 (zip args vals)
  modify (\s -> s{flags = Nothing : (flags s)})
  modify (\s -> s{variables = (tmp s) : (variables s)})
  modify (\s -> s{tmp = Map.empty})
  return ()

-- registe an function 
registFunc :: Ident -> Function -> Action Void
registFunc x v = modify (\s ->
  s{functions = Map.insert x v (functions s)}
  )

-- lookup the functions
lookupFunc :: Ident -> Action Function
lookupFunc x = do
  funs <- gets functions
  case Map.lookup x funs of
    Just v  -> return v
    Nothing -> error ("unknown variable " ++ printTree x)

-- generate output
output :: String -> Action Void
output m = modify (\s ->
  s{outputs = outputs s ++ [m]}
  )
