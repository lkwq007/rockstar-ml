# rockstar-ml

rockstar-ml is a Rockstar interpreter implemented in OCaml

## Motivation

I learned of the Rockstar programming language from the Hacker News several days ago. Since I wanna do some experiments with `ocamllex` and `menhir` , I decided to implement an interpreter for this literally interesting programming language. 

It takes me about 8 hours to finish this project with OCaml ( Thanks to my prior knowledge of `lex` and `yacc` , I was able to learn how to use the `ocamllex` and `menhir` easily ). And with some conventions forgotten, there may be some minor bugs in the lexer and parser. Thereby, I really appreciate and welcome contributions that can help me fix these bugs. 

## Spec - Implementation

- ❌File format - `ocamllex` not support UTF-8
- ✔️Comments
- 🐛Variables - Still some bugs, as the spec is ambiguous
  - ✔️Common variables
  - ✔️Proper variables
  - ✔️Pronouns - don't know variable scope, so assume global scope, using the previous parsed variable
- ✔️Types - Not support `dec64`
  - ✔️Mysterious
  - ✔️Null
  - ✔️Boolean
  - ❌Number - not support `dec64`, use `float` instead
  - ✔️String
  - ❌Object - lack details in spec
- ✔️Literals and Assignment
- ✔️Single Quotes - use a preprocessor
- ✔️Increment and Decrement
- ✔️Arithmetic - only support `float`
- 🐛Poetic Literals - may exist bugs
  - ✔️Poetic Type Literals
  - ✔️Poetic String Literals
  - ✔️Poetic Number Literals
- ✔️Comparison - support `and` and `or` operators
- ✔️Input/Output - about endline?
- ✔️Flow Control and Block Syntax
  - ✔️Conditionals
  - ✔️Loops
  - ✔️Blocks - brute implementation
- ✔️Functions - but nested function is not allowed

## How to build

```sh
make
```

or just 

```sh
ocamlbuild -use-menhir rockstar.native
```

## Usage

```
./rockstar.native <options> <files>
Options are:
  -stdin Read script from standard input
  -ast Print the ast rather than eval the script
```

## Demo

Here's the content of `demo.rock`, which is taken from the official spec. 

```
Midnight takes your heart and your soul (function)
While your heart is as high as your soul (loop, comparison, conditional)
Put your heart without your soul into your heart (assign, arithmetic)

Give back your heart


Desire is a lovestruck ladykiller
My world is nothing 
Fire is ice
Hate is water
Until my world is Desire
Build my world up
If Midnight taking my world, Fire is nothing and Midnight taking my world, Hate is nothing
Shout "FizzBuzz!" (output)
Take it to the top (break)

If Midnight taking my world, Fire is nothing (if, comparison, conditional, function)
Shout "Fizz!"
Take it to the top

If Midnight taking my world, Hate is nothing
Say "Buzz!" (test comment)
Take it to the top

Whisper my world

Listen to my words (input)
Put my words into your soul
Say your soul

Nothing is true
Everything is premitted
Octocat says nothing
Say Octocat
Octocat is nobody
Say Octocat
Octocat is true
Say Octocat

C is a
If C is greater than 1
Say C

Else
Build C up
Say C

While C is lower than 100
Build C up
Say C
If C is greater than 5
Break it down

Else
While C is lower than 5
If Octocat is true and true ain't t'r'u'e'''''''''''''''''
Say "Nyan"

Build C up


Say C

D
Say it
```

Result is shown below.

The abstract syntax tree:
```
# ./rockstar.native -ast demo.rock
Midnight(your heart your soul )
{
  WHILE(((Var: your heart)>=(Var: your soul)))
  {
    your heart=((Var: your heart)-(Var: your soul))
  }
  Return: (Var: your heart)
}
Define: (Var: Desire,100.)
Define: (Var: my world,Null)
Define: (Var: Fire,3.)
Define: (Var: Hate,5.)
UNTIL(((Var: my world)=(Var: Desire)))
{
  Inc: my world
  IF((((Call Midnight:[(Var: my world),(Var: Fire),])=(Val: Null))&&((Call Midnight:[(Var: my world),(Var: Hate),])=(Val: Null))))
  {
    Print: (Val: "FizzBuzz!")
    Continue
  }
  ELSE
  {
    Nop
  }
  IF(((Call Midnight:[(Var: my world),(Var: Fire),])=(Val: Null)))
  {
    Print: (Val: "Fizz!")
    Continue
  }
  ELSE
  {
    Nop
  }
  IF(((Call Midnight:[(Var: my world),(Var: Hate),])=(Val: Null)))
  {
    Print: (Val: "Buzz!")
    Continue
  }
  ELSE
  {
    Nop
  }
  Print: (Var: my world)
}
Scan to: my words
your soul=(Var: my words)
Print: (Var: your soul)
Define: (Var: Nothing,True)
Define: (Var: Everything,9.)
Define: (Var: Octocat,"nothing")
Print: (Var: Octocat)
Define: (Var: Octocat,Null)
Print: (Var: Octocat)
Define: (Var: Octocat,True)
Print: (Var: Octocat)
Define: (Var: C,1.)
IF(((Var: C)>(Val: 1.)))
{
  Print: (Var: C)
}
ELSE
{
  Inc: C
  Print: (Var: C)
}
WHILE(((Var: C)<(Val: 100.)))
{
  Inc: C
  Print: (Var: C)
  IF(((Var: C)>(Val: 5.)))
  {
    Break
  }
  ELSE
  {
    WHILE(((Var: C)<(Val: 5.)))
    {
      IF((((Var: Octocat)=(Val: True))&&((Val: True)!=(Val: True))))
      {
        Print: (Val: "Nyan")
      }
      ELSE
      {
        Nop
      }
      Inc: C
    }
  }
  Print: (Var: C)
}
(Var: D)
Print: (Var: D)
```

The output of script:
```
# echo 65535 | ./rockstar.native demo.rock
1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.41.42.43.44.45.46.47.48.49.50.51.52.53.54.55.56.57.58.59.60.61.62.63.64.65.66.67.68.69.70.71.72.73.74.75.76.77.78.79.80.81.82.83.84.85.86.87.88.89.90.91.92.93.94.95.96.97.98.99.100.65535.nothingNullTrue2.3.5.6.Undefined
```