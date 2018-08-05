# rockstar-ml

rockstar-ml is a Rockstar interpreter implemented in OCaml

## Motivation

I learned of the Rockstar programming language from the Hacker News several days ago. Since I wanna do some experiments with `ocamllex` and `menhir` , I decided to implement an interpreter for this literally interesting programming language. 

It takes me about 8 hours to finish this project with OCaml ( Thanks to my prior knowledge of `lex` and `yacc` , I was able to learn how to use the `ocamllex` and `mehir` easily ). And with some conventions forgotten, there may be some minor bugs in the lexer and parser. Thereby, I really appreciate and welcome contributions that can help me fix those bugs. 

## Spec - Implementation

- [ ] File format - `ocamllex` not support UTF-8
- [x] Comments
- [x] Variables - Still some bugs, as the spec is ambiguous
      - [x] Common variables
      - [x] Proper variables
      - [x] Pronouns - don't know variable scope, so assume global scope, using the previous parsed variable
- [x] Types - Not support `dec64`
      - [x] Mysterious
      - [x] Null
      - [x] Boolean
      - [ ] Number - not support `dec64`, use `float` instead
      - [x] String
      - [ ] Object - lack details in spec
- [x] Literals and Assignment
      - [x] Single Quotes - use a preprocessor
      - [x] Increment and Decrement
      - [x] Arithmetic - only support `float`
      - [x] Poetic Literals
            - [x] Poetic Type Literals
            - [x] Poetic String Literals
            - [x] Poetic Number Literals
- [x] Comparison - support `and` and `or` operators
- [x] Input/Output
- [x] Flow Control and Block Syntax
      - [x] Conditionals
      - [x] Loops
      - [x] Blocks - there are some bugs with blocks
- [x] Functions - but nested function is not allowed

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
Midnight takes your heart and your soul
While your heart is as high as your soul
Put your heart without your soul into your heart

Give back your heart


Desire is a lovestruck ladykiller
My world is nothing 
Fire is ice
Hate is water
Until my world is Desire,
Build my world up
If Midnight taking my world, Fire is nothing and Midnight taking my world, Hate is nothing
Shout "FizzBuzz!"
Take it to the top

If Midnight taking my world, Fire is nothing
Shout "Fizz!"
Take it to the top

If Midnight taking my world, Hate is nothing
Say "Buzz!"
Take it to the top

Whisper my world
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
```

The output of script:
```
# ./rockstar.native demo.rock
1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.41.42.43.44.45.46.47.48.49.50.51.52.53.54.55.56.57.58.59.60.61.62.63.64.65.66.67.68.69.70.71.72.73.74.75.76.77.78.79.80.81.82.83.84.85.86.87.88.89.90.91.92.93.94.95.96.97.98.99.100.
```